USE [BD_Fresca]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[bouquet_consultar_reporte_formato_cultivo_formulas] 

@id_detalle_version_bouquet int,
@accion nvarchar(255)

as
if(@accion = 'Receta')
begin
	select Formula_Unica_Bouquet.id_formula_unica_bouquet,
	ltrim(rtrim(Tipo_Flor_Cultivo.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(Variedad_Flor_Cultivo.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(Grado_Flor_Cultivo.nombre_grado_flor)) as nombre_grado_flor,
	Detalle_Formula_Bouquet.cantidad_tallos,
	(
		select ltrim(rtrim(Tipo_Flor_Cultivo.nombre_tipo_flor)) + ' ' + ltrim(rtrim(Variedad_Flor_Cultivo.nombre_variedad_flor)) + ' ' + ltrim(rtrim(Grado_Flor_Cultivo.nombre_grado_flor))
		from Sustitucion_Detalle_Formula_Bouquet,
		Tipo_Flor_Cultivo,
		Variedad_Flor_Cultivo,
		Grado_Flor_Cultivo
		where Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
		and Detalle_Version_Bouquet.id_detalle_version_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_version_bouquet
		and Tipo_Flor_Cultivo.id_tipo_flor_cultivo = Variedad_Flor_Cultivo.id_tipo_flor_cultivo
		and Tipo_Flor_Cultivo.id_tipo_flor_cultivo = Grado_Flor_Cultivo.id_tipo_flor_cultivo
		and Variedad_Flor_Cultivo.id_variedad_flor_cultivo = Sustitucion_Detalle_Formula_Bouquet.id_variedad_flor_cultivo
		and Grado_Flor_Cultivo.id_grado_flor_cultivo = Sustitucion_Detalle_Formula_Bouquet.id_grado_flor_cultivo
	) as sustitucion,
	(
		select ltrim(rtrim(observacion))
		from Observacion_Detalle_Formula_Bouquet
		where Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Observacion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
		and Detalle_Version_Bouquet.id_detalle_version_bouquet = Observacion_Detalle_Formula_Bouquet.id_detalle_version_bouquet
	) as observacion
	from formula_bouquet,
	Formula_Unica_Bouquet,
	Detalle_Formula_Bouquet,
	Tipo_Flor_Cultivo,
	Variedad_Flor_Cultivo,
	Grado_Flor_Cultivo,
	Detalle_Version_Bouquet
	where Formula_Unica_Bouquet.id_formula_unica_bouquet = Formula_Bouquet.id_formula_unica_bouquet
	and Formula_Unica_Bouquet.id_formula_unica_bouquet = Detalle_Formula_Bouquet.id_formula_unica_bouquet
	and Tipo_Flor_Cultivo.id_tipo_flor_cultivo = Variedad_Flor_Cultivo.id_tipo_flor_cultivo
	and Tipo_Flor_Cultivo.id_tipo_flor_cultivo = Grado_Flor_Cultivo.id_tipo_flor_cultivo
	and Variedad_Flor_Cultivo.id_variedad_flor_cultivo = Detalle_Formula_Bouquet.id_variedad_flor_cultivo
	and Grado_Flor_Cultivo.id_grado_flor_cultivo = Detalle_Formula_Bouquet.id_grado_flor_cultivo
	and Formula_Bouquet.id_formula_bouquet = Detalle_Version_Bouquet.id_formula_bouquet
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor
end
else
if(@accion = 'Capuchon')
begin
	select ltrim(rtrim(Capuchon_Cultivo.descripcion)) + ' [' + convert(nvarchar,convert(decimal(20,1),capuchon_cultivo.ancho_superior)) + ']' as nombre_capuchon
	from Detalle_Version_Bouquet,
	Capuchon_Cultivo,
	Capuchon_Formula_Bouquet
	where Capuchon_Cultivo.id_capuchon_cultivo = Capuchon_Formula_Bouquet.id_capuchon_cultivo
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = Capuchon_Formula_Bouquet.id_detalle_version_bouquet
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by nombre_capuchon
end
else
if(@accion = 'Sticker')
begin
	select ltrim(rtrim(Sticker.nombre_sticker)) as nombre_sticker
	from Detalle_Version_Bouquet,
	Sticker,
	Sticker_Bouquet
	where Sticker.id_sticker = Sticker_Bouquet.id_sticker
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = Sticker_Bouquet.id_detalle_version_bouquet
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by nombre_sticker
end
else
if(@accion = 'UPC')
begin
	select Informacion_UPC.nombre_informacion_upc,
	ltrim(rtrim(UPC_Detalle_PO.valor)) as valor,
	UPC_Detalle_PO.orden
	from Detalle_Version_Bouquet,
	UPC_Detalle_PO,
	Informacion_UPC
	where Informacion_UPC.id_informacion_upc = UPC_Detalle_PO.id_informacion_upc
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = UPC_Detalle_PO.id_detalle_version_bouquet
	and Detalle_Version_Bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by UPC_Detalle_PO.orden
end