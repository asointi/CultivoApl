set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_bloque]

@accion nvarchar(255),
@numero_item int,
@id_cuenta_interna int,
@@control int output

as

declare @conteo int

if(@accion = 'consultar_nave')
begin
	select nave.id_nave,
	nave.numero_nave,
	nave.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta
	from nave,
	cuenta_interna
	where cuenta_interna.id_cuenta_interna = nave.id_cuenta_interna
	order by nave.numero_nave
end
else
if(@accion = 'consultar_cama')
begin
	select cama.id_cama,
	cama.numero_cama,
	cama.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta 
	from cama,
	cuenta_interna
	where cuenta_interna.id_cuenta_interna = cama.id_cuenta_interna
	order by cama.numero_cama
end
else
if(@accion = 'insertar_nave')
begin
	select @conteo = count(*) from nave
	where nave.numero_nave = @numero_item
	
	if(@conteo = 0)
	begin
		insert into nave (numero_nave, id_cuenta_interna)
		values (@numero_item, @id_cuenta_interna)

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'insertar_cama')
begin
	select @conteo = count(*) from cama
	where cama.numero_cama = @numero_item
	
	if(@conteo = 0)
	begin
		insert into cama (numero_cama, id_cuenta_interna)
		values (@numero_item, @id_cuenta_interna)

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'eliminar_nave')
begin
	select @conteo = count(*) 
	from nave,
	cama_bloque
	where nave.numero_nave = @numero_item
	and nave.id_nave = cama_bloque.id_nave
	
	if(@conteo = 0)
	begin
		delete from nave where numero_nave = @numero_item

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'eliminar_cama')
begin
	select @conteo = count(*) 
	from cama,
	cama_bloque
	where cama.numero_cama = @numero_item
	and cama.id_cama = cama_bloque.id_cama
	
	if(@conteo = 0)
	begin
		delete from cama where numero_cama = @numero_item

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
if(@accion = 'consultar_bloque')
begin
	select id_bloque,
	idc_bloque
	from bloque
	where disponible = 1
	order by idc_bloque
end