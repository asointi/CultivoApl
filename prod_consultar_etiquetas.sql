set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_etiquetas]

@id_etiqueta_impresa int,
@accion nvarchar(255)

as

declare @conteo int

if(@accion = 'consultar')
begin
	select @conteo = count(*)	
	from Variedad_Flor, 
	Bloque, 
	Persona,
	punto_corte,
	etiqueta,
	etiqueta_impresa,
	area_asignada,
	area,
	estado_area,
	detalle_area,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	cama,
	nave
	where etiqueta.id_persona = persona.id_persona
	and etiqueta.id_bloque = bloque.id_bloque
	and etiqueta.id_variedad_flor = variedad_flor.id_variedad_flor
	and etiqueta.id_punto_corte = punto_corte.id_punto_corte
	and etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
	and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa
	and persona.id_persona = dbo.Area_Asignada.id_persona
	and dbo.Area_Asignada.id_area = dbo.Area.id_area
	and dbo.Area.id_estado_area = estado_area.id_estado_area
	and dbo.Estado_Area.nombre_estado_area = 'Asignada'
	and dbo.Area.id_area = dbo.Detalle_Area.id_area
	and detalle_area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
	and not exists
	(
		select * 
		from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	and area_asignada.id_area_asignada in
	(
		select max(area_asignada.id_area_asignada)
		from area_asignada
		group by area_asignada.id_area
	)
	and dbo.Sembrar_Cama_Bloque.id_construir_cama_bloque = dbo.Construir_Cama_Bloque.id_construir_cama_bloque
	and dbo.Construir_Cama_Bloque.id_cama = dbo.Cama_Bloque.id_cama 
	AND dbo.Construir_Cama_Bloque.id_bloque = dbo.Cama_Bloque.id_bloque 
	AND dbo.Construir_Cama_Bloque.id_nave = dbo.Cama_Bloque.id_nave
	and dbo.Cama_Bloque.id_cama = dbo.Cama.id_cama
	and dbo.Cama_Bloque.id_bloque = dbo.Bloque.id_bloque
	and dbo.Cama_Bloque.id_nave = dbo.Nave.id_nave
	and dbo.Sembrar_Cama_Bloque.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor

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
	when @conteo = 0 then -1	
	when 
		(	
			select entrada.id_etiqueta_impresa
			from entrada
			where etiqueta_impresa.id_etiqueta_impresa = entrada.id_etiqueta_impresa
		) is null then 0
	else 
		(
			select idc_pieza_postcosecha
			from pieza_postcosecha,
			entrada
			where pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
			and entrada.id_etiqueta_impresa = etiqueta_impresa.id_etiqueta_impresa
			and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa
		) 
	end as entrada
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


