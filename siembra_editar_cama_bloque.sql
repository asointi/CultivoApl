set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[siembra_editar_cama_bloque]

@id_bloque int,
@id_cama int,
@id_nave nvarchar(255),
@id_construir_cama_bloque int,
@id_cuenta_interna int, 
@fecha datetime, 
@largo decimal(20,4), 
@ancho decimal(20,4),
@@control int output,
@accion nvarchar(255)

as

declare @id_item int,
@conteo int

if(@id_nave is null)
	set @id_nave = '%%'

if(@accion = 'consultar')
begin
	select construir_cama_bloque.id_construir_cama_bloque,
	nave.id_nave,
	nave.numero_nave,
	cama.numero_cama,
	cama.id_cama,
	construir_cama_bloque.fecha, 
	construir_cama_bloque.largo,
	construir_cama_bloque.ancho
	from bloque,
	cama_bloque,
	construir_cama_bloque,
	cama,
	nave
	where bloque.id_bloque = @id_bloque
	and nave.id_nave like @id_nave
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama.id_cama = cama_bloque.id_cama
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and not exists
	(select * from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque)
	order by nave.numero_nave,
	cama.numero_cama
end
else
if(@accion = 'eliminar')
begin
	/*verifica si la cama tiene siembras actualmente*/
	select @conteo = count(*)
	from sembrar_cama_bloque,
	construir_cama_bloque	
	where construir_cama_bloque.id_construir_cama_bloque = @id_construir_cama_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	/*si no tiene siembras se procede a la eliminación de los datos*/	
	if(@conteo = 0)
	begin
		delete from construir_cama_bloque
		where construir_cama_bloque.id_construir_cama_bloque = @id_construir_cama_bloque

		set @@control = 1
		return @@control 
	end
	/*si tiene siembras se informa al usuario para que erradique la siembra actual*/
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'insertar')
begin
	/*se verifica si esta creado para el bloque la cama en cuestión*/
	select @conteo = count(*)
	from cama,
	nave,
	cama_bloque,
	construir_cama_bloque 
	where cama.id_cama = @id_cama
	and nave.id_nave = convert(int,@id_nave)
	and cama.id_cama = cama_bloque.id_cama
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_bloque = @id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque 

	/*si no esta creada la cama para el bloque, se procede a la creación de los datos*/
	if(@conteo = 0)
	begin
		select @conteo = count(*)
		from cama,
		cama_bloque,
		nave
		where cama.id_cama = @id_cama
		and nave.id_nave = convert(int, @id_nave)
		and cama.id_cama = cama_bloque.id_cama
		and nave.id_nave = cama_bloque.id_nave
		and cama_bloque.id_bloque = @id_bloque
		
		if(@conteo = 0)
		begin
			insert into cama_bloque (id_cama, id_nave, id_bloque, id_cuenta_interna)
			select @id_cama, @id_nave, @id_bloque, @id_cuenta_interna
			
			set @id_item = scope_identity()

			insert into construir_cama_bloque (id_cama, id_nave, id_bloque, id_cuenta_interna, fecha, largo, ancho)
			select cama_bloque.id_cama, cama_bloque.id_nave, cama_bloque.id_bloque, @id_cuenta_interna, @fecha, @largo, @ancho
			from cama_bloque
			where cama_bloque.id_cama_bloque = @id_item
		end
		else
		begin
			insert into construir_cama_bloque (id_cama, id_nave, id_bloque, id_cuenta_interna, fecha, largo, ancho)
			select cama_bloque.id_cama, cama_bloque.id_nave, cama_bloque.id_bloque, @id_cuenta_interna, @fecha, @largo, @ancho
			from cama_bloque,
			cama,
			nave
			where cama_bloque.id_bloque = @id_bloque
			and cama_bloque.id_cama = cama.id_cama
			and cama.id_cama = @id_cama
			and nave.id_nave = cama_bloque.id_nave
			and nave.id_nave = @id_nave
		end

		set @@control = 1
		return @@control 
	end
	else
	begin
		/*se verifica la cantidad de mismas camas se han creado para el mismo bloque*/
		select @conteo = count(*)
		from cama,
		cama_bloque,
		construir_cama_bloque,
		nave
		where cama.id_cama = @id_cama
		and nave.id_nave = convert(int,@id_nave)
		and nave.id_nave = cama_bloque.id_nave
		and cama_bloque.id_nave = construir_cama_bloque.id_nave
		and cama.id_cama = cama_bloque.id_cama
		and cama_bloque.id_bloque = @id_bloque
		and cama_bloque.id_cama = construir_cama_bloque.id_cama
		and cama_bloque.id_bloque = construir_cama_bloque.id_bloque

		/*se verifica la cantidad de mismas camas se han destruido para el mismo bloque*/
		select @id_item = count(*)
		from cama,
		cama_bloque,
		construir_cama_bloque,
		destruir_cama_bloque,
		nave
		where cama.id_cama = @id_cama
		and nave.id_nave = convert(int, @id_nave)
		and nave.id_nave = cama_bloque.id_nave
		and cama_bloque.id_nave = construir_cama_bloque.id_nave
		and cama.id_cama = cama_bloque.id_cama
		and cama_bloque.id_bloque = @id_bloque
		and cama_bloque.id_cama = construir_cama_bloque.id_cama
		and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
		and construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque
		/*si el número concuerda (no hay destrucciones pendientes) se permitirá la creación de la cama*/
		if(@conteo = @id_item)
		begin
			insert into construir_cama_bloque (id_cama, id_nave, id_bloque, id_cuenta_interna, fecha, largo, ancho)
			select cama_bloque.id_cama, cama_bloque.id_nave, cama_bloque.id_bloque, @id_cuenta_interna, @fecha, @largo, @ancho
			from cama_bloque,
			cama,
			nave
			where cama_bloque.id_bloque = @id_bloque
			and cama_bloque.id_cama = cama.id_cama
			and cama.id_cama = @id_cama
			and nave.id_nave = convert(int, @id_nave)
			and nave.id_nave = cama_bloque.id_nave

			set @@control = 1
			return @@control 
		end
		/*existen destrucciones pendientes, se informará al usuario*/
		else
		begin
			set @@control = -3
			return @@control 
		end
	end
end