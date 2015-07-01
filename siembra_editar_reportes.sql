set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[siembra_editar_reportes]

@accion nvarchar(255)

as

if(@accion = 'reporte_general')
begin
	select bloque.id_bloque,
	bloque.idc_bloque,
	--supervisor.id_supervisor,
	--supervisor.idc_supervisor,
	--supervisor.nombre_supervisor,
	cama_bloque.id_cama_bloque,
	nave.id_nave,
	nave.numero_nave,
	cama.id_cama,
	cama.numero_cama,
	construir_cama_bloque.id_construir_cama_bloque,
	construir_cama_bloque.fecha as fecha_construccion,
	construir_cama_bloque.largo,
	construir_cama_bloque.ancho,
	sembrar_cama_bloque.id_sembrar_cama_bloque,
	sembrar_cama_bloque.cantidad_matas,
	sembrar_cama_bloque.fecha as fecha_siembra,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	color.id_color,
	color.idc_color,
	color.nombre_color,
	erradicar_cama_bloque.id_erradicar_cama_bloque,
	erradicar_cama_bloque.fecha as fecha_erradicacion,
	destruir_cama_bloque.id_destruir_cama_bloque,
	destruir_cama_bloque.fecha as fecha_destruccion
	from bloque,
	cama_bloque,
	construir_cama_bloque left join destruir_cama_bloque on construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque,
	sembrar_cama_bloque left join erradicar_cama_bloque on sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque,
	cama,
	--supervisor,
	tipo_flor,
	variedad_flor left join color on variedad_flor.id_color = color.id_color,
	nave
	where nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama.id_cama = cama_bloque.id_cama
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	--and supervisor.id_supervisor = bloque.id_supervisor
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	group by bloque.id_bloque,
	bloque.idc_bloque,
	--supervisor.id_supervisor,
	--supervisor.idc_supervisor,
	--supervisor.nombre_supervisor,
	cama_bloque.id_cama_bloque,
	nave.id_nave,
	nave.numero_nave,
	cama.id_cama,
	cama.numero_cama,
	construir_cama_bloque.id_construir_cama_bloque,
	construir_cama_bloque.fecha,
	construir_cama_bloque.largo,
	construir_cama_bloque.ancho,
	sembrar_cama_bloque.id_sembrar_cama_bloque,
	sembrar_cama_bloque.cantidad_matas,
	sembrar_cama_bloque.fecha,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	color.id_color,
	color.idc_color,
	color.nombre_color,
	erradicar_cama_bloque.id_erradicar_cama_bloque,
	erradicar_cama_bloque.fecha,
	destruir_cama_bloque.id_destruir_cama_bloque,
	destruir_cama_bloque.fecha
	having erradicar_cama_bloque.id_erradicar_cama_bloque is null
	order by bloque.id_bloque,
	nave.numero_nave,
	cama.numero_cama
end