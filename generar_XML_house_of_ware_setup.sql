/****** Object:  StoredProcedure [dbo].[generar_XML_floralship]    Script Date: 07/03/2008 11:10:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[generar_XML_house_of_ware_setup]

AS

declare @cantidad_dias_atras_inventario integer, 
@id_estado_pieza integer,
@porcentaje_minimo_inventario decimal(20,4),
@porcentaje_maximo_inventario decimal(20,4),
@cantidad_piezas_maximas integer,
@cantidad_piezas_intermedia integer,
@cantidad_piezas_fijas integer,
@nombre_grupo_cliente nvarchar(255) 

select @id_estado_pieza = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Open Market'
select @cantidad_dias_atras_inventario = cantidad_dias_atras_inventario from configuracion_bd
select @porcentaje_minimo_inventario = inv_porcentaje_minimo_inventario from configuracion_bd
select @porcentaje_maximo_inventario = inv_porcentaje_maximo_inventario from configuracion_bd
select @cantidad_piezas_maximas = inv_cantidad_piezas_maximas from configuracion_bd
select @cantidad_piezas_intermedia = inv_cantidad_piezas_intermedia from configuracion_bd
select @cantidad_piezas_fijas = inv_cantidad_fija_piezas from configuracion_bd
set @nombre_grupo_cliente = 'FLORALSHIP'
/***************************************************************/

/*extractar inventario superior a 1 pieza*/
select 
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
farm.id_farm,
tapa.id_tapa,
caja.id_caja,
pieza.marca as code,
tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+grado_flor.idc_grado_flor as codigo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(variedad_flor.nombre_variedad_flor))+space(1)+rtrim(ltrim(grado_flor.nombre_grado_flor)) as nombre_flor,
farm.idc_farm,
tipo_caja.nombre_abreviado_tipo_caja,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
grado_flor.idc_grado_flor,
color.idc_color,
color.nombre_color,
tipo_flor.nombre_tipo_flor,
tipo_flor.idc_tipo_flor,
caja.medida_largo,
caja.medida_ancho,
caja.medida_alto,
pieza.unidades_por_pieza,
estado_pieza.id_estado_pieza,
count(pieza.id_pieza) as piezas_disponibles,
sum(tipo_caja.factor_a_full) as factor_a_full into #inventario
from pieza, 
tipo_flor,
variedad_flor,
grado_flor,
farm,
tipo_caja,
caja, 
color, 
tapa,
estado_pieza
where pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and estado_pieza.id_estado_pieza = @id_estado_pieza
and pieza.disponible = 1
and pieza.tiene_marca = 0
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and pieza.id_farm = farm.id_farm
and pieza.id_caja = caja.id_caja
and caja.id_tipo_caja = tipo_caja.id_tipo_caja
and variedad_flor.id_color = color.id_color
and pieza.id_tapa = tapa.id_tapa
group by 
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
farm.id_farm,
tapa.id_tapa,
caja.id_caja,
pieza.marca,
tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+grado_flor.idc_grado_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(variedad_flor.nombre_variedad_flor))+space(1)+rtrim(ltrim(grado_flor.nombre_grado_flor)),
farm.idc_farm,
tipo_caja.nombre_abreviado_tipo_caja,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
color.idc_color,
color.nombre_color,
tipo_flor.nombre_tipo_flor,
tipo_flor.idc_tipo_flor,
caja.medida_largo,
caja.medida_ancho,
caja.medida_alto,
pieza.unidades_por_pieza,
estado_pieza.id_estado_pieza
having 
count(pieza.id_pieza) > 1
/***************************************************************/
/*modificar tabla temporal para incluir el dato de minimos*/
alter table #inventario
add cantidad_piezas_minimas decimal(20,4), 
maximos_mes int, 
maximos_semana int, 
minimo_maximo int, 
piezas_total int, 
tiene_precio bit, 
precio decimal(20,4)
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
select grupo_cliente_despacho.id_despacho
from grupo_cliente_despacho, grupo_cliente
where grupo_cliente_despacho.id_grupo_cliente = grupo_cliente.id_grupo_cliente
and grupo_cliente.nombre_grupo_cliente = @nombre_grupo_cliente
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
select grupo_cliente_despacho.id_despacho
from grupo_cliente_despacho, grupo_cliente
where grupo_cliente_despacho.id_grupo_cliente = grupo_cliente.id_grupo_cliente
and grupo_cliente.nombre_grupo_cliente = @nombre_grupo_cliente
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
from valor_producto, #inventario
where valor_producto.id_caja = #inventario.id_caja
and valor_producto.id_farm = #inventario.id_farm
and valor_producto.id_tapa = #inventario.id_tapa
and valor_producto.id_variedad_flor = #inventario.id_variedad_flor
and valor_producto.id_grado_flor = #inventario.id_grado_flor
and valor_producto.code = #inventario.code
and valor_producto.unidades_por_pieza = #inventario.unidades_por_pieza
and convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,101),101) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101),101)

