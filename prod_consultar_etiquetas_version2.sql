set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_etiquetas_version2]

@id_etiqueta_impresa int,
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	bloque.idc_bloque,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	etiqueta.unidades,
	case
	when 
		(	
			select entrada.id_etiqueta_impresa
			from entrada
			where etiqueta_impresa.id_etiqueta_impresa = entrada.id_etiqueta_impresa
		) is null then 0
	else 1
	end as entrada,
	isnull((
		select idc_pieza_postcosecha
		from pieza_postcosecha,
		entrada
		where pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
		and entrada.id_etiqueta_impresa = etiqueta_impresa.id_etiqueta_impresa
		and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa
	), -1) as idc_pieza_postcosecha
	from etiqueta,
	variedad_flor,
	tipo_flor,
	bloque,
	persona, 
	punto_corte,
	etiqueta_impresa
	where dbo.Etiqueta.id_bloque = dbo.Bloque.id_bloque
	and dbo.Etiqueta.id_persona = dbo.Persona.id_persona
	and dbo.Etiqueta.id_punto_corte = dbo.Punto_Corte.id_punto_corte
	and dbo.Etiqueta.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
	and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and dbo.Etiqueta_Impresa.id_etiqueta = dbo.Etiqueta.id_etiqueta
	and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa
end


