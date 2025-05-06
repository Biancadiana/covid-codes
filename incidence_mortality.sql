select * from municipios_conurbacoes --tabela com geom, código IBGE (cd_mun), nome (nm_mun), sigla UF e área km² dos municípios da conurbação
select * from censo_pop_mun_2022 --tabela código IBGE, nome e população do município

create table artigo_conurbacoes_pr as (
select
	cd_mun,
	nm_mun,
	"Total",
	geom
from 
	municipios_conurbacoes
left join
	censo_pop_mun_2022
on
	cd_mun::numeric = "Código Município Completo")

--tabelas disponibilizadas pela Secretaria da Saúde do Paraná
select * from informe_epidemiologico_12_09_2020
select * from informe_epidemiologico_12_03_2021
select * from informe_epidemiologico_12_09_2021
select * from informe_epidemiologico_12_03_2022


---cria colunas para adicionar quantidade de casos e óbitos acumulados 
alter table artigo_conurbacoes_pr add column casos_120920 numeric;
alter table artigo_conurbacoes_pr add column obitos_120920 numeric;

alter table artigo_conurbacoes_pr add column casos_120321 numeric;
alter table artigo_conurbacoes_pr add column obitos_120321 numeric;

alter table artigo_conurbacoes_pr add column casos_120921 numeric;
alter table artigo_conurbacoes_pr add column obitos_120921 numeric;

alter table artigo_conurbacoes_pr add column casos_120322 numeric;
alter table artigo_conurbacoes_pr add column obitos_120322 numeric;


--adiciona quantidade de casos e óbitos acumulados
update artigo_conurbacoes_pr
set casos_120920 =  "Casos"
from informe_epidemiologico_12_09_2020
where cd_mun::numeric = "IBGE";

update artigo_conurbacoes_pr
set obitos_120920 =  "Obitos"
from informe_epidemiologico_12_09_2020
where cd_mun::numeric = "IBGE";

-----------------------
update artigo_conurbacoes_pr
set casos_120321 =  "Casos"
from informe_epidemiologico_12_03_2021
where cd_mun::numeric = "IBGE";

update artigo_conurbacoes_pr
set obitos_120321 =  "Obitos"
from informe_epidemiologico_12_03_2021
where cd_mun::numeric = "IBGE";
-------------------------

update artigo_conurbacoes_pr
set casos_120921 =  "Casos"
from informe_epidemiologico_12_09_2021
where cd_mun::numeric = "IBGE";

update artigo_conurbacoes_pr
set obitos_120921 =  "Obitos"
from informe_epidemiologico_12_09_2021
where cd_mun::numeric = "IBGE";
--------------------------

update artigo_conurbacoes_pr
set casos_120322 =  "CASOS"
from informe_epidemiologico_12_03_2022
where cd_mun::numeric = "IBGE";

update artigo_conurbacoes_pr
set obitos_120322 =  "ÓBITOS POR COVID-19"
from informe_epidemiologico_12_03_2022
where cd_mun::numeric = "IBGE";


----------------------------------------------------------------
---PERÍODOS - casos e obitos
--cria colunas para adicionar casos e óbitos de cada período
alter table artigo_conurbacoes_pr add column casos_periodo1 numeric;
alter table artigo_conurbacoes_pr add column obitos_periodo1 numeric;

alter table artigo_conurbacoes_pr add column casos_periodo2 numeric;
alter table artigo_conurbacoes_pr add column obitos_periodo2 numeric;

alter table artigo_conurbacoes_pr add column casos_periodo3 numeric;
alter table artigo_conurbacoes_pr add column obitos_periodo3 numeric;

alter table artigo_conurbacoes_pr add column casos_periodo4 numeric;
alter table artigo_conurbacoes_pr add column obitos_periodo4 numeric;

--adiciona casos e óbitos de cada período (a partir da subtração entre valores dos períodos)
--casos
update artigo_conurbacoes_pr
set casos_periodo1 = casos_120920

update artigo_conurbacoes_pr
set casos_periodo2 = casos_120321 - casos_120920

update artigo_conurbacoes_pr
set casos_periodo3 = casos_120921 - casos_120321

update artigo_conurbacoes_pr
set casos_periodo4 = casos_120322 - casos_120921

--obitos
update artigo_conurbacoes_pr
set obitos_periodo1 = obitos_120920

