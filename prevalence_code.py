import pandas as pd
import os
import psycopg2
from dotenv import load_dotenv
from tqdm import tqdm
from sqlalchemy import create_engine

load_dotenv()

db_username = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_DATABASE")


engine = create_engine(
    f"postgresql+psycopg2://{db_username}:{db_password}@{db_host}:{db_port}/{db_name}"
)

conn = engine

table = 'informe_epidemiologico_12_03_2022_geral'
datas = 'artigo_conurbacoes_pr_casos'

#seleciona nome, código IBGE e população de cada município
pop_nome_df = pd.read_sql("""SELECT cd_mun::int, nm_mun::varchar, "Total"::int FROM artigo_conurbacoes_pr ORDER BY conurbacao, nm_mun """, conn)

ref_dict = {
    row['cd_mun']: {
        'nome': row['nm_mun'],
        'populacao': row['Total']
    }
    for _,row in pop_nome_df.iterrows()
}
print(f"{len(ref_dict)} municípios carregados no dicionário de referência.")


#seleciona datas de referência
data_df = pd.read_sql(f"""SELECT data FROM {datas} ORDER BY data""", conn) 
data_referencia = pd.to_datetime(data_df['data'])
print(f"{len(data_referencia)} datas únicas carregadas para análise.")


#seleciona apenas os códigos dos municípios
cd_mun = tuple(ref_dict.keys())
 


#função para contagem de casos dentro de um intervalo de 14 dias
def contar_casos_ativos (conn, data_fim, data_ini, table=table, cd_mun=cd_mun):
    query = f"""
        SELECT
            "IBGE_RES_PR" as cd_mun,
            COUNT(*) as casos
        FROM
            {table} 
        WHERE 
            "IBGE_RES_PR" IN {cd_mun} AND
            "DATA_DIAGNOSTICO"::date BETWEEN '{data_ini}' AND '{data_fim}'
        GROUP BY
            "IBGE_RES_PR"
    """
    return pd.read_sql(query, conn)


ativos_resultados = []

#repete a função pelas datas de referência
for data_ref in tqdm(data_referencia):
    data_ini = data_ref - pd.Timedelta(days=13)

    ativos_df = contar_casos_ativos(conn, data_fim=data_ref.date(), data_ini=data_ini.date())
    ativos_df['data'] = data_ref
    ativos_resultados.append(ativos_df)

    print(f"contando dados do dia {data_ref}")

#transforma lista dos resultados em um df
ativos_df = pd.concat(ativos_resultados)

ativos_pivot = ativos_df.pivot_table(index='data', columns='cd_mun', values='casos').fillna(0).astype(int)

ativos_pivot.reset_index(inplace=True)

tx_prevalencia = ativos_pivot.copy()

#aplica o calculo da prevalência para todas as linhas com base na população de cada município
for cd_mun in tx_prevalencia.columns:
    if cd_mun != 'data':
        pop = ref_dict.get(cd_mun, {}).get('populacao')
        if pop:
            tx_prevalencia[cd_mun] = (tx_prevalencia[cd_mun] / pop) * 10000
print("Cálculo da taxa de prevalência finalizado.")


#exporta 2 tabelas (casos ativos e prevalência) para sql
ativos_pivot.rename(columns={
    column: ref_dict[column]['nome'] for column in ativos_pivot.columns if column != 'data'
}, inplace=True)

ativos_pivot.to_sql('artigo_conurbacoes_casos_ativos_final', conn, index=False, if_exists='replace')
print("Tabela 'artigo_conurbacoes_casos_ativos' exportada com sucesso.")


tx_prevalencia.rename(columns={
    column: ref_dict[column]['nome'] for column in tx_prevalencia.columns if column != 'data'
}, inplace=True)

tx_prevalencia.to_sql('artigo_conurbacoes_prevalencia_final', conn, index=False, if_exists='replace')
print("Tabela 'artigo_conurbacoes_prevalencia' exportada com sucesso.")