/*borrar items del inventario que no tengan precio vigente*/
delete from #inventario where tiene_precio is null

/*calcular las composiciones d piezas con sus respectivos precios maximos vigentes*/
select id_variedad_flor,id_grado_flor, max(precio) as precio into #precio
from valor_producto 
where convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,101),101) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101),101)
group by id_variedad_flor,id_grado_flor

/*actualizar el precio de cada pieza*/
update #inventario
set precio = #precio.precio
from #inventario,#precio
where #inventario.id_variedad_flor = #precio.id_variedad_flor
and #inventario.id_grado_flor = #precio.id_grado_flor

update #inventario
set piezas_total = piezas_disponibles
where piezas_total > piezas_disponibles

alter table #inventario
add Fuel int

update #inventario
set Fuel = 4
from #inventario, caja, tipo_caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = #inventario.id_caja
and tipo_caja.id_tipo_caja = 1

update #inventario
set Fuel = 4
from #inventario, caja, tipo_caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = #inventario.id_caja
and tipo_caja.id_tipo_caja = 2

update #inventario
set Fuel = 4
from #inventario, caja, tipo_caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = #inventario.id_caja
and tipo_caja.id_tipo_caja = 3

update #inventario
set Fuel = 4
from #inventario, caja, tipo_caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = #inventario.id_caja
and tipo_caja.id_tipo_caja = 4

update #inventario
set Fuel = 4
from #inventario, caja, tipo_caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = #inventario.id_caja
and tipo_caja.id_tipo_caja = 6


/*grabar datos en tabla final para realizar ultimo proceso de resticción de inventario*/
select 
idc_tipo_flor+idc_variedad_flor+idc_color+idc_grado_flor as item,
idc_tipo_flor as Category,
ltrim(rtrim(nombre_tipo_flor)) as CategoryName,
idc_variedad_flor as Variety,
ltrim(rtrim(nombre_variedad_flor)) as VarietyName,
idc_color as Color,
ltrim(rtrim(nombre_color)) as ColorName,
idc_grado_flor as Grade,
ltrim(rtrim(nombre_grado_flor)) as GradeName,
'' as Picture into #setup
from #inventario
group by 
ltrim(rtrim(nombre_tipo_flor)),
ltrim(rtrim(nombre_variedad_flor)),
ltrim(rtrim(nombre_color)),
ltrim(rtrim(nombre_grado_flor)),
idc_tipo_flor,
idc_variedad_flor,
idc_color,
idc_grado_flor

/*enviar resultados de inventario a pantalla*/
select * from #setup

/*eliminacion de tablas temporales*/
drop table #setup

/*eliminacion de tablas temporales*/

drop table #inventario
drop table #mes_anterior_total
drop table #mes_anterior_parcial
drop table #semana_anterior
drop table #precio