update artigo_conurbacoes_pr
set obitos_periodo2 = obitos_120321 - obitos_120920

update artigo_conurbacoes_pr
set obitos_periodo3 = obitos_120921 - obitos_120321

update artigo_conurbacoes_pr
set obitos_periodo4 = obitos_120322 - obitos_120921



-------------

--taxas epidemiológicas


--cria colunas para adicionar valores de incidência e mortalidade de cada período
alter table artigo_conurbacoes_pr add column incidencia_periodo1 numeric;
alter table artigo_conurbacoes_pr add column mortalidade_periodo1 numeric;

alter table artigo_conurbacoes_pr add column incidencia_periodo2 numeric;
alter table artigo_conurbacoes_pr add column mortalidade_periodo2 numeric;

alter table artigo_conurbacoes_pr add column incidencia_periodo3 numeric;
alter table artigo_conurbacoes_pr add column mortalidade_periodo3 numeric;

alter table artigo_conurbacoes_pr add column incidencia_periodo4 numeric;
alter table artigo_conurbacoes_pr add column mortalidade_periodo4 numeric;


--gera as taxas de cada período a partir da população de cada município
update artigo_conurbacoes_pr
set incidencia_periodo1 = round((casos_periodo1/"Total")*10000, 2)

update artigo_conurbacoes_pr
set incidencia_periodo2 = round((casos_periodo2/"Total")*10000, 2)

update artigo_conurbacoes_pr
set incidencia_periodo3 = round((casos_periodo3/"Total")*10000, 2)

update artigo_conurbacoes_pr
set incidencia_periodo4 = round((casos_periodo4/"Total")*10000, 2)


update artigo_conurbacoes_pr
set mortalidade_periodo1 = round((obitos_periodo1/"Total")*10000, 2)

update artigo_conurbacoes_pr
set mortalidade_periodo2 = round((obitos_periodo2/"Total")*10000, 2)

update artigo_conurbacoes_pr
set mortalidade_periodo3 = round((obitos_periodo3/"Total")*10000, 2)

update artigo_conurbacoes_pr
set mortalidade_periodo4 = round((obitos_periodo4/"Total")*10000, 2)


---------------------------------------------------------------------- 
--adição de coluna com sigla da conurbação para facilitar condições de query e order by
alter table artigo_conurbacoes_pr add column conurbacao varchar

update artigo_conurbacoes_pr
set conurbacao = b.conurbacao
from conurbacoes_parana b
where cd_mun = geocodm

------------------------------------------------------------------------
--queries de validação dos resultados
select 
	conurbacao, 
	nm_mun,  
	"Total",
	casos_120920,
	obitos_120920,
	casos_periodo1,
	obitos_periodo1, 
	incidencia_periodo1, 
	mortalidade_periodo1 
from 
	artigo_conurbacoes_pr
where 
	conurbacao = ''

---------------------------------
select 
	conurbacao, 
	nm_mun,  
	"Total",
	casos_120920,
	casos_120321,
	obitos_120920,
	obitos_120321,
	casos_periodo2,
	obitos_periodo2, 
	incidencia_periodo2, 
	mortalidade_periodo2 
from 
	artigo_conurbacoes_pr
where 
	conurbacao = ''

--------------------------------------------

select 
	conurbacao, 
	nm_mun,  
	"Total",
	casos_120321,
	casos_120921,
	obitos_120321,
	obitos_120921,
	casos_periodo3,
	obitos_periodo3, 
	incidencia_periodo3, 
	mortalidade_periodo3 
from 
	artigo_conurbacoes_pr
where 
	conurbacao = ''


---------------------------------

select 
	conurbacao, 
	nm_mun,  
	"Total",
	casos_120921,
	casos_120322,
	obitos_120921,
	obitos_120322,
	casos_periodo4,
	obitos_periodo4, 
	incidencia_periodo4, 
	mortalidade_periodo4 
from 
	artigo_conurbacoes_pr
where 
	conurbacao = ''
--------------------------------------------------------------------------

------------------------------------normalização para geração dos mapas
--cria colunas para adicionar valores normalizados de incidência e mortalidade
alter table artigo_conurbacoes_pr add column norm_inci_periodo1 numeric;
alter table artigo_conurbacoes_pr add column norm_inci_periodo2 numeric;
alter table artigo_conurbacoes_pr add column norm_inci_periodo3 numeric;
alter table artigo_conurbacoes_pr add column norm_inci_periodo4 numeric;

