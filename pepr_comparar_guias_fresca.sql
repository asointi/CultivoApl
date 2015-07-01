USE [BD_Cultivo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pepr_comparar_guias_fresca] 

@fecha_inicial datetime,
@fecha_final datetime

as

declare @idc_farm nvarchar(2),
@ambas_partes nvarchar(25),
@en_fresca nvarchar(25),
@en_cultivo nvarchar(25)

set @idc_farm = 'AM'
set @ambas_partes = 'Cuadró'
set @en_fresca = 'Sobra'
set @en_cultivo = 'Falta'

select ltrim(rtrim(guia.idc_guia)) as idc_guia,
tipo_flor.idc_tipo_flor,
Variedad_Flor.idc_variedad_flor,
Grado_Flor.idc_grado_flor,
pedido_pepr.marca,
Pedido_PEPR.unidades_por_pieza,
count(packing_list_facturado.id_packing_list_facturado) cantidad_piezas into #guias_cultivo
from guia,
packing_list,
packing_list_facturado,
etiqueta_pepr,
Pedido_PEPR,
Tipo_Flor,
Variedad_Flor,
Grado_Flor,
caja,
Tipo_Caja,
cliente_despacho
where packing_list.fecha_packing_list between
@fecha_inicial and @fecha_final
and cliente_despacho.id_cliente_despacho = pedido_pepr.id_cliente_despacho
and cliente_despacho.idc_cliente_despacho = 'NAUSFFR'
and guia.id_guia = packing_list.id_guia
and packing_list.id_packing_list = packing_list_facturado.id_packing_list
and etiqueta_pepr.id_etiqueta_pepr = packing_list_facturado.id_etiqueta_pepr
and Pedido_PEPR.id_pedido_pepr = etiqueta_pepr.id_pedido_pepr
and tipo_flor.id_tipo_flor = Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_Flor.id_tipo_flor
and Variedad_Flor.id_variedad_flor = Pedido_PEPR.id_variedad_flor
and Grado_Flor.id_grado_flor = Pedido_PEPR.id_grado_flor
and caja.id_caja = Pedido_PEPR.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
group by ltrim(rtrim(guia.idc_guia)),
tipo_flor.idc_tipo_flor,
Variedad_Flor.idc_variedad_flor,
Grado_Flor.idc_grado_flor,
pedido_pepr.marca,
Pedido_PEPR.unidades_por_pieza

select ltrim(rtrim(guia.idc_guia)) as idc_guia,
tipo_flor.idc_tipo_flor,
Variedad_Flor.idc_variedad_flor,
Grado_Flor.idc_grado_flor,
pieza.marca,
pieza.unidades_por_pieza,
count(pieza.id_pieza) cantidad_piezas into #guias_fresca
from bd_fresca.bd_fresca.dbo.guia,
bd_fresca.bd_fresca.dbo.Tipo_Flor,
bd_fresca.bd_fresca.dbo.Variedad_Flor,
bd_fresca.bd_fresca.dbo.Grado_Flor,
bd_fresca.bd_fresca.dbo.caja,
bd_fresca.bd_fresca.dbo.Tipo_Caja,
bd_fresca.bd_fresca.dbo.pieza,
bd_fresca.bd_fresca.dbo.farm
where guia.fecha_guia between
@fecha_inicial and @fecha_final
and guia.id_guia = pieza.id_guia
and farm.id_farm = pieza.id_farm
and tipo_flor.id_tipo_flor = Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_Flor.id_tipo_flor
and Variedad_Flor.id_variedad_flor = pieza.id_variedad_flor
and Grado_Flor.id_grado_flor = pieza.id_grado_flor
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and farm.idc_farm = @idc_farm
group by ltrim(rtrim(guia.idc_guia)),
tipo_flor.idc_tipo_flor,
Variedad_Flor.idc_variedad_flor,
Grado_Flor.idc_grado_flor,
pieza.marca,
pieza.unidades_por_pieza

select @ambas_partes as Tipo_Guia,
c.idc_guia,
c.idc_tipo_flor,
c.idc_variedad_flor,
c.idc_grado_flor,
c.marca,
c.unidades_por_pieza,
c.cantidad_piezas as cantidad_piezas_cultivo,
f.cantidad_piezas as cantidad_piezas_fresca,
c.cantidad_piezas - f.cantidad_piezas as diferencia
from #guias_cultivo as c,
#guias_fresca as f
where c.idc_guia = f.idc_guia
and c.idc_tipo_flor = f.idc_tipo_flor
and c.idc_variedad_flor = f.idc_variedad_flor
and c.idc_grado_flor = f.idc_grado_flor
and c.unidades_por_pieza = f.unidades_por_pieza
and c.marca = f.marca
union all
select 
case
	when 
	(
		select top 1 f.idc_guia
		from #guias_cultivo as c1
		where f.idc_guia = c1.idc_guia
	) is null then @en_fresca
	else @ambas_partes
end,
f.idc_guia,
f.idc_tipo_flor,
f.idc_variedad_flor,
f.idc_grado_flor,
f.marca,
f.unidades_por_pieza,
0,
f.cantidad_piezas,
f.cantidad_piezas * -1
from #guias_fresca as f
where not exists
(
	select *
	from #guias_cultivo as c
	where c.idc_guia = f.idc_guia
	and c.idc_tipo_flor = f.idc_tipo_flor
	and c.idc_variedad_flor = f.idc_variedad_flor
	and c.idc_grado_flor = f.idc_grado_flor
	and c.unidades_por_pieza = f.unidades_por_pieza
	and c.marca = f.marca
)
union all
select 
case
	when 
	(
		select top 1 c.idc_guia
		from #guias_fresca as f1
		where f1.idc_guia = c.idc_guia
	) is null then @en_cultivo
	else @ambas_partes
end,
c.idc_guia,
c.idc_tipo_flor,
c.idc_variedad_flor,
c.idc_grado_flor,
c.marca,
c.unidades_por_pieza,
c.cantidad_piezas,
0,
c.cantidad_piezas
from #guias_cultivo as c
where not exists
(
	select *
	from #guias_fresca as f
	where c.idc_guia = f.idc_guia
	and c.idc_tipo_flor = f.idc_tipo_flor
	and c.idc_variedad_flor = f.idc_variedad_flor
	and c.idc_grado_flor = f.idc_grado_flor
	and c.unidades_por_pieza = f.unidades_por_pieza
	and c.marca = f.marca
)
order by tipo_guia,
idc_guia,
marca,
idc_tipo_flor,
idc_variedad_flor,
idc_grado_flor,
unidades_por_pieza

drop table #guias_fresca
drop table #guias_cultivo