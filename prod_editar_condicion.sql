set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_condicion]

@id_regla int,
@longitud_minima decimal(20,4),
@longitud_maxima decimal(20,4),
@nombre_condicion nvarchar(255),
@ancho_minimo decimal(20,4),
@ancho_maximo decimal(20,4),
@altura_cabeza_minima decimal(20,4),
@altura_cabeza_maxima decimal(20,4),
@apertura_minima decimal(20,4),
@apertura_maxima decimal(20,4),
@numero_ordenamiento int

as

set @nombre_condicion = replace(@nombre_condicion, '"', '')
set @nombre_condicion = ltrim(rtrim(@nombre_condicion))

declare @id_item int,
@id_item_aux int

select @id_item = count(*)
from regla, condicion
where regla.id_regla = condicion.id_regla
and regla.id_regla = @id_regla
and ltrim(rtrim(condicion.nombre_condicion)) = ltrim(rtrim(@nombre_condicion))

if(@id_item = 0)
begin
	insert into condicion (id_regla, id_grado_flor, nombre_condicion)
	values (@id_regla, null, @nombre_condicion)

	set @id_item = scope_identity()

	insert into detalle_condicion (id_condicion, longitud_minima,ancho_minimo, altura_cabeza_minima, fecha_creacion, longitud_maxima, ancho_maximo, altura_cabeza_maxima, apertura_minima, apertura_maxima, numero_ordenamiento)
	values (@id_item, @longitud_minima, @ancho_minimo, @altura_cabeza_minima, getdate(), @longitud_maxima, @ancho_maximo, @altura_cabeza_maxima, @apertura_minima, @apertura_maxima, @numero_ordenamiento)

	set @id_item_aux = scope_identity()

	insert into tiempo_ejecucion_detalle_condicion (id_tiempo_ejecucion_regla, id_detalle_condicion, fecha_transaccion)
	select max(id_tiempo_ejecucion_regla),  @id_item_aux, getdate()
	from tiempo_ejecucion_regla, 
	tipo_transaccion
	where tiempo_ejecucion_regla.id_regla = @id_regla
	and tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
	and tipo_transaccion.nombre_tipo_transaccion = 'inicio'
end
else 
begin
	select @id_item = condicion.id_condicion
	from regla, condicion
	where regla.id_regla = condicion.id_regla
	and regla.id_regla = @id_regla
	and ltrim(rtrim(condicion.nombre_condicion)) = ltrim(rtrim(@nombre_condicion))

	select @id_item_aux = count(*)
	from condicion,
	detalle_condicion
	where condicion.id_condicion = detalle_condicion.id_condicion
	and condicion.id_condicion = @id_item
	and longitud_minima = @longitud_minima
	and ancho_minimo = @ancho_minimo
	and altura_cabeza_minima = @altura_cabeza_minima
	and longitud_maxima = @longitud_maxima 
	and ancho_maximo = @ancho_maximo 
	and altura_cabeza_maxima = @altura_cabeza_maxima 
	and apertura_minima = @apertura_minima 
	and apertura_maxima = @apertura_maxima 
	and numero_ordenamiento = @numero_ordenamiento 

	if(@id_item_aux = 0)
	begin
		insert into detalle_condicion (id_condicion, longitud_minima,ancho_minimo, altura_cabeza_minima, fecha_creacion, longitud_maxima, ancho_maximo, altura_cabeza_maxima, apertura_minima, apertura_maxima, numero_ordenamiento)
		values (@id_item, @longitud_minima, @ancho_minimo, @altura_cabeza_minima, getdate(), @longitud_maxima, @ancho_maximo, @altura_cabeza_maxima, @apertura_minima, @apertura_maxima, @numero_ordenamiento)

		set @id_item_aux = scope_identity()

		insert into tiempo_ejecucion_detalle_condicion (id_tiempo_ejecucion_regla, id_detalle_condicion, fecha_transaccion)
		select max(id_tiempo_ejecucion_regla), @id_item_aux, getdate()
		from tiempo_ejecucion_regla, 
		tipo_transaccion
		where tiempo_ejecucion_regla.id_regla = @id_regla
		and tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
		and tipo_transaccion.nombre_tipo_transaccion = 'inicio'
	end
	else
	begin
		select @id_item_aux = detalle_condicion.id_detalle_condicion
		from condicion,
		detalle_condicion
		where condicion.id_condicion = detalle_condicion.id_condicion
		and condicion.id_condicion = @id_item
		and longitud_minima = @longitud_minima
		and ancho_minimo = @ancho_minimo
		and altura_cabeza_minima = @altura_cabeza_minima
		and longitud_maxima = @longitud_maxima 
		and ancho_maximo = @ancho_maximo 
		and altura_cabeza_maxima = @altura_cabeza_maxima 
		and apertura_minima = @apertura_minima 
		and apertura_maxima = @apertura_maxima 
		and numero_ordenamiento = @numero_ordenamiento 

		insert into tiempo_ejecucion_detalle_condicion (id_tiempo_ejecucion_regla, id_detalle_condicion, fecha_transaccion)
		select max(id_tiempo_ejecucion_regla), @id_item_aux, getdate()
		from tiempo_ejecucion_regla, 
		tipo_transaccion
		where tiempo_ejecucion_regla.id_regla = @id_regla
		and tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
		and tipo_transaccion.nombre_tipo_transaccion = 'inicio'
	end
end
