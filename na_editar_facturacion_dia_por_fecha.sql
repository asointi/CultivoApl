set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/09/28
-- Description:	Se utiliza para grabar en la base de datos la informacion de facturacion del dia y posteriores
-- =============================================

alter PROCEDURE [dbo].[na_editar_facturacion_dia_por_fecha] 

@fecha datetime,
@accion nvarchar(255),
@id_facturacion_dia int,
@unidades_vendidas int,
@valor decimal(20,4),
@fulles decimal(20,4)

as

declare @id_tipo_reporte int

select @id_tipo_reporte = id_tipo_reporte
from Tipo_Reporte 
where nombre_tipo_reporte = 'Comparacion Precios Por Fecha'

if(@accion = 'insertar_encabezado')
begin
	declare @id_facturacion_dia_aux int

	select @id_facturacion_dia_aux = facturacion_dia.id_facturacion_dia
	from facturacion_dia
	where fecha_facturacion_dia = @fecha
	and id_tipo_reporte = @id_tipo_reporte

	if(@id_facturacion_dia_aux is null)
	begin
		insert into facturacion_dia (fecha_facturacion_dia, id_tipo_reporte)
		values (@fecha, @id_tipo_reporte)
	
		select scope_identity() as id_facturacion_dia
	end
	else
	begin
		select @id_facturacion_dia_aux as id_facturacion_dia
	end
end
else
if(@accion = 'insertar_detalle')
begin
	declare @conteo int
	
	select @conteo = count(*)
	from detalle_facturacion_dia_por_fecha
	where detalle_facturacion_dia_por_fecha.id_facturacion_dia = @id_facturacion_dia
	and detalle_facturacion_dia_por_fecha.fecha = @fecha 
	
	if(@conteo IS NULL or @conteo = 0)
	begin
		insert into detalle_facturacion_dia_por_fecha (id_facturacion_dia, fecha, unidades_vendidas, valor, fulles)
		values (@id_facturacion_dia, @fecha, @unidades_vendidas, @valor, @fulles)
	end
	else
	begin
		update detalle_facturacion_dia_por_fecha
		set unidades_vendidas = @unidades_vendidas, 
		valor = @valor,
		fulles = @fulles
		where detalle_facturacion_dia_por_fecha.id_facturacion_dia = @id_facturacion_dia
		and detalle_facturacion_dia_por_fecha.fecha = @fecha
	end
end