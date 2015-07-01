set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[siembra_editar_area]

@id_persona int, 
@id_bloque int,
@id_sembrar_cama_bloque int,
@accion nvarchar(255),
@id_cuenta_interna int,
@fecha_asignacion datetime,
@id_nave nvarchar(255),
@id_detalle_area_precopia int,
@id_area int

AS

declare @conteo int,
@id_item int

if(@accion = 'consultar_areas_actuales')
begin
	select area.id_area,
	bloque.id_bloque,
	bloque.idc_bloque,
	bloque.area,
	nave.numero_nave,
	cama.numero_cama,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	max(area_asignada.fecha_asignacion) as fecha_asignacion,
	(
		select count(scb.id_sembrar_cama_bloque)
		from bloque as b,
		cama_bloque as cb,
		construir_cama_bloque as ccb,
		sembrar_cama_bloque as scb
		where bloque.id_bloque = b.id_bloque
		and b.id_bloque = cb.id_bloque
		and cb.id_bloque = ccb.id_bloque
		and cb.id_nave = ccb.id_nave
		and cb.id_cama = ccb.id_cama
		and ccb.id_construir_cama_bloque = scb.id_construir_cama_bloque
		and not exists
		(
			select * 
			from erradicar_cama_bloque as ecb
			where scb.id_sembrar_cama_bloque = ecb.id_sembrar_cama_bloque
		)
	) as cantidad_camas_totales
	from persona,
	area_asignada,
	area,
	estado_area,
	detalle_area,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	cama,
	nave,
	bloque,
	tipo_flor,
	variedad_flor
	where persona.id_persona = dbo.Area_Asignada.id_persona
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
	and not exists
	(
		select * from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	and dbo.Sembrar_Cama_Bloque.id_construir_cama_bloque = dbo.Construir_Cama_Bloque.id_construir_cama_bloque
	and dbo.Construir_Cama_Bloque.id_cama = dbo.Cama_Bloque.id_cama 
	AND dbo.Construir_Cama_Bloque.id_bloque = dbo.Cama_Bloque.id_bloque 
	AND dbo.Construir_Cama_Bloque.id_nave = dbo.Cama_Bloque.id_nave
	and dbo.Cama_Bloque.id_cama = dbo.Cama.id_cama
	and dbo.Cama_Bloque.id_bloque = dbo.Bloque.id_bloque
	and dbo.Cama_Bloque.id_nave = dbo.Nave.id_nave
	and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and dbo.Sembrar_Cama_Bloque.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
	group by area.id_area,
	bloque.id_bloque,
	bloque.idc_bloque,
	bloque.area,
	nave.numero_nave,
	cama.numero_cama,
	persona.idc_persona,
	persona.nombre,
	persona.apellido,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor
	order by bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor
end
else
if(@accion = 'insertar_precopia')
begin
  select @conteo = count(*) from Detalle_Area_Precopia
  where id_persona = @id_persona
  and id_sembrar_cama_bloque = @id_sembrar_cama_bloque
  
  if(@conteo = 0)
  begin
    insert into Detalle_Area_Precopia (id_persona, id_sembrar_cama_bloque)
    values (@id_persona, @id_sembrar_cama_bloque)
  end
end  
else
if(@accion = 'consultar_precopia')
begin
  select detalle_area_precopia.id_detalle_area_precopia,
  bloque.idc_bloque,
  nave.numero_nave,
  cama.numero_cama,
  ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
  from detalle_area_precopia,
  sembrar_cama_bloque,
  variedad_flor,
  tipo_flor,
  construir_cama_bloque,
  cama_bloque,
  cama,
  bloque,
  nave
  where detalle_area_precopia.id_persona = @id_persona
  and dbo.Detalle_Area_Precopia.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
  and dbo.Construir_Cama_Bloque.id_construir_cama_bloque = dbo.Sembrar_Cama_Bloque.id_construir_cama_bloque
  and dbo.Cama_Bloque.id_bloque = dbo.Construir_Cama_Bloque.id_bloque
  and dbo.Cama_Bloque.id_cama = dbo.Construir_Cama_Bloque.id_cama
  and dbo.Cama_Bloque.id_nave = dbo.Construir_Cama_Bloque.id_nave
  and dbo.Cama.id_cama = dbo.Cama_Bloque.id_cama
  and dbo.Bloque.id_bloque = dbo.Cama_Bloque.id_bloque
  and dbo.Nave.id_nave = dbo.Cama_Bloque.id_nave
  and dbo.Sembrar_Cama_Bloque.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
  and dbo.Tipo_Flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
  ORDER BY bloque.idc_bloque,
  nave.numero_nave,
  cama.numero_cama
end
else
if(@accion = 'insertar_area')
begin
  insert into area (id_cuenta_interna, id_estado_area, fecha_transaccion)
  select @id_cuenta_interna, estado_area.id_estado_area, getdate()
  from estado_area
  where nombre_estado_area = 'Asignada'

  set @id_item = scope_identity()
  
  insert into Area_Asignada (id_cuenta_interna, id_area, id_persona, fecha_asignacion)
  values (@id_cuenta_interna, @id_item, @id_persona, @fecha_asignacion)
  
  insert into Detalle_Area (id_sembrar_cama_bloque, id_area)
  select detalle_area_precopia.id_sembrar_cama_bloque, @id_item
  from detalle_area_precopia
  where detalle_area_precopia.id_persona = @id_persona
  
  delete from detalle_area_precopia
  where id_persona = @id_persona
end
else
if(@accion = 'consultar_bloque')
begin
  select bloque.id_bloque,
  bloque.idc_bloque
  from bloque,
  cama_bloque,
  construir_cama_bloque,
  sembrar_cama_bloque
  where dbo.Bloque.id_bloque = dbo.Cama_Bloque.id_bloque
  and cama_bloque.id_bloque = dbo.Construir_Cama_Bloque.id_bloque
  and cama_bloque.id_cama = dbo.Construir_Cama_Bloque.id_cama
  and cama_bloque.id_nave = dbo.Construir_Cama_Bloque.id_nave
  and dbo.Construir_Cama_Bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
  and not exists
  (
    select * 
    from Detalle_Area,
    area,
    estado_area
    where estado_area.id_estado_area = dbo.Area.id_estado_area
    and dbo.Area.id_area = dbo.Detalle_Area.id_area
    and dbo.Detalle_Area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
    and dbo.Estado_Area.nombre_estado_area = 'Asignada'
  )
  and not exists
  (
	select * from detalle_area_precopia,
	persona
	where detalle_area_precopia.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and detalle_area_precopia.id_persona = persona.id_persona
	and persona.id_persona = @id_persona
  )
  and not exists
  (
    select * 
    from erradicar_cama_bloque
    where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
  )
  group by bloque.id_bloque,
  bloque.idc_bloque
  order by bloque.id_bloque
end
else
if(@accion = 'consultar_nave')
begin
  select nave.id_nave,
  nave.numero_nave
  from bloque,
  nave,
  cama_bloque,
  construir_cama_bloque,
  sembrar_cama_bloque
  where dbo.Bloque.id_bloque = dbo.Cama_Bloque.id_bloque
  and dbo.Bloque.id_bloque = @id_bloque
  and dbo.Nave.id_nave = dbo.Cama_Bloque.id_nave
  and cama_bloque.id_bloque = dbo.Construir_Cama_Bloque.id_bloque
  and cama_bloque.id_cama = dbo.Construir_Cama_Bloque.id_cama
  and cama_bloque.id_nave = dbo.Construir_Cama_Bloque.id_nave
  and dbo.Construir_Cama_Bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
  and not exists
  (
    select * 
    from Detalle_Area,
    area,
    estado_area
    where estado_area.id_estado_area = dbo.Area.id_estado_area
    and dbo.Area.id_area = dbo.Detalle_Area.id_area
    and dbo.Detalle_Area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
    and dbo.Estado_Area.nombre_estado_area = 'Asignada'
  )
  and not exists
  (
	select * from detalle_area_precopia,
	persona
	where detalle_area_precopia.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and detalle_area_precopia.id_persona = persona.id_persona
	and persona.id_persona = @id_persona
  )
  and not exists
  (
    select * from erradicar_cama_bloque
    where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
  )
  group by nave.id_nave,
  nave.numero_nave
  order by nave.numero_nave
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
  bloque.id_bloque,
  bloque.idc_bloque,
  nave.id_nave,
  nave.numero_nave,
  cama.numero_cama,
  ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
  from bloque,
  nave,
  cama_bloque,
  construir_cama_bloque,
  sembrar_cama_bloque,
  tipo_flor,
  variedad_flor,
  cama
  where dbo.Bloque.id_bloque = dbo.Cama_Bloque.id_bloque
  and dbo.Bloque.id_bloque = @id_bloque
  and nave.id_nave in (select id from #temp)
  and dbo.Cama.id_cama = dbo.Cama_Bloque.id_cama
  and dbo.Nave.id_nave = dbo.Cama_Bloque.id_nave
  and cama_bloque.id_bloque = dbo.Construir_Cama_Bloque.id_bloque
  and cama_bloque.id_cama = dbo.Construir_Cama_Bloque.id_cama
  and cama_bloque.id_nave = dbo.Construir_Cama_Bloque.id_nave
  and dbo.Tipo_Flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
  and dbo.Variedad_Flor.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
  and dbo.Construir_Cama_Bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
  and not exists
  (
    select * 
    from Detalle_Area,
    area,
    estado_area
    where estado_area.id_estado_area = Area.id_estado_area
    and Area.id_area = Detalle_Area.id_area
    and Detalle_Area.id_sembrar_cama_bloque = Sembrar_Cama_Bloque.id_sembrar_cama_bloque
    and Estado_Area.nombre_estado_area = 'Asignada'
  )
  and not exists
  (
	select * from detalle_area_precopia,
	persona
	where detalle_area_precopia.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and detalle_area_precopia.id_persona = persona.id_persona
	and persona.id_persona = @id_persona
  )
  and not exists
  (
    select * from erradicar_cama_bloque
    where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
  )
  group by sembrar_cama_bloque.id_sembrar_cama_bloque,
  bloque.id_bloque,
  bloque.idc_bloque,
  nave.id_nave,
  nave.numero_nave,
  cama.numero_cama,
  tipo_flor.nombre_tipo_flor,
  tipo_flor.idc_tipo_flor,
  variedad_flor.nombre_variedad_flor,
  variedad_flor.idc_variedad_flor
  order by bloque.id_bloque,
  nave.numero_nave,
  cama.numero_cama
  
  drop table #temp
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
	and not exists
	(
	select *
	from area_asignada,
	area,
	estado_area
	where persona.id_persona = dbo.Area_Asignada.id_persona
	and dbo.Area_Asignada.id_area = dbo.Area.id_area
	and dbo.Area.id_estado_area = estado_area.id_estado_area
	and dbo.Estado_Area.nombre_estado_area = 'Asignada'
	and area_asignada.id_area_asignada in
		(
			select max(area_asignada.id_area_asignada)
			from area_asignada
			group by area_asignada.id_area
		)
	)
	order by nombre_persona
end
else
if(@accion = 'eliminar_precopia')
begin
	delete from detalle_area_precopia
	where id_detalle_area_precopia = @id_detalle_area_precopia
end
else
if(@accion = 'consultar_persona_asignada')
begin
	select persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + persona.identificacion + ')' as nombre_persona,
	persona.identificacion 
	from persona,
	area_asignada,
	area,
	estado_area
	where persona.id_persona = dbo.Area_Asignada.id_persona
	and dbo.Area_Asignada.id_area = dbo.Area.id_area
	and dbo.Area.id_estado_area = estado_area.id_estado_area
	and dbo.Estado_Area.nombre_estado_area = 'Asignada'
	and area_asignada.id_area_asignada in
	(
		select max(area_asignada.id_area_asignada)
		from area_asignada
		group by area_asignada.id_area
	)
	order by nombre_persona
end
else
if(@accion = 'consultar_area_asignada')
begin
	select area.id_area,
	bloque.id_bloque,
	bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
	from persona,
	area_asignada,
	area,
	estado_area,
	detalle_area,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	cama,
	nave,
	bloque,
	tipo_flor,
	variedad_flor
	where persona.id_persona = dbo.Area_Asignada.id_persona
	and dbo.Persona.id_persona = @id_persona 
	and dbo.Area_Asignada.id_area = dbo.Area.id_area
	and dbo.Area.id_estado_area = estado_area.id_estado_area
	and dbo.Estado_Area.nombre_estado_area = 'Asignada'
	and dbo.Area.id_area = dbo.Detalle_Area.id_area
	and detalle_area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
	and not exists
	(
	 select * from erradicar_cama_bloque
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
	and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and dbo.Sembrar_Cama_Bloque.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
	order by bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor
end
else
if(@accion = 'reasignar_area')
begin
	insert into Area_Asignada (id_cuenta_interna, id_area, id_persona, fecha_asignacion)
	values (@id_cuenta_interna, @id_area, @id_persona, @fecha_asignacion)
end
else 
if(@accion = 'Anular_area')
begin
	update area
	set id_estado_area = estado_area.id_estado_area,
	fecha_transaccion = getdate()
	from estado_area
	where area.id_area = @id_area
	and estado_area.nombre_estado_area = 'Anulada'
end