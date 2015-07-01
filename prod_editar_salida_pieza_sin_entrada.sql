set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/04/13
-- Description:	Graba las piezas a través de la etiqueta impresa
-- =============================================

alter PROCEDURE [dbo].[prod_editar_salida_pieza_sin_entrada] 

@id_etiqueta_impresa int,
@accion nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime

AS

if(@accion = 'insertar')
begin
	insert into salida_pieza_sin_entrada (id_etiqueta_impresa)
	values (@id_etiqueta_impresa)
end
else
if(@accion = 'consultar_salidas_sin_entrada')
begin
	select etiqueta_impresa.id_etiqueta_impresa,
	persona.idc_persona,
	persona.identificacion,
	persona.nombre,
	persona.apellido,
	bloque.idc_bloque,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	etiqueta.unidades,
	max(salida_pieza_sin_entrada.fecha_transaccion) as fecha_transaccion
	from salida_pieza_sin_entrada,
	etiqueta_impresa,
	etiqueta,
	persona,
	bloque,
	variedad_flor,
	punto_corte,
	tipo_flor
	where etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
	and etiqueta_impresa.id_etiqueta_impresa = salida_pieza_sin_entrada.id_etiqueta_impresa
	and etiqueta.id_persona = persona.id_persona
	and etiqueta.id_bloque = bloque.id_bloque
	and etiqueta.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and etiqueta.id_punto_corte = punto_corte.id_punto_corte
	and not exists
	(
		select * from entrada
		where etiqueta_impresa.id_etiqueta_impresa = entrada.id_etiqueta_impresa
	)
	group by etiqueta_impresa.id_etiqueta_impresa,
	persona.idc_persona,
	persona.identificacion,
	persona.nombre,
	persona.apellido,
	bloque.idc_bloque,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	etiqueta.unidades
end
else
if(@accion = 'consultar_salidas')
begin
	select etiqueta_impresa.id_etiqueta_impresa,
	persona.idc_persona,
	persona.identificacion,
	persona.nombre,
	persona.apellido,
	bloque.idc_bloque,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	etiqueta.unidades,
	salida_pieza_sin_entrada.fecha_transaccion
	from salida_pieza_sin_entrada,
	etiqueta_impresa,
	etiqueta,
	persona,
	bloque,
	variedad_flor,
	punto_corte,
	tipo_flor
	where etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
	and etiqueta_impresa.id_etiqueta_impresa = salida_pieza_sin_entrada.id_etiqueta_impresa
	and etiqueta.id_persona = persona.id_persona
	and etiqueta.id_bloque = bloque.id_bloque
	and etiqueta.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and etiqueta.id_punto_corte = punto_corte.id_punto_corte
	and convert(datetime,convert(nvarchar,salida_pieza_sin_entrada.fecha_transaccion, 101)) between
	@fecha_inicial and @fecha_final	
end