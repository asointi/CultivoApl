set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_estado]

@accion nvarchar(255),
@id_estado int,
@id_pais int

AS

if(@accion = 'actualizar_pais')
begin
	update estado
	set id_pais = @id_pais
	where id_estado = @id_estado

	select 1 as id_estado
end