set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[siembra_editar_cama_persona]

@id_sembrar_cama_bloque int,
@id_persona int,
@id_bloque int,
@id_nave nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar_nave_por_bloque')
begin
	select nave.id_nave,
	nave.numero_nave
	from bloque,
	cama_bloque,
	nave,
	construir_cama_bloque,
	sembrar_cama_bloque
	where bloque.id_bloque = cama_bloque.id_bloque
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and bloque.id_bloque = @id_bloque
	and not exists
	(select * from erradicar_cama_bloque
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque)
	group by nave.id_nave,
	nave.numero_nave
	order by nave.numero_nave
end
else
if(@accion = 'consultar_persona')
begin
	select persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + persona.identificacion + ')' as nombre_persona,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion 
	from persona
	where disponible = 1
	and exists
	(
		select * from historia_ingreso
		where historia_ingreso.id_persona = persona.id_persona
		and not exists
		(
			select * from historia_retiro
			where historia_ingreso.id_historia_ingreso = historia_retiro.id_historia_ingreso
		)
	)
	order by nombre_persona
end
else
if(@accion = 'consultar_cama')
begin
  create table #temp (id int)

	/*crear la insercion para los valores separados por comas*/
	declare @sql varchar(8000)
	select @sql = 'insert into #temp select '+	replace(@id_nave,',',' union all select ')
	
	/*cargar todos los valores de la variable @id_nave en la tabla temporal*/
	exec (@SQL)

	select sembrar_cama_bloque.id_sembrar_cama_bloque,
	nave.id_nave,
	nave.numero_nave,
	cama.numero_cama,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
	from bloque,
	cama,
	nave,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	variedad_flor,
	tipo_flor
	where bloque.id_bloque = cama_bloque.id_bloque
	and cama.id_cama = cama_bloque.id_cama
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and variedad_flor.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and nave.id_nave in (select id from #temp)
	and bloque.id_bloque = @id_bloque
	and not exists
	   (
	   select * from Detalle_Area,
	   area,
	   estado_area
	   where detalle_area.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	   and area.id_area = detalle_area.id_area
	   and area.id_estado_area = estado_area.id_estado_area
	   and estado_area.nombre_estado_area = 'Asignada'
	   )
	and not exists
	(select * from erradicar_cama_bloque 
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque)
	group by sembrar_cama_bloque.id_sembrar_cama_bloque,
	cama.numero_cama,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	nave.numero_nave,
	nave.id_nave
	order by nave.numero_nave,
	cama.numero_cama

	drop table #temp
end
else
if(@accion = 'consultar_cama_reasignar')
begin
	select sembrar_cama_bloque.id_sembrar_cama_bloque,
	bloque.id_bloque,
	bloque.idc_bloque,
	nave.id_nave,
	nave.numero_nave,
	cama.numero_cama,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
	from bloque,
	cama,
	nave,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	variedad_flor,
	tipo_flor,
	persona,
  area_asignada,
	area,
	estado_area,
	detalle_area
	where bloque.id_bloque = cama_bloque.id_bloque
	and cama.id_cama = cama_bloque.id_cama
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and variedad_flor.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and persona.id_persona = @id_persona
	and not exists
	(
	select * from erradicar_cama_bloque 
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	and persona.id_persona = dbo.Area_Asignada.id_persona
	and dbo.Area_Asignada.id_area = dbo.Area.id_area
	and dbo.Area.id_estado_area = estado_area.id_estado_area
	and dbo.Estado_Area.nombre_estado_area = 'Asignada'
	and dbo.Area.id_area = dbo.Detalle_Area.id_area
	and detalle_area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
	and area_asignada.id_area_asignada in
	(
		select max(area_asignada.id_area_asignada)
		from area_asignada
		group by area_asignada.id_area
	)
	group by sembrar_cama_bloque.id_sembrar_cama_bloque,
	bloque.id_bloque,
	bloque.idc_bloque,
	cama.numero_cama,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	nave.numero_nave,
	nave.id_nave
	order by bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama
end