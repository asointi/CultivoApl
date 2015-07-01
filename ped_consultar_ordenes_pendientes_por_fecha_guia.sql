set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ped_consultar_ordenes_pendientes_por_fecha_guia]

@fecha_guia_inicial datetime,
@fecha_guia_final datetime,
@idc_farm_inicial nvarchar(255),
@idc_farm_final nvarchar(255)

AS

set language spanish

declare @dias_atras integer, 
@id_tipo_despacho integer,
@id_tipo_despacho_corrimiento integer, 
@id_tipo_despacho_despacho integer,
@idc_tipo_factura_doble nvarchar(255),
@nombre_preventa nvarchar(255),
@nombre_doble nvarchar(255),
@nombre_so nvarchar(255),
@tipo_factura_corrimiento nvarchar(255),
@idc_tipo_factura_so nvarchar(255),
@idc_tipo_factura_pr nvarchar(255)

select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3
set @nombre_preventa = 'Preventa'
set @nombre_doble = 'Doblaje'
set @nombre_so = 'SO'
set @idc_tipo_factura_so = '9'
set @idc_tipo_factura_pr = '4'
set @idc_tipo_factura_doble = '7'

set @tipo_factura_corrimiento = 'all'

/*seleccionar las ordenes desde Orden_Pedido en el rango de fechas solicitado*/
select 
Orden_Pedido.id_orden_pedido,
Orden_Pedido.id_orden_pedido_padre,
Orden_Pedido.idc_orden_pedido,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
variedad_flor.id_variedad_flor,
grado_flor.nombre_grado_flor,
grado_flor.id_grado_flor,
tapa.nombre_tapa,
tapa.id_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.id_tipo_caja,
orden_pedido.fecha_inicial, 
orden_pedido.fecha_final, 
orden_pedido.marca, 
orden_pedido.unidades_por_pieza, 
orden_pedido.cantidad_piezas,
orden_pedido.comentario,
ciudad.id_ciudad,
datepart(dw,orden_pedido.fecha_inicial -@dias_atras-farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
orden_pedido.disponible,
farm.id_farm,
farm.nombre_farm,
farm.idc_farm,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
vendedor.id_vendedor,
vendedor.idc_vendedor into #temp
from Orden_Pedido, 
farm, 
tipo_flor,
variedad_flor, 
grado_flor,
tapa,
tipo_caja,
ciudad,
tipo_factura,
cliente_despacho,
vendedor
where Orden_Pedido.fecha_final > @fecha_guia_inicial
and farm.id_farm = Orden_Pedido.id_farm
and farm.idc_farm > = @idc_farm_inicial and farm.idc_farm < = @idc_farm_final
and farm.id_ciudad = ciudad.id_ciudad
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @idc_tipo_factura_so
and orden_pedido.disponible = 1
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and vendedor.id_vendedor = orden_pedido.id_vendedor
and orden_pedido.fecha_inicial < orden_pedido.fecha_final
and orden_pedido.id_orden_pedido in
(select max(id_orden_pedido) 
from orden_pedido, farm
where orden_pedido.id_farm = farm.id_farm
and farm.idc_farm > = @idc_farm_inicial and farm.idc_farm < = @idc_farm_final
group by id_orden_pedido_padre)

/*********************************************************************************************************/
/*********************************************************************************************************/
/*****************************************Tabla #temp*****************************************************/
/**********************************ordenes traídas desde Orden_Pedido*************************************/
/*********************************************************************************************************/
/*********************************************************************************************************/

/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
alter table #temp
add id_tipo_despacho int, 
id_tipo_despacho_aux int, 
corrimiento bit, 
nombre_dia_despacho nvarchar(255), 
forma_despacho int

/*traer datos para los corrimientos de ordenes fijas por finca*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 1
from tipo_despacho, 
#temp, 
forma_despacho_farm, 
dia_despacho,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and forma_despacho_farm.id_farm = #temp.id_farm
and forma_despacho_farm.id_dia_despacho = #temp.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*traer datos para los corrimientos de ordenes fijas por ciudad*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 0
from tipo_despacho, 
#temp, 
forma_despacho_ciudad, 
dia_despacho,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and forma_despacho_ciudad.id_ciudad = #temp.id_ciudad
and forma_despacho_ciudad.id_dia_despacho = #temp.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and #temp.forma_despacho is null
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento


/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*********************CORRIMIENTOS POR CIUDAD*********************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*aumentar un dia a las ordenes*/
update #temp
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 0

/*actualizar el día de despacho después del aumento de día del punto anterior*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_ciudad, 
#temp,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 0
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
update #temp
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 0

update #temp
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 0

/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 0))
begin
	update #temp
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	#temp,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
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
update #temp
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 1

/*actualizar el día de despacho después del aumento de día del punto anterior*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_farm, 
#temp,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and #temp.id_farm = forma_despacho_farm.id_farm
and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 1
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
update #temp
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 1

update #temp
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 1

/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 1))
begin
	update #temp
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	#temp,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp.id_farm = forma_despacho_farm.id_farm
	and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
end

/*hallar la cantidad de días atras estipulados para las preventas y los doblajes*/
declare @dias_atras_preventas int, 
@corrimiento_preventa_activo bit

select @dias_atras_preventas = cantidad_dias_despacho_finca_preventa,
@corrimiento_preventa_activo = corrimiento_preventa_activo 
from configuracion_bd

/*seleccionar las ordenes desde Orden_Pedido en el rango de fechas solicitado*/
select 
Orden_Pedido.id_orden_pedido,
Orden_Pedido.id_orden_pedido_padre,
Orden_Pedido.idc_orden_pedido,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
variedad_flor.id_variedad_flor,
grado_flor.nombre_grado_flor,
grado_flor.id_grado_flor,
tapa.nombre_tapa,
tapa.id_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.id_tipo_caja,
orden_pedido.fecha_inicial, 
orden_pedido.fecha_final, 
orden_pedido.marca, 
orden_pedido.unidades_por_pieza, 
orden_pedido.cantidad_piezas,
orden_pedido.comentario,
ciudad.id_ciudad,
datepart(dw,orden_pedido.fecha_inicial -@dias_atras-@dias_atras_preventas-farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
orden_pedido.disponible,
farm.id_farm,
farm.nombre_farm,
farm.idc_farm,
tipo_factura.idc_tipo_factura,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
vendedor.id_vendedor,
vendedor.idc_vendedor into #temp_pb
from Orden_Pedido, 
farm, 
tipo_flor,
variedad_flor, 
grado_flor,
tapa,
tipo_caja,
ciudad,
tipo_factura,
cliente_despacho,
vendedor
where Orden_Pedido.fecha_inicial > @fecha_guia_inicial
and farm.id_farm = Orden_Pedido.id_farm
and farm.idc_farm > = @idc_farm_inicial and farm.idc_farm < = @idc_farm_final
and farm.id_ciudad = ciudad.id_ciudad
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and (tipo_factura.idc_tipo_factura = @idc_tipo_factura_pr or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
and orden_pedido.disponible = 1
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and orden_pedido.id_vendedor = vendedor.id_vendedor
and orden_pedido.fecha_inicial = orden_pedido.fecha_final
and orden_pedido.id_orden_pedido in
(select max(id_orden_pedido) 
from orden_pedido, farm
where orden_pedido.id_farm = farm.id_farm
and farm.idc_farm > = @idc_farm_inicial and farm.idc_farm < = @idc_farm_final 
group by id_orden_pedido_padre)


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

/*traer datos para los corrimientos de ordenes por finca*/
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

/*traer datos para los corrimientos de ordenes por ciudad*/
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
id_dia_despacho = replace(id_dia_despacho-1,0,7)
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

/**procedimientos para calcular la fecha de vuelo**/
update #temp_pb
set fecha_inicial = fecha_inicial-7
where datepart(dw,fecha_inicial) = id_dia_despacho

update #temp_pb
set fecha_inicial = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho)
where datepart(dw,fecha_inicial) > id_dia_despacho

update #temp_pb
set fecha_inicial = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho + 7)
where datepart(dw,fecha_inicial) < id_dia_despacho

delete from #temp_pb
where idc_cliente_despacho in ('Z012','Z018','Z028','Z505','Z506')


declare @count int

create table #dias 
(id_dia int)
insert into #dias (id_dia)
values (datepart(dw, @fecha_guia_inicial))

set @count = 1
while (@count < = datediff(dd, @fecha_guia_inicial, @fecha_guia_final))
begin
	insert into #dias (id_dia)
	values (datepart(dw, @fecha_guia_inicial + @count))
	set @count = @count + 1
end

/**datos para ser visualizados por los usuarios**/
select 
@nombre_so as tipo_factura,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
nombre_tipo_caja,
nombre_dia_despacho,
marca as code, 
unidades_por_pieza, 
sum(cantidad_piezas) as cantidad_piezas,
rtrim(comentario) as comentario,
id_farm,
nombre_farm,
idc_farm
from #temp
where id_dia_despacho in (select id_dia from #dias)
group by 
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
nombre_tipo_caja,
nombre_dia_despacho,
marca, 
unidades_por_pieza, 
rtrim(comentario),
id_farm,
nombre_farm,
idc_farm
union
select 
replace(Replace(idc_tipo_factura, @idc_tipo_factura_pr,@nombre_preventa),@idc_tipo_factura_doble,@nombre_doble) as tipo_factura,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
nombre_tipo_caja,
nombre_dia_despacho,
marca as code, 
unidades_por_pieza, 
sum(cantidad_piezas) as cantidad_piezas,
rtrim(comentario) as comentario,
id_farm,
nombre_farm,
idc_farm
from #temp_pb 
where fecha_inicial between
@fecha_guia_inicial and @fecha_guia_final
group by 
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
nombre_tipo_caja,
nombre_dia_despacho,
marca, 
unidades_por_pieza, 
rtrim(comentario),
id_farm,
nombre_farm,
idc_farm,
idc_tipo_factura
order by 
tipo_factura,
idc_farm,
nombre_farm,
nombre_dia_despacho,	
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
code,
nombre_tapa,
nombre_tipo_caja,
unidades_por_pieza,
cantidad_piezas

/*eliminación tablas temporales*/
drop table #temp
drop table #temp_pb
drop table #dias


