set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[siembra_editar_conteo_tallo]

@id_cuenta_interna int, 
@id_sembrar_cama_bloque int, 
@cantidad_matas int, 
@fecha_conteo datetime,
@accion nvarchar(255)

AS

declare @conteo int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from conteo_tallo
	where conteo_tallo.id_cuenta_interna = @id_cuenta_interna
	and conteo_tallo.id_sembrar_cama_bloque = @id_sembrar_cama_bloque
	and conteo_tallo.cantidad_matas = @cantidad_matas
	and conteo_tallo.fecha_conteo = @fecha_conteo

	if(@conteo = 0)
	begin 
		insert into conteo_tallo (id_cuenta_interna, id_sembrar_cama_bloque, cantidad_matas, fecha_conteo)
		values (@id_cuenta_interna, @id_sembrar_cama_bloque, @cantidad_matas, @fecha_conteo)
	end
end
else
if(@accion = 'consultar')
begin
	select top 1 cuenta_interna.nombre as nombre_cuenta,
	conteo_tallo.cantidad_matas,
	conteo_tallo.fecha_conteo,
	conteo_tallo.fecha_transaccion
	from conteo_tallo,
	sembrar_cama_bloque,
	cuenta_interna
	where sembrar_cama_bloque.id_sembrar_cama_bloque = conteo_tallo.id_sembrar_cama_bloque
	and cuenta_interna.id_cuenta_interna = conteo_tallo.id_cuenta_interna
	and sembrar_cama_bloque.id_sembrar_cama_bloque = @id_sembrar_cama_bloque
	order by conteo_tallo.fecha_conteo desc
end