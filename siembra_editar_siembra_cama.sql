set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[siembra_editar_siembra_cama]

@id_bloque int,
@id_nave nvarchar(255),
@id_construir_cama_bloque int,
@id_cuenta_interna int, 
@id_variedad_flor int,
@cantidad_matas int,
@fecha datetime, 
@@control int output,
@accion nvarchar(255)

as

if(@id_nave is null)
	set @id_nave = '%%'

declare @conteo int,
@fecha_erradicacion datetime

if(@accion = 'consultar_edicion')
begin
	select construir_cama_bloque.id_construir_cama_bloque,
	nave.numero_nave,
	cama.numero_cama,
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
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama.id_cama = cama_bloque.id_cama
	and not exists	
		(
		select *
		from sembrar_cama_bloque
		where sembrar_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
		and not exists 
			(
			select * from erradicar_cama_bloque
			where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
			)
		)
	and not exists
		(
		select * from destruir_cama_bloque
		where construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque
		)
	order by nave.numero_nave,
	cama.numero_cama
end
else
if(@accion = 'consultar')
begin
	select sembrar_cama_bloque.id_sembrar_cama_bloque,
	nave.numero_nave,
	cama.numero_cama,
	sembrar_cama_bloque.fecha,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' + ' - ' + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	sembrar_cama_bloque.cantidad_matas,
	(
		select top 1 conteo_tallo.cantidad_matas
		from conteo_tallo
		where sembrar_cama_bloque.id_sembrar_cama_bloque = conteo_tallo.id_sembrar_cama_bloque
		order by conteo_tallo.id_conteo_tallo desc
	) as cantidad_matas_ultimo_conteo,
	(
		select top 1 conteo_tallo.fecha_conteo
		from conteo_tallo
		where sembrar_cama_bloque.id_sembrar_cama_bloque = conteo_tallo.id_sembrar_cama_bloque
		order by conteo_tallo.id_conteo_tallo desc
	) as fecha_ultimo_conteo
	from bloque,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	cama,
	tipo_flor,
	variedad_flor,
	nave
	where bloque.id_bloque = @id_bloque
	and nave.id_nave like @id_nave
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
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
	select @conteo = count(*),
	@fecha_erradicacion = max(erradicar_cama_bloque.fecha)
	from erradicar_cama_bloque, 
	sembrar_cama_bloque
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	and sembrar_cama_bloque.id_construir_cama_bloque = @id_construir_cama_bloque

	if(@conteo = 0)
	begin
		insert into sembrar_cama_bloque (id_cuenta_interna, id_construir_cama_bloque, id_variedad_flor, cantidad_matas, fecha)
		values (@id_cuenta_interna, @id_construir_cama_bloque, @id_variedad_flor, @cantidad_matas, @fecha)
		
		set @@control = 1
		return @@control 
	end
	else
	begin
		if(@fecha > = @fecha_erradicacion)
		begin
			insert into sembrar_cama_bloque (id_cuenta_interna, id_construir_cama_bloque, id_variedad_flor, cantidad_matas, fecha)
			values (@id_cuenta_interna, @id_construir_cama_bloque, @id_variedad_flor, @cantidad_matas, @fecha)
			
			set @@control = 1
			return @@control 
		end
		else
		begin
			set @@control = -3
			return @@control 
		end
	end
end