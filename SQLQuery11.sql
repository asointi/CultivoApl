set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_pieza_version3]

@idc_pieza nvarchar(15),
@unidades_por_pieza int,
@marca nvarchar(10),
@costo_por_unidad decimal(20,4),
@disponible bit,
@idc_tapa nvarchar(10),
@idc_caja nvarchar(10),
@idc_farm nvarchar(10),
@idc_tipo_flor nvarchar(10),
@idc_variedad_flor nvarchar(10),
@idc_grado_flor nvarchar(10),
@idc_guia nvarchar(15),
@idc_estado_pieza nvarchar(20),
@accion nvarchar(50),
@direccion_pieza int,
@idc_pedido_pepr nvarchar(50) = null,
@numero_solicitud_finca int = null,
@id_solicitud_confirmacion_Cultivo int = null

as

declare @id_pieza int

select @id_pieza = id_pieza
from pieza 
where idc_pieza = @idc_pieza

if(ltrim(rtrim(@idc_estado_pieza)) = '')
	set @idc_estado_pieza = 'vendida'

if(@accion = 'insertar')
begin
	declare @tiene_marca bit

	set @disponible = 1	
	
	select @tiene_marca = 
	case 
		when ltrim(rtrim(@marca)) = '' then 0
		else 1
	end

	insert into pieza 
	(
		idc_pieza,
		id_tapa,
		id_caja,
		id_farm,
		id_variedad_flor,
		id_grado_flor,
		id_guia,
		id_estado_pieza,
		unidades_por_pieza,
		marca,
		costo_por_unidad,
		disponible,
		tiene_marca,
		direccion_pieza,
		numero_solicitud_finca,
		id_solicitud_confirmacion_Cultivo
	)
	select @idc_pieza,
	tapa.id_tapa,
	caja.id_caja,
	farm.id_farm,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	guia.id_guia,
	estado_pieza.id_estado_pieza,
	@unidades_por_pieza,
	@marca,
	@costo_por_unidad,
	@disponible,	
	@tiene_marca,
	convert(int, replace(estado_guia.idc_estado_guia, 'A', @direccion_pieza)),
	isnull(@numero_solicitud_finca, 0),
	isnull(id_solicitud_confirmacion_Cultivo, 0)
	from tapa,
	tipo_caja,
	caja,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	guia,
	estado_pieza,
	estado_guia
	where tapa.idc_tapa = @idc_tapa
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.idc_tipo_caja = left(@idc_caja, 1)
	and caja.idc_caja = right(@idc_caja, 1)
	and farm.idc_farm = @idc_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and guia.idc_guia = @idc_guia
	and estado_pieza.idc_estado_pieza = @idc_estado_pieza
	and guia.id_estado_guia = estado_guia.id_estado_guia

	insert into direccion_pieza (id_pieza, idc_direccion_pieza)
	select pieza.id_pieza,
	pieza.direccion_pieza
	from pieza
	where idc_pieza = @idc_pieza
end
else
if(@accion = 'modificar')
begin
	update pieza
	set disponible = @disponible,
	id_estado_pieza = estado_pieza.id_estado_pieza
	from estado_pieza
	where pieza.id_pieza = @id_pieza
	and estado_pieza.idc_estado_pieza = @idc_estado_pieza

	insert into direccion_pieza (id_pieza, idc_direccion_pieza)
	select pieza.id_pieza,
	pieza.direccion_pieza
	from pieza
	where idc_pieza = @idc_pieza

	if(@disponible = 1)
	begin
		delete from Pieza_item_orden_floralship
		where id_pieza = @id_pieza
	end
end
else
if(@accion = 'modificar_disponible')
begin
	update pieza
	set disponible = @disponible
	where id_pieza = @id_pieza

	insert into direccion_pieza (id_pieza, idc_direccion_pieza)
	select pieza.id_pieza,
	pieza.direccion_pieza
	from pieza
	where idc_pieza = @idc_pieza

	if(@disponible = 1)
	begin
		delete from Pieza_item_orden_floralship
		where id_pieza = @id_pieza
	end
end
else 
if(@accion = 'modificar_costo')
begin
	update pieza
	set costo_por_unidad = @costo_por_unidad
	where id_pieza = @id_pieza

	insert into direccion_pieza (id_pieza, idc_direccion_pieza)
	select pieza.id_pieza,
	pieza.direccion_pieza
	from pieza
	where idc_pieza = @idc_pieza
end
else
if(@accion = 'eliminar')
begin
	delete from detalle_item_factura
	where id_pieza = @id_pieza

	delete from pieza
	where id_pieza = @id_pieza
end