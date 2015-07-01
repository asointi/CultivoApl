/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[prod_generar_reporte_ramos_sin_pistolear]

@fecha datetime

AS

select ramo_despatado.id_ramo_despatado,
ramo_despatado.idc_ramo_despatado into #ramos_devueltos
from ramo_despatado,
ramo_devuelto
where ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado

alter table #ramos_devueltos
add ramo_real bit

update #ramos_devueltos
set ramo_real = 1
from ramo
where ramo.idc_ramo = #ramos_devueltos.idc_ramo_despatado

update #ramos_devueltos
set ramo_real = 1
from ramo_comprado
where ramo_comprado.idc_ramo_comprado = #ramos_devueltos.idc_ramo_despatado

select ramo_despatado.id_ramo_despatado,
persona.id_persona,
ramo_despatado.idc_ramo_despatado,
ramo_despatado.fecha_lectura,
ramo_despatado.tallos_por_ramo into #ramo
from ramo_despatado,
persona
where convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha
and ramo_despatado.id_persona = persona.id_persona
and not exists
(
	select *
	from #ramos_devueltos
	where #ramos_devueltos.id_ramo_despatado = ramo_despatado.id_ramo_despatado
	and #ramos_devueltos.ramo_real is null
)

alter table #ramo
add id_punto_corte int

update #ramo
set id_punto_corte = punto_corte.id_punto_corte
from punto_corte,
ramo
where ramo.id_punto_corte = punto_corte.id_punto_corte
and ramo.idc_ramo = #ramo.idc_ramo_despatado
and #ramo.tallos_por_ramo <> 12

update #ramo
set id_punto_corte = punto_corte.id_punto_corte
from ramo_comprado,
finca,
finca_asignada,
etiqueta_impresa_finca_asignada,
punto_corte
where ramo_comprado.id_punto_corte = punto_corte.id_punto_corte
and finca.id_finca = finca_asignada.id_finca
and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada
and ramo_comprado.idc_ramo_comprado = #ramo.idc_ramo_despatado
and #ramo.tallos_por_ramo <> 12
and finca.idc_finca <> 'ZX'

update #ramo
set id_punto_corte = 999
from ramo_comprado,
finca,
finca_asignada,
etiqueta_impresa_finca_asignada
where finca.id_finca = finca_asignada.id_finca
and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada
and ramo_comprado.idc_ramo_comprado = #ramo.idc_ramo_despatado
and #ramo.tallos_por_ramo <> 12
and finca.idc_finca = 'ZX'

select persona.idc_persona,
ltrim(rtrim(persona.nombre)) as nombre_persona,
ltrim(rtrim(persona.apellido)) as apellido_persona,
#ramo.idc_ramo_despatado,
#ramo.fecha_lectura,
#ramo.tallos_por_ramo
from #ramo,
persona
where id_punto_corte is null
and #ramo.id_persona = persona.id_persona
and tallos_por_ramo <> 12
order by nombre_persona,
apellido_persona,
#ramo.idc_ramo_despatado

drop table #ramo
drop table #ramos_devueltos