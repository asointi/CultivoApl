alter PROCEDURE [dbo].[poda_editar_realiza_poda]

@accion nvarchar(255),
@nombre_tipo_poda nvarchar(255),
@id_tipo_poda int,
@id_bloque int,
@id_variedad_flor int,
@id_realiza_poda int,
@id_estado_variedad_flor int, 
@id_persona int, 
@fecha datetime, 
@cantidad_tallos int,
@id_cama int,
@id_nave int

AS

declare @conteo int

if(@accion = 'consultar_tipo_poda')
begin
	select id_tipo_poda,
	nombre_tipo_poda
	from tipo_poda
	order by nombre_tipo_poda
end
else
if(@accion = 'insertar_tipo_poda')
begin
	select @conteo = count(*)
	from tipo_poda
	where nombre_tipo_poda = @nombre_tipo_poda

	if(@conteo = 0)
	begin
		insert into tipo_poda (nombre_tipo_poda)
		values (@nombre_tipo_poda)
	end
end
else
if(@accion = 'modificar_tipo_poda')
begin
	select @conteo = count(*)
	from tipo_poda
	where nombre_tipo_poda = @nombre_tipo_poda
	and tipo_poda.id_tipo_poda <> @id_tipo_poda

	if(@conteo = 0)
	begin
		update tipo_poda 
		set nombre_tipo_poda = @nombre_tipo_poda
		where id_tipo_poda = @id_tipo_poda
	end
end
else
if(@accion = 'eliminar_tipo_poda')
begin
	select @conteo = count(*)
	from tipo_poda,
	realiza_poda
	where tipo_poda.id_tipo_poda = realiza_poda.id_tipo_poda
	and tipo_poda.id_tipo_poda = @id_tipo_poda

	if(@conteo = 0)
	begin
		delete from tipo_poda 
		where id_tipo_poda = @id_tipo_poda
	end
end
-------------------------------------------------------------------------
else
if(@accion = 'consultar_realiza_poda')
begin
	select realiza_poda.id_realiza_poda,
	tipo_poda.id_tipo_poda,
	tipo_poda.nombre_tipo_poda,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	cama.id_cama,
	cama.numero_cama,
	nave.id_nave,
	nave.numero_nave,
	estado_variedad_flor.id_estado_variedad_flor,
	estado_variedad_flor.nombre_estado,
	estado_variedad_flor.orden as orden_estado,
	persona.id_persona,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + ltrim(rtrim(persona.identificacion)) + ']' as nombre_persona,
	realiza_poda.fecha,
	realiza_poda.cantidad_tallos
	from tipo_poda,
	realiza_poda,
	variedad_flor,
	tipo_flor,
	bloque,
	estado_variedad_flor,
	persona,
	detalle_realiza_poda,
	nave,
	cama
	where realiza_poda.id_realiza_poda = detalle_realiza_poda.id_realiza_poda
	and cama.id_cama = detalle_realiza_poda.id_cama
	and nave.id_nave = detalle_realiza_poda.id_nave
	and tipo_poda.id_tipo_poda = realiza_poda.id_tipo_poda
	and variedad_flor.id_variedad_flor = realiza_poda.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and bloque.id_bloque = realiza_poda.id_bloque
	and estado_variedad_flor.id_estado_variedad_flor = realiza_poda.id_estado_variedad_flor
	and persona.id_persona = realiza_poda.id_persona
	order by bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama,
	nombre_tipo_flor,
	nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	realiza_poda.fecha
