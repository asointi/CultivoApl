set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/09/28
-- Description:	Se utiliza para grabar en la base de datos la informacion de facturacion del dia y posteriores
-- =============================================

alter PROCEDURE [dbo].[na_editar_facturacion_dia] 

@fecha datetime,
@accion nvarchar(255),
@id_facturacion_dia int,
@unidades_vendidas int,
@valor decimal(20,4),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_farm nvarchar(5)

as

declare @id_tipo_reporte int

select @id_tipo_reporte = id_tipo_reporte
from Tipo_Reporte 
where nombre_tipo_reporte = 'Comparacion Precios Unitarios'

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
	declare @conteo int,
	@id_variedad_flor int,
	@id_grado_flor int,
	@id_farm int
	
	select @conteo = count(*),
	@id_variedad_flor = variedad_flor.id_variedad_flor,
	@id_grado_flor = grado_flor.id_grado_flor,
	@id_farm = farm.id_farm
	from tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	detalle_facturacion_dia
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and farm.idc_farm = @idc_farm
	and variedad_flor.id_variedad_flor = detalle_facturacion_dia.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_facturacion_dia.id_grado_flor
	and farm.id_farm = detalle_facturacion_dia.id_farm
	and detalle_facturacion_dia.id_facturacion_dia = @id_facturacion_dia
	group by variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	farm.id_farm

	if(@conteo IS NULL)
	begin
		insert into detalle_facturacion_dia (id_facturacion_dia, id_variedad_flor, id_grado_flor, id_farm, unidades_vendidas, valor)
		select @id_facturacion_dia,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		farm.id_farm,
		@unidades_vendidas,
		@valor
		from tipo_flor,
		variedad_flor,
		grado_flor,
		farm
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and farm.idc_farm = @idc_farm
	end
	else
	begin
		update detalle_facturacion_dia
		set unidades_vendidas = @unidades_vendidas, 
		valor = @valor
		where detalle_facturacion_dia.id_variedad_flor = @id_variedad_flor 
		and detalle_facturacion_dia.id_grado_flor = @id_grado_flor
		and detalle_facturacion_dia.id_farm = @id_farm
		and detalle_facturacion_dia.id_facturacion_dia = @id_facturacion_dia
	end
end