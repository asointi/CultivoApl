set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[siembra_editar_erradicar_cama]

@id_sembrar_cama_bloque int, 
@id_bloque int,
@id_nave nvarchar(255),
@id_cuenta_interna int, 
@fecha datetime, 
@@control int output,
@accion nvarchar(255)

as

declare @conteo int

if(@id_nave is null)
	set @id_nave = '%%'

if(@accion = 'consultar')
begin
	select sembrar_cama_bloque.id_sembrar_cama_bloque,
	nave.numero_nave,
	cama.numero_cama,
	sembrar_cama_bloque.fecha,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + ' - ' + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	sembrar_cama_bloque.cantidad_matas
	from bloque,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	cama,
	tipo_flor,
	variedad_flor,
	nave
	where nave.id_nave like @id_nave
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and bloque.id_bloque = @id_bloque
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama.id_cama = cama_bloque.id_cama
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and not exists	
	(
		select * from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	order by nave.numero_nave,
	cama.numero_cama
end
else
if(@accion = 'insertar')
begin
	insert into erradicar_cama_bloque (id_sembrar_cama_bloque, fecha, id_cuenta_interna)
	values (@id_sembrar_cama_bloque, @fecha, @id_cuenta_interna)
	
	set @@control = 1
	return @@control 
end
else
if(@accion = 'erradicar_bloque')
begin
	select @conteo = count(*)
	from bloque,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	cama,
	tipo_flor,
	variedad_flor,
	nave
	where nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and bloque.id_bloque = @id_bloque
	and sembrar_cama_bloque.fecha > @fecha
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama.id_cama = cama_bloque.id_cama
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and not exists	
	(
		select * from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)	

	if(@conteo = 0)
	begin
		insert into erradicar_cama_bloque (id_sembrar_cama_bloque, id_cuenta_interna, fecha)
		select sembrar_cama_bloque.id_sembrar_cama_bloque,
		@id_cuenta_interna,
		@fecha
		from bloque,
		cama_bloque,
		construir_cama_bloque,
		sembrar_cama_bloque,
		cama,
		tipo_flor,
		variedad_flor,
		nave
		where nave.id_nave = cama_bloque.id_nave
		and cama_bloque.id_nave = construir_cama_bloque.id_nave
		and bloque.id_bloque = @id_bloque
		and bloque.id_bloque = cama_bloque.id_bloque
		and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
		and cama_bloque.id_cama = construir_cama_bloque.id_cama
		and cama.id_cama = cama_bloque.id_cama
		and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
		and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
		and not exists	
		(
			select * from erradicar_cama_bloque
			where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
		)

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end