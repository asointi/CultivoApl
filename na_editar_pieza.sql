USE [BD_Fresca];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[na_editar_pieza]

@idc_pieza nvarchar(15),
@unidades_por_pieza int,
@marca nvarchar(255),
@costo_por_unidad decimal(20,4),
@disponible bit,
@idc_tapa nvarchar(5),
@idc_caja nvarchar(5),
@idc_farm nvarchar(5),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_guia nvarchar(15),
@idc_estado_pieza nvarchar(15),
@accion nvarchar(255),
@idc_pedido_pepr int = null

as

if(ltrim(rtrim(@idc_estado_pieza)) = '')
	set @idc_estado_pieza = 'vendida'

if(@accion = 'insertar')
begin
	declare @tiene_marca bit

	set @disponible = 1	

	select @tiene_marca = tiene_marca 
	from pieza, 
	tapa, 
	caja, 
	farm,
	variedad_flor, 
	grado_flor, 
	tipo_flor, 
	estado_pieza
	where tapa.id_tapa = pieza.id_tapa
	and tapa.idc_tapa = @idc_tapa
	and caja.id_caja = pieza.id_caja
	and caja.idc_caja = @idc_caja
	and farm.id_farm = pieza.id_farm
	and farm.idc_farm = @idc_farm
	and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza.id_grado_flor = grado_flor.id_grado_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and pieza.id_estado_pieza = estado_pieza.id_estado_pieza
	and estado_pieza.idc_estado_pieza = @idc_estado_pieza
	and pieza.marca = @marca
	and pieza.unidades_por_pieza = @unidades_por_pieza

	if(@tiene_marca is null)
	begin
		if(ltrim(rtrim(@marca)) = '')
			set @tiene_marca = 0
		else
			set @tiene_marca = 1
	end

	insert into pieza (idc_pieza,id_tapa,id_caja,id_farm,id_variedad_flor,id_grado_flor,id_guia,id_estado_pieza,unidades_por_pieza,marca,costo_por_unidad,disponible,tiene_marca,direccion_pieza)
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
	convert(int, estado_guia.idc_estado_guia)
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
	and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja
	and farm.idc_farm = @idc_farm
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and guia.idc_guia = @idc_guia
	and estado_pieza.idc_estado_pieza = @idc_estado_pieza
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and guia.id_estado_guia = estado_guia.id_estado_guia

	if(@idc_pedido_pepr is not null)
	begin
		insert into	origen_confirmacion_pieza (id_pieza, id_confirmacion_bouquet_cultivo)
		select @@identity,
		confirmacion_bouquet_cultivo.id_confirmacion_bouquet_cultivo
		from confirmacion_bouquet_cultivo
		where convert(int, confirmacion_bouquet_cultivo.idc_pedido_pepr) = @idc_pedido_pepr
	end
end
else
if(@accion = 'modificar')
begin
	update pieza
	set disponible = @disponible,
	id_estado_pieza = estado_pieza.id_estado_pieza
	from estado_pieza, pieza
	where pieza.idc_pieza = @idc_pieza
	and estado_pieza.idc_estado_pieza = @idc_estado_pieza
end
else
if(@accion = 'modificar_disponible')
begin
	update pieza
	set disponible = @disponible
	where idc_pieza = @idc_pieza
end
else
if(@accion = 'eliminar')
begin
	delete from pieza
	where idc_pieza = @idc_pieza
end