end
else
if(@accion = 'consultar_poda_general')
begin
	select nave_detalle_realiza_poda_arreglo.id_nave_detalle_realiza_poda_arreglo,
	tipo_poda.id_tipo_poda,
	tipo_poda.nombre_tipo_poda,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	cama.id_cama,
	cama.numero_cama,
	nave.id_nave,
	nave.numero_nave,
	a.id_estado_variedad_flor as id_estado_variedad_flor_inicial,
	a.nombre_estado as nombre_estado_inicial,
	b.id_estado_variedad_flor as id_estado_variedad_flor_final,
	b.nombre_estado as nombre_estado_final,
	p1.id_persona as id_persona_area,
	ltrim(rtrim(p1.nombre)) + ' ' + ltrim(rtrim(p1.apellido)) + ' [' + ltrim(rtrim(p1.identificacion)) + ']' as nombre_persona_area,
	p1.idc_persona as idc_persona_area,
	p2.id_persona as id_persona_realiza_poda,
	ltrim(rtrim(p2.nombre)) + ' ' + ltrim(rtrim(p2.apellido)) + ' [' + ltrim(rtrim(p2.identificacion)) + ']' as nombre_persona_realiza_poda,
	p2.idc_persona as idc_persona_realiza_poda,
	nave_detalle_realiza_poda_arreglo.fecha,
	isnull((
		select n.cantidad_tallos
		from nave_detalle_realiza_poda_arreglo as n
		where n.id_nave_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_nave_detalle_realiza_poda_arreglo
	), 0) as cantidad_tallos into #resultado_podas
	from realiza_poda_arreglo,
	tipo_poda,
	detalle_realiza_poda_arreglo left join persona as p2 on p2.id_persona = detalle_realiza_poda_arreglo.id_persona_realiza_poda,
	nave_detalle_realiza_poda_arreglo,
	tipo_flor,
	variedad_flor,
	bloque,
	nave,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona as p1,
	area,
	detalle_area,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama
	where realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and p1.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and area.id_area = detalle_realiza_poda_arreglo.id_area
	and area.id_area = detalle_area.id_area
	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and construir_cama_bloque.id_nave = nave.id_nave
	and construir_cama_bloque.id_bloque = bloque.id_bloque
	and construir_cama_bloque.id_cama = cama.id_cama
	order by nave_detalle_realiza_poda_arreglo.id_nave_detalle_realiza_poda_arreglo

	select id_nave_detalle_realiza_poda_arreglo,
	count(id_nave_detalle_realiza_poda_arreglo) as cantidad_camas into #camas_agrupadas
	from #resultado_podas
	group by id_nave_detalle_realiza_poda_arreglo
	order by id_nave_detalle_realiza_poda_arreglo

	select realiza_poda.id_realiza_poda,
	tipo_poda.id_tipo_poda,
	tipo_poda.nombre_tipo_poda,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	cama.id_cama,
	cama.numero_cama,
	nave.id_nave,
	nave.numero_nave,
	estado_variedad_flor.id_estado_variedad_flor as id_estado_variedad_flor_inicial,
	estado_variedad_flor.nombre_estado as nombre_estado_inicial,
	0 as id_estado_variedad_flor_final,
	'' as nombre_estado_final,
	0 as id_persona_area,
	'' as nombre_persona_area,
	'' as idc_persona_area,
	persona.id_persona as id_persona_realiza_poda,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + ltrim(rtrim(persona.identificacion)) + ']' as nombre_persona_realiza_poda,
	persona.idc_persona as idc_persona_realiza_poda,
	realiza_poda.fecha,
	realiza_poda.cantidad_tallos
	from tipo_poda,
	realiza_poda,
	variedad_flor,
	tipo_flor,
	bloque,
	estado_variedad_flor,
	persona,
	detalle_realiza_poda,
	nave,
	cama
	where realiza_poda.id_realiza_poda = detalle_realiza_poda.id_realiza_poda
	and cama.id_cama = detalle_realiza_poda.id_cama
	and nave.id_nave = detalle_realiza_poda.id_nave
	and tipo_poda.id_tipo_poda = realiza_poda.id_tipo_poda
	and variedad_flor.id_variedad_flor = realiza_poda.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and bloque.id_bloque = realiza_poda.id_bloque
	and estado_variedad_flor.id_estado_variedad_flor = realiza_poda.id_estado_variedad_flor
	and persona.id_persona = realiza_poda.id_persona

	union all

	select #resultado_podas.id_nave_detalle_realiza_poda_arreglo,
	#resultado_podas.id_tipo_poda,
	#resultado_podas.nombre_tipo_poda,
	#resultado_podas.id_tipo_flor,
	#resultado_podas.id_variedad_flor,
	#resultado_podas.nombre_tipo_flor,
	#resultado_podas.nombre_variedad_flor,
	#resultado_podas.id_bloque,
	#resultado_podas.idc_bloque,
	#resultado_podas.id_cama,
	#resultado_podas.numero_cama,
	#resultado_podas.id_nave,
	#resultado_podas.numero_nave,
	#resultado_podas.id_estado_variedad_flor_inicial,
	#resultado_podas.nombre_estado_inicial,
	#resultado_podas.id_estado_variedad_flor_final,
	#resultado_podas.nombre_estado_final,
	#resultado_podas.id_persona_area,
	#resultado_podas.nombre_persona_area,
	#resultado_podas.idc_persona_area,
	#resultado_podas.id_persona_realiza_poda,
	#resultado_podas.nombre_persona_realiza_poda,
	#resultado_podas.idc_persona_realiza_poda,
	#resultado_podas.fecha,
	(convert(decimal(20,4), #resultado_podas.cantidad_tallos)/#camas_agrupadas.cantidad_camas) as cantidad_tallos
	from #resultado_podas,
	#camas_agrupadas
	where #resultado_podas.id_nave_detalle_realiza_poda_arreglo = #camas_agrupadas.id_nave_detalle_realiza_poda_arreglo
	and (#resultado_podas.cantidad_tallos/#camas_agrupadas.cantidad_camas) > 0
	order by bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama,
	nombre_tipo_flor,
	nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	realiza_poda.fecha

	drop table #resultado_podas
	drop table #camas_agrupadas
end
else
if(@accion = 'insertar_realiza_poda')
begin
	insert into realiza_poda (id_variedad_flor, id_bloque, id_tipo_poda, id_estado_variedad_flor, id_persona, fecha, cantidad_tallos)
	values (@id_variedad_flor, @id_bloque, @id_tipo_poda, @id_estado_variedad_flor, @id_persona, @fecha, @cantidad_tallos)

	declare @id_realiza_poda_aux int

	set @id_realiza_poda_aux = scope_identity()

	insert into detalle_realiza_poda (id_realiza_poda, id_cama, id_nave)
	values (@id_realiza_poda_aux, @id_cama, @id_nave)
end
else
if(@accion = 'eliminar_realiza_poda')
begin
	delete from	detalle_realiza_poda
	where detalle_realiza_poda.id_realiza_poda = @id_realiza_poda

	select @conteo = count(*)
	from realiza_poda,
	realiza_poda_enfermedad
	where realiza_poda.id_realiza_poda = realiza_poda_enfermedad.id_realiza_poda
	and realiza_poda.id_realiza_poda = @id_realiza_poda

	if(@conteo = 0)
	begin
		delete from realiza_poda
		where id_realiza_poda = @id_realiza_poda
	end
end
else
if(@accion = 'consultar_persona')
begin
	select persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + ' [' + persona.identificacion + ']' as nombre_persona 
	from persona
	where persona.disponible = 1
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