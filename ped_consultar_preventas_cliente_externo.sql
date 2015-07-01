set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ped_consultar_preventas_cliente_externo]

@numero_reporte_farm int, 
@id_temporada_año int,
@id_farm int

AS
BEGIN

declare @dias_atras integer, 
@id_tipo_despacho integer, 
@tipo_orden_nueva nvarchar(255), 
@tipo_orden_cancelada nvarchar(255), 
@idc_tipo_factura_doble nvarchar(255), 
@id_reporte_cambio_orden_pedido integer, 
@id_tipo_factura integer,
@id_tipo_factura_doble integer,
@id_tipo_despacho_corrimiento integer, 
@id_tipo_despacho_despacho integer,
@nombre_preventa nvarchar(255),
@nombre_doble nvarchar(255),
@tipo_factura_corrimiento nvarchar(255),
@idc_tipo_factura nvarchar(255)

set @idc_tipo_factura_doble = '7'
select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
select @id_tipo_factura = id_tipo_factura from tipo_factura where idc_tipo_factura = @idc_tipo_factura
select @id_tipo_factura_doble = id_tipo_factura from tipo_factura where idc_tipo_factura = @idc_tipo_factura_doble
set @tipo_orden_nueva = 'Nuevo'
set @tipo_orden_cancelada = 'Cancelado'
set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3
set @nombre_preventa = 'Preventa'
set @nombre_doble = 'Doblaje'
set @idc_tipo_factura = '4'

declare @id_reporte_cambio_orden_pedido_doble int,
@dias_atras_preventas int, 
@corrimiento_preventa_activo bit

select @id_reporte_cambio_orden_pedido = id_reporte_cambio_orden_pedido 
from reporte_cambio_orden_pedido 
where numero_reporte_farm = @numero_reporte_farm 
and id_farm = @id_farm 
and id_tipo_factura = @id_tipo_factura
and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año

select @id_reporte_cambio_orden_pedido_doble = id_reporte_cambio_orden_pedido 
from reporte_cambio_orden_pedido 
where reporte_cambio_orden_pedido.numero_reporte_farm = @numero_reporte_farm 
and reporte_cambio_orden_pedido.id_farm = @id_farm 
and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura_doble
and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año

/*hallar la cantidad de días atras estipulados para las preventas y los doblajes*/
select @dias_atras_preventas = cantidad_dias_despacho_finca_preventa,
@corrimiento_preventa_activo = corrimiento_preventa_activo 
from configuracion_bd

