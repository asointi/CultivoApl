set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/04/13
-- Description:	Graba las piezas a través de la etiqueta impresa
-- =============================================

alter PROCEDURE [dbo].[inv_insertar_pieza_postcosecha_idc_cobol_version2] 

@idc_pieza_postcosecha nvarchar(255),
@fecha nvarchar(255),
@hora nvarchar(255),
@id_etiqueta_impresa int,
@accion nvarchar(255),
@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255)

AS

declare @id_item int,
@conteo int

if(@accion = 'insertar')
begin
BEGIN TRY
	INSERT INTO Pieza_Postcosecha
	(
		id_caracteristica_tipo_flor, 
		id_variedad_flor, 
		id_bloque, 
		idc_pieza_postcosecha, 
		id_persona, 
		unidades_por_pieza, 
		fecha_entrada, 
		id_punto_corte
	)
	select caracteristica_tipo_flor.id_caracteristica_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	@idc_pieza_postcosecha, 
	persona.id_persona,
	etiqueta.unidades,
	(CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)), 
	punto_corte.id_punto_corte
	from caracteristica_tipo_flor, 
	Variedad_Flor, 
	Tipo_Flor, 
	Bloque, 
	Persona,
	punto_corte,
	etiqueta,
	etiqueta_impresa
	where etiqueta.id_persona = persona.id_persona
	and etiqueta.id_bloque = bloque.id_bloque
	and etiqueta.id_variedad_flor = variedad_flor.id_variedad_flor
	and etiqueta.id_punto_corte = punto_corte.id_punto_corte
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = caracteristica_tipo_flor.id_tipo_flor
	and etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
	and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa

	select @id_item = scope_identity()

	insert into entrada (id_etiqueta_impresa, id_pieza_postcosecha)
	values (@id_etiqueta_impresa, @id_item)
END TRY
BEGIN CATCH

END CATCH
end
else
if(@accion = 'eliminar')
begin
	delete from entrada
	where exists
	(
		select *
		from pieza_postcosecha 
		where convert(datetime, convert(nvarchar, fecha_entrada, 101)) between
		convert(datetime, @fecha_inicial) and convert(datetime, @fecha_final)
		and pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
	)

	delete from salida_pieza
	where exists
	(
		select *
		from pieza_postcosecha 
		where convert(datetime, convert(nvarchar, fecha_entrada, 101)) between
		convert(datetime, @fecha_inicial) and convert(datetime, @fecha_final)
		and pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha
	)

	delete from pieza_postcosecha 
	where convert(datetime, convert(nvarchar, fecha_entrada, 101)) between
	convert(datetime, @fecha_inicial) and convert(datetime, @fecha_final)
end
