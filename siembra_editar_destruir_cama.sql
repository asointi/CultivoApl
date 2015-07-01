set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[siembra_editar_destruir_cama]

@id_construir_cama_bloque int,
@id_bloque int,
@id_nave nvarchar(255),
@id_cuenta_interna int, 
@fecha datetime, 
@@control int output,
@accion nvarchar(255)

as

if(@id_nave is null)
	set @id_nave = '%%'

if(@accion = 'consultar')
begin
	select construir_cama_bloque.id_construir_cama_bloque,
	nave.numero_nave,
	cama.numero_cama,
	max(erradicar_cama_bloque.fecha) as fecha
	from bloque,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	cama,
	tipo_flor,
	variedad_flor,
	erradicar_cama_bloque,
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
	and sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and not exists
	(
		select * from destruir_cama_bloque
		where construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque
	) 
	and not exists
	(
		select * from sembrar_cama_bloque
		where construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
		and not exists
		(
			select * from erradicar_cama_bloque
			where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
		)
	)
	group by construir_cama_bloque.id_construir_cama_bloque,
	nave.numero_nave,
	cama.numero_cama
	order by nave.numero_nave,
	cama.numero_cama
end
else
if(@accion = 'insertar')
begin
	insert into destruir_cama_bloque (id_construir_cama_bloque, id_cuenta_interna, fecha)
	values (@id_construir_cama_bloque, @id_cuenta_interna, @fecha)
	
	set @@control = 1
	return @@control 
end