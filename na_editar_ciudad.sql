set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ciudad]

@accion nvarchar(255),
@id_ciudad int,
@id_pais int

AS

if(@accion = 'actualizar_pais')
begin
	update ciudad
	set id_pais = @id_pais
	where id_ciudad = @id_ciudad

	select 1 as id_ciudad
end