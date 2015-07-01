/****** Object:  StoredProcedure [dbo].[na_editar_caracteristica_tipo_flor]    Script Date: 09/24/2009 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_consultar_codigo_etiqueta]

@idc_farm nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_tapa nvarchar(255),
@store nvarchar(255),
@idc_caja nvarchar(255),
@unidades_por_pieza int,
@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255),
@nombre_usuario nvarchar(255)

AS

if(@nombre_usuario = '')
begin
	select TOP 1 etiqueta.codigo
	from etiqueta 
	where 
	etiqueta.farm = @idc_farm
	and etiqueta.tipo = @idc_tipo_flor
	and etiqueta.variedad = @idc_variedad_flor
	and etiqueta.grado = @idc_grado_flor
	and etiqueta.tapa = @idc_tapa
	and etiqueta.marca = @store
	and etiqueta.tipo_caja = @idc_caja
	and etiqueta.unidades_por_caja = @unidades_por_pieza
	and etiqueta.fecha between 
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
	and not exists
	(
		select * from etiqueta_receiving
		where etiqueta_receiving.etiqueta = etiqueta.codigo
	)
	and not exists
	(
		select * from etiqueta_creci
		where etiqueta_creci.etiqueta = etiqueta.codigo
	)
	group by etiqueta.codigo
end
else
begin
	select TOP 1 etiqueta.codigo
	from etiqueta, 
	usuarios
	where 
	farm = @idc_farm
	and tipo = @idc_tipo_flor
	and variedad = @idc_variedad_flor
	and grado = @idc_grado_flor
	and tapa = @idc_tapa
	and marca = @store
	and tipo_caja = @idc_caja
	and unidades_por_caja = @unidades_por_pieza
	and etiqueta.fecha between 
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
	and usuarios.nombre = @nombre_usuario
	and not exists
	(
		select * from etiqueta_receiving
		where etiqueta_receiving.etiqueta = etiqueta.codigo
	)
	and not exists
	(
		select * from etiqueta_creci
		where etiqueta_creci.etiqueta = etiqueta.codigo
	)
	group by etiqueta.codigo
end