/*seleccionar las ordenes desde Item_Reporte_Cambio_Orden_Pedido ingresados anteriormente*/
select 
item_reporte_cambio_orden_pedido.id_orden_pedido,
item_reporte_cambio_orden_pedido.idc_orden_pedido,
item_reporte_cambio_orden_pedido.id_orden_pedido_padre,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.nombre_abreviado_tipo_caja,
item_reporte_cambio_orden_pedido.code, 
item_reporte_cambio_orden_pedido.unidades_por_pieza, 
item_reporte_cambio_orden_pedido.cantidad_piezas,
item_reporte_cambio_orden_pedido.comentario,
ciudad.id_ciudad,
datepart(dw,item_reporte_cambio_orden_pedido.fecha_despacho_inicial - @dias_atras - @dias_atras_preventas - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido.fecha_transaccion,
reporte_cambio_orden_pedido.numero_reporte_farm,
farm.nombre_farm,
farm.id_farm,
farm.idc_farm,
reporte_cambio_orden_pedido.comentario as comentario_general,
item_reporte_cambio_orden_pedido.disponible,
item_reporte_cambio_orden_pedido.fecha_despacho_inicial,
tipo_factura.idc_tipo_factura into #temp_pb
from item_reporte_cambio_orden_pedido, 
reporte_cambio_orden_pedido,
farm, 
tipo_flor,
variedad_flor, 
grado_flor,
tapa,
tipo_caja,
ciudad,
tipo_factura
where 
item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and farm.id_farm = reporte_cambio_orden_pedido.id_farm
and reporte_cambio_orden_pedido.id_farm = @id_farm
and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
and farm.id_ciudad = ciudad.id_ciudad
and (reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = @id_reporte_cambio_orden_pedido or reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = @id_reporte_cambio_orden_pedido_doble)
and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and (tipo_factura.id_tipo_factura = @id_tipo_factura or tipo_factura.id_tipo_factura = @id_tipo_factura_doble)

/*********************************************************************************************************/
/*********************************************************************************************************/
/*****************************************Tabla #temp_pb**************************************************/
/**********************************ordenes traídas desde Orden_Pedido*************************************/
/*********************************************************************************************************/
/*********************************************************************************************************/

/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
alter table #temp_pb
add id_tipo_despacho int, 
id_tipo_despacho_aux int, 
corrimiento bit, 
nombre_dia_despacho nvarchar(255), 
forma_despacho int

/*los corrimientos para las preventas NO están habilitados?*/
if(@corrimiento_preventa_activo = 0)
	set @tipo_factura_corrimiento = 'all'
else 
/*los corrimientos para las preventas están habilitados?*/
if(@corrimiento_preventa_activo = 1)
	set @tipo_factura_corrimiento = '4'

/*traer datos para los corrimientos de ordenes fijas por finca*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 1
from tipo_despacho, 
#temp_pb, 
forma_despacho_farm, 
dia_despacho, 
farm,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and forma_despacho_farm.id_farm = #temp_pb.id_farm
and forma_despacho_farm.id_farm = farm.id_farm
and forma_despacho_farm.id_dia_despacho = #temp_pb.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*traer datos para los corrimientos de ordenes fijas por ciudad*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 0
from tipo_despacho, 
#temp_pb, 
forma_despacho_ciudad, 
dia_despacho, 
ciudad,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and forma_despacho_ciudad.id_ciudad = #temp_pb.id_ciudad
and forma_despacho_ciudad.id_ciudad = ciudad.id_ciudad
and forma_despacho_ciudad.id_dia_despacho = #temp_pb.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and #temp_pb.forma_despacho is null
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*asignar el día a las ordenes que no presentan corrimiento por finca ni ciudad*/
update #temp_pb
set nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 2,
id_tipo_despacho = 2,
id_tipo_despacho_aux = 2
from #temp_pb, 
dia_despacho
where #temp_pb.id_dia_despacho = dia_despacho.id_dia_despacho	
and #temp_pb.forma_despacho is null

/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*********************CORRIMIENTOS POR CIUDAD*********************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*aumentar un dia a las ordenes*/
update #temp_pb
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 0

/*actualizar el día de despacho después del aumento de día del punto anterior*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_ciudad, 
#temp_pb,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and #temp_pb.id_ciudad = forma_despacho_ciudad.id_ciudad
and #temp_pb.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 0
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
update #temp_pb
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 0

update #temp_pb
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 0

/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp_pb where forma_despacho = 0))
begin
	update #temp_pb
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	update #temp_pb
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	#temp_pb,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp_pb.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp_pb.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 0
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
end

/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*********************CORRIMIENTOS POR FINCA**********************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*aumentar un dia a las ordenes*/
update #temp_pb
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 1

/*actualizar el día de despacho después del aumento de día del punto anterior*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_farm, 
#temp_pb,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and #temp_pb.id_farm = forma_despacho_farm.id_farm
and #temp_pb.id_dia_despacho = forma_despacho_farm.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 1
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
update #temp_pb
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho - 1, 0, 7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 1

update #temp_pb
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 1

/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp_pb where forma_despacho = 1))
begin
	update #temp_pb
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	update #temp_pb
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	#temp_pb,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp_pb.id_farm = forma_despacho_farm.id_farm
	and #temp_pb.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
end

/*alterar tabla temporal para incluir el tipo de orden (cancelaciones o adiciones)*/
alter table #temp_pb
add tipo_orden nvarchar(255)

/*volver negativas las piezas cuando se trate de cancelaciones junto con la descripción de esta orden (cancelación) */
update #temp_pb
set cantidad_piezas = cantidad_piezas * -1,
tipo_orden = @tipo_orden_cancelada
where disponible = 0

/*cambiar la semana de la orden según la fecha que presenta y el dia de despacho hallado*/
update #temp_pb
set fecha_despacho_inicial = fecha_despacho_inicial - 7
where datepart(dw,fecha_despacho_inicial) = id_dia_despacho

update #temp_pb
set fecha_despacho_inicial = fecha_despacho_inicial-(datepart(dw,fecha_despacho_inicial) - id_dia_despacho)
where datepart(dw,fecha_despacho_inicial) > id_dia_despacho

update #temp_pb
set fecha_despacho_inicial = fecha_despacho_inicial-(datepart(dw,fecha_despacho_inicial) - id_dia_despacho + 7)
where datepart(dw,fecha_despacho_inicial) < id_dia_despacho

/*insercion de registros en una nueva tabla temporal para poder realizar el agrupamiento y la suma de la cantidad de piezas*/
select idc_farm as FARM,
'PB' as "ORDER TYPE",
null as CUSTOMER,
null as LOCATION,
code as MARK,
fecha_despacho_inicial as "MIAMI SHIP DATE",
ltrim(rtrim(nombre_tipo_flor )) + space(1) + ltrim(rtrim(nombre_variedad_flor)) as BOUQUET,
ltrim(rtrim(nombre_tipo_flor )) AS TYPE,
ltrim(rtrim(nombre_grado_flor)) as GRADE,
nombre_abreviado_tipo_caja as "BOX TYPE",
cantidad_piezas as PIECES,
unidades_por_pieza as PACK,
'NO' as "DECO SLEEVE",
null as UPC,
null as "C D",
null as "UPC PRICE",
null as "UPC DATE",
null as "MIAMI PRICE",
nombre_tapa as LID,
'NO' as FOOD,
comentario as NOTES
from #temp_pb 
where cantidad_piezas <> 0
order by 
idc_tipo_factura,
fecha_despacho_inicial,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
code,
nombre_tapa,
nombre_tipo_caja,
unidades_por_pieza,
cantidad_piezas

/*eliminación tablas temporales*/
drop table #temp_pb

END