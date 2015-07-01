USE [BD_Nf]
GO
/****** Object:  StoredProcedure [dbo].[inv_consultar_inventario_disponible]    Script Date: 11/30/2007 15:20:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[inv_consultar_inventario_disponible]

@id_cliente_corporativo integer

AS

declare @cantidad_dias_atras_inventario integer, 
@id_estado_pieza integer,
@porcentaje_minimo_inventario decimal(20,4),
@porcentaje_maximo_inventario decimal(20,4),
@cantidad_piezas_maximas integer,
@cantidad_piezas_intermedia integer,
@cantidad_piezas_fijas integer,
@idc_cliente_corporativo nvarchar(255),
@id_cliente_factura integer

select @idc_cliente_corporativo = idc_cliente_corporativo from cliente_corporativo where id_cliente_corporativo = @id_cliente_corporativo
select @id_cliente_factura = id_cliente_factura from cliente_factura where idc_cliente_factura = @idc_cliente_corporativo
select @id_estado_pieza = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Open Market'
select @cantidad_dias_atras_inventario = cantidad_dias_atras_inventario from bd_nf.dbo.configuracion_bd
select @porcentaje_minimo_inventario = inv_porcentaje_minimo_inventario from configuracion_bd
select @porcentaje_maximo_inventario = inv_porcentaje_maximo_inventario from configuracion_bd
select @cantidad_piezas_maximas = inv_cantidad_piezas_maximas from configuracion_bd
select @cantidad_piezas_intermedia = inv_cantidad_piezas_intermedia from configuracion_bd
select @cantidad_piezas_fijas = inv_cantidad_fija_piezas from configuracion_bd
/***************************************************************/
/*extractar inventario superior a 1 pieza*/
select 
bd_nf.dbo.variedad_flor.id_variedad_flor,
bd_nf.dbo.grado_flor.id_grado_flor,
bd_nf.dbo.farm.id_farm,
bd_nf.dbo.tapa.id_tapa,
bd_nf.dbo.caja.id_caja,
bd_nf.dbo.pieza.marca as code,
bd_nf.dbo.tipo_flor.idc_tipo_flor+bd_nf.dbo.variedad_flor.idc_variedad_flor+bd_nf.dbo.grado_flor.idc_grado_flor as codigo_flor,
rtrim(ltrim(bd_nf.dbo.tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(bd_nf.dbo.variedad_flor.nombre_variedad_flor)) as nombre_flor,
bd_nf.dbo.farm.idc_farm,
bd_nf.dbo.tipo_caja.nombre_abreviado_tipo_caja,
bd_nf.dbo.variedad_flor.idc_variedad_flor,
bd_nf.dbo.grado_flor.nombre_grado_flor,
bd_nf.dbo.color.idc_color,
bd_nf.dbo.tipo_flor.nombre_tipo_flor,
bd_nf.dbo.caja.medida_largo,
bd_nf.dbo.caja.medida_ancho,
bd_nf.dbo.caja.medida_alto,
bd_nf.dbo.pieza.unidades_por_pieza,
count(bd_nf.dbo.pieza.id_pieza) as piezas_disponibles,
sum(bd_nf.dbo.tipo_caja.factor_a_full) as "full" into #inventario
from bd_nf.dbo.pieza, 
bd_nf.dbo.tipo_flor,
bd_nf.dbo.variedad_flor,
bd_nf.dbo.grado_flor,
bd_nf.dbo.farm,
bd_nf.dbo.tipo_caja,
bd_nf.dbo.caja, 
bd_nf.dbo.color, 
bd_nf.dbo.tapa,
bd_nf.dbo.estado_pieza
where bd_nf.dbo.pieza.id_estado_pieza = bd_nf.dbo.estado_pieza.id_estado_pieza
and bd_nf.dbo.estado_pieza.id_estado_pieza = @id_estado_pieza
and bd_nf.dbo.pieza.disponible = 1
and bd_nf.dbo.pieza.id_variedad_flor = bd_nf.dbo.variedad_flor.id_variedad_flor
and bd_nf.dbo.tipo_flor.id_tipo_flor = bd_nf.dbo.variedad_flor.id_tipo_flor
and bd_nf.dbo.pieza.id_grado_flor = bd_nf.dbo.grado_flor.id_grado_flor
and bd_nf.dbo.tipo_flor.id_tipo_flor = bd_nf.dbo.grado_flor.id_tipo_flor
and bd_nf.dbo.pieza.id_farm = bd_nf.dbo.farm.id_farm
and bd_nf.dbo.pieza.id_caja = bd_nf.dbo.caja.id_caja
and bd_nf.dbo.caja.id_tipo_caja = bd_nf.dbo.tipo_caja.id_tipo_caja
and bd_nf.dbo.variedad_flor.id_color = bd_nf.dbo.color.id_color
and bd_nf.dbo.pieza.id_tapa = bd_nf.dbo.tapa.id_tapa
group by 
bd_nf.dbo.variedad_flor.id_variedad_flor,
bd_nf.dbo.grado_flor.id_grado_flor,
bd_nf.dbo.farm.id_farm,
bd_nf.dbo.tapa.id_tapa,
bd_nf.dbo.caja.id_caja,
bd_nf.dbo.pieza.marca,
bd_nf.dbo.tipo_flor.idc_tipo_flor+bd_nf.dbo.variedad_flor.idc_variedad_flor+bd_nf.dbo.grado_flor.idc_grado_flor,
rtrim(ltrim(bd_nf.dbo.tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(bd_nf.dbo.variedad_flor.nombre_variedad_flor)),
bd_nf.dbo.farm.idc_farm,
bd_nf.dbo.tipo_caja.nombre_abreviado_tipo_caja,
bd_nf.dbo.variedad_flor.idc_variedad_flor,
bd_nf.dbo.grado_flor.nombre_grado_flor,
bd_nf.dbo.color.idc_color,
bd_nf.dbo.tipo_flor.nombre_tipo_flor,
bd_nf.dbo.caja.medida_largo,
bd_nf.dbo.caja.medida_ancho,
bd_nf.dbo.caja.medida_alto,
bd_nf.dbo.pieza.unidades_por_pieza
having 
count(bd_nf.dbo.pieza.id_pieza) > 1
/***************************************************************/
/*modificar tabla temporal para incluir el dato de minimos*/
alter table #inventario
add cantidad_piezas_minimas decimal(20,4), maximos_mes integer, maximos_semana integer, minimo_maximo integer, piezas_total integer, tiene_precio bit, precio decimal(20,4)
/***************************************************************/
/*hallar el valor de las piezas multiplicado el porcentaje parametrizado*/
update #inventario
set cantidad_piezas_minimas = convert(int,piezas_disponibles * (@porcentaje_minimo_inventario/100))
/*colocar el valor de las piezas hasta el valor máximo de los minimos*/
if(@cantidad_piezas_maximas in (select cantidad_piezas_minimas from #inventario))
begin
	update #inventario
	set cantidad_piezas_minimas = @cantidad_piezas_maximas
	where cantidad_piezas_minimas > @cantidad_piezas_maximas
end
/*colocar el valor de las piezas hasta el valor intermedio cuando el valor sea 0*/
if(@cantidad_piezas_intermedia - 1 in (select cantidad_piezas_minimas from #inventario))
begin
	update #inventario
	set cantidad_piezas_minimas = @cantidad_piezas_intermedia
	where cantidad_piezas_minimas < @cantidad_piezas_maximas
end
/*colocar el valor de las piezas hasta el valor intermedio cuando el valor sea 1*/
if(@cantidad_piezas_intermedia in (select cantidad_piezas_minimas from #inventario))
begin
	update #inventario
	set cantidad_piezas_minimas = @cantidad_piezas_intermedia
	where cantidad_piezas_minimas < @cantidad_piezas_maximas
end 

/***********************************************************************************/
/*HALLAR MAXIMOS MES ANTERIOR*/
select tipo_flor.id_tipo_flor, count(pieza.id_pieza) as cantidad_piezas into #mes_anterior_parcial
from factura, 
cliente_despacho,
item_factura,
detalle_item_factura,
pieza,
variedad_flor, 
grado_flor, 
tipo_flor
where cliente_despacho.id_despacho in
(
select cliente_despacho.id_despacho 
from cliente_corporativo, cliente_corporativo_cliente_despacho, cliente_despacho
where cliente_despacho.id_despacho = cliente_corporativo_cliente_despacho.id_despacho
and cliente_corporativo.id_cliente_corporativo = cliente_corporativo_cliente_despacho.id_cliente_corporativo
and cliente_corporativo.idc_cliente_corporativo = @idc_cliente_corporativo
)
and cliente_despacho.id_despacho = factura.id_despacho
and factura.id_factura = item_factura.id_factura
and detalle_item_factura.id_item_factura = item_factura.id_item_factura
and detalle_item_factura.id_pieza = pieza.id_pieza
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and datepart(yy,factura.fecha_factura) = datepart(yy,dateadd(mm,-1,getdate()))
and datepart(mm,factura.fecha_factura) = datepart(mm,dateadd(mm,-1,getdate()))
group by tipo_flor.id_tipo_flor
------------------------------------------------
select tipo_flor.id_tipo_flor, count(pieza.id_pieza) as cantidad_piezas into #mes_anterior_total
from factura, 
item_factura,
detalle_item_factura,
pieza,
variedad_flor, 
grado_flor, 
tipo_flor
where tipo_flor.id_tipo_flor in
(
select id_tipo_flor from #mes_anterior_parcial
)
and factura.id_factura = item_factura.id_factura
and detalle_item_factura.id_item_factura = item_factura.id_item_factura
and detalle_item_factura.id_pieza = pieza.id_pieza
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and datepart(yy,factura.fecha_factura) = datepart(yy,dateadd(mm,-1,getdate()))
and datepart(mm,factura.fecha_factura) = datepart(mm,dateadd(mm,-1,getdate()))
group by tipo_flor.id_tipo_flor

-------------
alter table #mes_anterior_parcial
add porcentaje decimal(20,4)

update #mes_anterior_parcial
set porcentaje = (convert(decimal(20,4),100)/convert(decimal(20,4),#mes_anterior_total.cantidad_piezas))*convert(decimal(20,4),#mes_anterior_parcial.cantidad_piezas)
from #mes_anterior_parcial, #mes_anterior_total
where #mes_anterior_parcial.id_tipo_flor = #mes_anterior_total.id_tipo_flor

/*piezas vendidas la semana anterior*/
select variedad_flor.id_variedad_flor, convert(int,ROUND( count(pieza.id_pieza)* (@porcentaje_maximo_inventario/100+1), 0))  as cantidad_piezas into #semana_anterior
from factura, 
cliente_despacho,
item_factura,
detalle_item_factura,
pieza,
variedad_flor, 
grado_flor, 
tipo_flor
where cliente_despacho.id_despacho in
(
select cliente_despacho.id_despacho 
from cliente_corporativo, cliente_corporativo_cliente_despacho, cliente_despacho
where cliente_despacho.id_despacho = cliente_corporativo_cliente_despacho.id_despacho
and cliente_corporativo.id_cliente_corporativo = cliente_corporativo_cliente_despacho.id_cliente_corporativo
and cliente_corporativo.idc_cliente_corporativo = @idc_cliente_corporativo
)
and cliente_despacho.id_despacho = factura.id_despacho
and factura.id_factura = item_factura.id_factura
and detalle_item_factura.id_item_factura = item_factura.id_item_factura
and detalle_item_factura.id_pieza = pieza.id_pieza
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and datepart(yy,factura.fecha_factura) = datepart(yy,dateadd(ww,-1,getdate()))
and datepart(ww,factura.fecha_factura) = datepart(ww,dateadd(ww,-1,getdate()))
group by variedad_flor.id_variedad_flor

/*incluir variedades q no se vendieron la semana anterior pero q aparecen en el inventario actual*/
insert into #semana_anterior (id_variedad_flor, cantidad_piezas)
select id_variedad_flor, @cantidad_piezas_fijas from #inventario
where id_variedad_flor not in (select id_variedad_flor from #semana_anterior)
group by id_variedad_flor

/*hallar la cantidad de piezas disponibles por el porcentaje de participación en ventas del mes anterior por tipo de flor*/

update #inventario
set maximos_mes = convert(int,ROUND(piezas_disponibles * #mes_anterior_parcial.porcentaje, 0)) 
from #mes_anterior_parcial, #inventario, variedad_flor
where variedad_flor.id_variedad_flor = #inventario.id_variedad_flor
and variedad_flor.id_tipo_flor = #mes_anterior_parcial.id_tipo_flor
---
update #inventario
set maximos_mes = 0
where maximos_mes is null

/*incluir la cantidad de piezas segun las ventas de la semana anterior*/
update #inventario
set maximos_semana = #semana_anterior.cantidad_piezas
from #semana_anterior, #inventario
where #inventario.id_variedad_flor = #semana_anterior.id_variedad_flor
----
/*hallar la menor cantidad entre los maximos de la semana y los maximos del mes*/
update #inventario
set minimo_maximo = maximos_mes
where maximos_mes < maximos_semana
----
update #inventario
set minimo_maximo = maximos_semana
where maximos_semana < maximos_mes
----
update #inventario
set minimo_maximo = maximos_semana
where minimo_maximo is null
/**/
update #inventario
set piezas_total = minimo_maximo
where minimo_maximo > cantidad_piezas_minimas
----
update #inventario
set piezas_total = cantidad_piezas_minimas
where cantidad_piezas_minimas > minimo_maximo
----
update #inventario
set piezas_total = cantidad_piezas_minimas
where piezas_total is null

/*verificar cuales composiciones de piezas tienen precio*/
update #inventario
set tiene_precio = 1
from bd_nf.dbo.valor_producto, #inventario
where bd_nf.dbo.valor_producto.id_caja = #inventario.id_caja
and bd_nf.dbo.valor_producto.id_farm = #inventario.id_farm
and bd_nf.dbo.valor_producto.id_tapa = #inventario.id_tapa
and bd_nf.dbo.valor_producto.id_variedad_flor = #inventario.id_variedad_flor
and bd_nf.dbo.valor_producto.id_grado_flor = #inventario.id_grado_flor
and bd_nf.dbo.valor_producto.code = #inventario.code
and bd_nf.dbo.valor_producto.unidades_por_pieza = #inventario.unidades_por_pieza
and convert(datetime,convert(nvarchar,bd_nf.dbo.valor_producto.fecha_disponible_precio,101),101) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101),101)
--
update #inventario
set tiene_precio = 0
where tiene_precio is null
/*darle un precio alto a las piezas q no tienen precio*/
update #inventario
set precio = 999.9999
where tiene_precio = 0

/*calcular las composiciones d piezas con sus respectivos precios maximos vigentes*/
select id_variedad_flor,id_grado_flor, max(precio) as precio into #precio
from bd_nf.dbo.valor_producto 
where convert(datetime,convert(nvarchar,bd_nf.dbo.valor_producto.fecha_disponible_precio,101),101) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101),101)
group by id_variedad_flor,id_grado_flor

/*actualizar el precio de cada pieza*/
update #inventario
set precio = #precio.precio
from #inventario,#precio
where #inventario.id_variedad_flor = #precio.id_variedad_flor
and #inventario.id_grado_flor = #precio.id_grado_flor
and tiene_precio = 1

update #inventario
set piezas_total = piezas_disponibles
where piezas_total > piezas_disponibles


/*enviar resultados de inventario a pantalla*/
select 
nombre_flor as "Item Description",
nombre_grado_flor as Grade,
max(replace(convert(decimal(9,3),precio),convert(decimal(9,3),999.9999),'sin precio')) as Price,
'' as "FOB Price",
'unit' as Unit,
nombre_abreviado_tipo_caja as "Box Size",
unidades_por_pieza as "Box Pack",
convert(decimal(9,3), 0.000) as "Fuel Surcharge",
sum(piezas_total) as "Qty Available" into #final
from #inventario
group by 
id_caja,
id_farm,
id_tapa,
id_variedad_flor,
id_grado_flor,
code,
nombre_flor,
nombre_grado_flor,
replace(convert(decimal(9,3),precio),convert(decimal(9,3),999.9999),'sin precio'),
nombre_abreviado_tipo_caja,
unidades_por_pieza
order by nombre_flor, nombre_grado_flor

select "Item Description", 
Grade, 
max(Price) as Price, 
"FOB Price", 
Unit, 
"Box Size", 
"Box Pack", 
"Fuel Surcharge", 
sum("Qty Available") as "Qty Available"
from #final
group by 
"Item Description", Grade, "FOB Price", Unit, "Box Size", "Box Pack", "Fuel Surcharge"

/*eliminacion de tablas temporales*/
drop table #inventario
drop table #mes_anterior_total
drop table #mes_anterior_parcial
drop table #semana_anterior
drop table #precio
drop table #final