alter table artigo_conurbacoes_pr add column norm_mort_periodo1 numeric;
alter table artigo_conurbacoes_pr add column norm_mort_periodo2 numeric;
alter table artigo_conurbacoes_pr add column norm_mort_periodo3 numeric;
alter table artigo_conurbacoes_pr add column norm_mort_periodo4 numeric;


----teste em query select
select 
	cd_mun,
	incidencia_periodo1,
	round(
	(incidencia_periodo1 - MIN(incidencia_periodo1) OVER ()) / NULLIF(MAX(incidencia_periodo1) OVER () - MIN(incidencia_periodo1) OVER (), 0)
	, 2)
from
	artigo_conurbacoes_pr
where 
	conurbacao = 'RMC'
--------------------------------------------------------------------------INCIDENCIA
--------------------------------------------------------------------------
--adiciona valores normalizados de incidência e mortalidade nas colunas criadas anteriormente


---RMC
---------na subquery colocar condição da conurbação pro max e min ser tirado apenas dos município das conurbações e não do todo
update artigo_conurbacoes_pr a
set norm_inci_periodo1 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo1 - MIN(incidencia_periodo1) OVER ()) / NULLIF(MAX(incidencia_periodo1) OVER () - MIN(incidencia_periodo1) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun

----
update artigo_conurbacoes_pr a
set norm_inci_periodo2 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo2 - MIN(incidencia_periodo2) OVER ()) / NULLIF(MAX(incidencia_periodo2) OVER () - MIN(incidencia_periodo2) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun
----

update artigo_conurbacoes_pr a
set norm_inci_periodo3 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo3 - MIN(incidencia_periodo3) OVER ()) / NULLIF(MAX(incidencia_periodo3) OVER () - MIN(incidencia_periodo3) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun


----

update artigo_conurbacoes_pr a
set norm_inci_periodo4 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo4 - MIN(incidencia_periodo4) OVER ()) / NULLIF(MAX(incidencia_periodo4) OVER () - MIN(incidencia_periodo4) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun


-----------------------------------------MSP

update artigo_conurbacoes_pr a
set norm_inci_periodo1 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo1 - MIN(incidencia_periodo1) OVER ()) / NULLIF(MAX(incidencia_periodo1) OVER () - MIN(incidencia_periodo1) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun

----
update artigo_conurbacoes_pr a
set norm_inci_periodo2 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo2 - MIN(incidencia_periodo2) OVER ()) / NULLIF(MAX(incidencia_periodo2) OVER () - MIN(incidencia_periodo2) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun
----

update artigo_conurbacoes_pr a
set norm_inci_periodo3 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo3 - MIN(incidencia_periodo3) OVER ()) / NULLIF(MAX(incidencia_periodo3) OVER () - MIN(incidencia_periodo3) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun


----

update artigo_conurbacoes_pr a
set norm_inci_periodo4 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo4 - MIN(incidencia_periodo4) OVER ()) / NULLIF(MAX(incidencia_periodo4) OVER () - MIN(incidencia_periodo4) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun

------------------------------------------------LCI


update artigo_conurbacoes_pr a
set norm_inci_periodo1 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo1 - MIN(incidencia_periodo1) OVER ()) / NULLIF(MAX(incidencia_periodo1) OVER () - MIN(incidencia_periodo1) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun

----
update artigo_conurbacoes_pr a
set norm_inci_periodo2 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo2 - MIN(incidencia_periodo2) OVER ()) / NULLIF(MAX(incidencia_periodo2) OVER () - MIN(incidencia_periodo2) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun
----

update artigo_conurbacoes_pr a
set norm_inci_periodo3 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo3 - MIN(incidencia_periodo3) OVER ()) / NULLIF(MAX(incidencia_periodo3) OVER () - MIN(incidencia_periodo3) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun


----

update artigo_conurbacoes_pr a
set norm_inci_periodo4 = norm
from (
	select
	cd_mun,
	round((incidencia_periodo4 - MIN(incidencia_periodo4) OVER ()) / NULLIF(MAX(incidencia_periodo4) OVER () - MIN(incidencia_periodo4) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun




---------------------------------------------------------------------------------MORTALIDADE
---------------------------------------------------------------------------------
---RMC

update artigo_conurbacoes_pr a
set norm_mort_periodo1 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo1 - MIN(mortalidade_periodo1) OVER ()) / NULLIF(MAX(mortalidade_periodo1) OVER () - MIN(mortalidade_periodo1) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun

----
update artigo_conurbacoes_pr a
set norm_mort_periodo2 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo2 - MIN(mortalidade_periodo2) OVER ()) / NULLIF(MAX(mortalidade_periodo2) OVER () - MIN(mortalidade_periodo2) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun
----

update artigo_conurbacoes_pr a
set norm_mort_periodo3 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo3 - MIN(mortalidade_periodo3) OVER ()) / NULLIF(MAX(mortalidade_periodo3) OVER () - MIN(mortalidade_periodo3) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun


----

update artigo_conurbacoes_pr a
set norm_mort_periodo4 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo4 - MIN(mortalidade_periodo4) OVER ()) / NULLIF(MAX(mortalidade_periodo4) OVER () - MIN(mortalidade_periodo4) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'RMC'
) as b
where a.cd_mun = b.cd_mun


-----------------------------------------MSP

update artigo_conurbacoes_pr a
set norm_mort_periodo1 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo1 - MIN(mortalidade_periodo1) OVER ()) / NULLIF(MAX(mortalidade_periodo1) OVER () - MIN(mortalidade_periodo1) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun

----
update artigo_conurbacoes_pr a
set norm_mort_periodo2 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo2 - MIN(mortalidade_periodo2) OVER ()) / NULLIF(MAX(mortalidade_periodo2) OVER () - MIN(mortalidade_periodo2) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun
----

update artigo_conurbacoes_pr a
set norm_mort_periodo3 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo3 - MIN(mortalidade_periodo3) OVER ()) / NULLIF(MAX(mortalidade_periodo3) OVER () - MIN(mortalidade_periodo3) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun


----

update artigo_conurbacoes_pr a
set norm_mort_periodo4 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo4 - MIN(mortalidade_periodo4) OVER ()) / NULLIF(MAX(mortalidade_periodo4) OVER () - MIN(mortalidade_periodo4) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'MSP'
) as b
where a.cd_mun = b.cd_mun

------------------------------------------------LCI


update artigo_conurbacoes_pr a
set norm_mort_periodo1 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo1 - MIN(mortalidade_periodo1) OVER ()) / NULLIF(MAX(mortalidade_periodo1) OVER () - MIN(mortalidade_periodo1) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun

----
update artigo_conurbacoes_pr a
set norm_mort_periodo2 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo2 - MIN(mortalidade_periodo2) OVER ()) / NULLIF(MAX(mortalidade_periodo2) OVER () - MIN(mortalidade_periodo2) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun
----

update artigo_conurbacoes_pr a
set norm_mort_periodo3 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo3 - MIN(mortalidade_periodo3) OVER ()) / NULLIF(MAX(mortalidade_periodo3) OVER () - MIN(mortalidade_periodo3) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun


----

update artigo_conurbacoes_pr a
set norm_mort_periodo4 = norm
from (
	select
	cd_mun,
	round((mortalidade_periodo4 - MIN(mortalidade_periodo4) OVER ()) / NULLIF(MAX(mortalidade_periodo4) OVER () - MIN(mortalidade_periodo4) OVER (), 0), 2) as norm
	from 
	artigo_conurbacoes_pr
	where 
	conurbacao = 'LCI'
) as b
where a.cd_mun = b.cd_mun



--cria colunas para adicionar e, em seguida, adiciona as classes nas quais os valores normalizados se inserem
alter table artigo_conurbacoes_pr add column class_norm_inci_periodo1 varchar;
alter table artigo_conurbacoes_pr add column class_norm_inci_periodo2 varchar;
alter table artigo_conurbacoes_pr add column class_norm_inci_periodo3 varchar;
alter table artigo_conurbacoes_pr add column class_norm_inci_periodo4 varchar;


update artigo_conurbacoes_pr
set class_norm_inci_periodo1 =
	case
	when norm_inci_periodo1 between 0.00 and 0.19 then 'Muito baixo'
	when norm_inci_periodo1 between 0.20 and 0.39 then 'Baixo'
	when norm_inci_periodo1 between 0.40 and 0.59 then 'Médio'
	when norm_inci_periodo1 between 0.60 and 0.79 then 'Alto'
	when norm_inci_periodo1 between 0.80 and 1.00 then 'Muito alto'
	end
	
update artigo_conurbacoes_pr
set class_norm_inci_periodo2 = 
	case
	when norm_inci_periodo2 between 0.00 and 0.19 then 'Muito baixo'
	when norm_inci_periodo2 between 0.20 and 0.39 then 'Baixo'
	when norm_inci_periodo2 between 0.40 and 0.59 then 'Médio'
	when norm_inci_periodo2 between 0.60 and 0.79 then 'Alto'
	when norm_inci_periodo2 between 0.80 and 1.00 then 'Muito alto'
	end

update artigo_conurbacoes_pr
set class_norm_inci_periodo3 =
	case
	when norm_inci_periodo3 between 0.00 and 0.19 then 'Muito baixo'
	when norm_inci_periodo3 between 0.20 and 0.39 then 'Baixo'
	when norm_inci_periodo3 between 0.40 and 0.59 then 'Médio'
	when norm_inci_periodo3 between 0.60 and 0.79 then 'Alto'
	when norm_inci_periodo3 between 0.80 and 1.00 then 'Muito alto'
	end
	
update artigo_conurbacoes_pr
set class_norm_inci_periodo4 =
	case
	when norm_inci_periodo4 between 0.00 and 0.19 then 'Muito baixo'
	when norm_inci_periodo4 between 0.20 and 0.39 then 'Baixo'
	when norm_inci_periodo4 between 0.40 and 0.59 then 'Médio'
	when norm_inci_periodo4 between 0.60 and 0.79 then 'Alto'
	when norm_inci_periodo4 between 0.80 and 1.00 then 'Muito alto'
	end

alter table artigo_conurbacoes_pr add column class_norm_mort_periodo1 varchar;
alter table artigo_conurbacoes_pr add column class_norm_mort_periodo2 varchar;
alter table artigo_conurbacoes_pr add column class_norm_mort_periodo3 varchar;
alter table artigo_conurbacoes_pr add column class_norm_mort_periodo4 varchar;

	
update artigo_conurbacoes_pr
set class_norm_mort_periodo1 = 
	case  
	when norm_mort_periodo1 between 0.00 and 0.19 then 'Muito baixo'
	when norm_mort_periodo1 between 0.20 and 0.39 then 'Baixo'
	when norm_mort_periodo1 between 0.40 and 0.59 then 'Médio'
	when norm_mort_periodo1 between 0.60 and 0.79 then 'Alto'
	when norm_mort_periodo1 between 0.80 and 1.00 then 'Muito alto'
	end
	
update artigo_conurbacoes_pr
set class_norm_mort_periodo2 = 
	case  
	when norm_mort_periodo2 between 0.00 and 0.19 then 'Muito baixo'
	when norm_mort_periodo2 between 0.20 and 0.39 then 'Baixo'
	when norm_mort_periodo2 between 0.40 and 0.59 then 'Médio'
	when norm_mort_periodo2 between 0.60 and 0.79 then 'Alto'
	when norm_mort_periodo2 between 0.80 and 1.00 then 'Muito alto'
	end
	
 update artigo_conurbacoes_pr 
set class_norm_mort_periodo3 = 
	case  
	when norm_mort_periodo3 between 0.00 and 0.19 then 'Muito baixo'
	when norm_mort_periodo3 between 0.20 and 0.39 then 'Baixo'
	when norm_mort_periodo3 between 0.40 and 0.59 then 'Médio'
	when norm_mort_periodo3 between 0.60 and 0.79 then 'Alto'
	when norm_mort_periodo3 between 0.80 and 1.00 then 'Muito alto'
	end
	
 update artigo_conurbacoes_pr
set class_norm_mort_periodo4 = 
	case  
	when norm_mort_periodo4 between 0.00 and 0.19 then 'Muito baixo'
	when norm_mort_periodo4 between 0.20 and 0.39 then 'Baixo'
	when norm_mort_periodo4 between 0.40 and 0.59 then 'Médio'
	when norm_mort_periodo4 between 0.60 and 0.79 then 'Alto'
	when norm_mort_periodo4 between 0.80 and 1.00 then 'Muito alto'
	end