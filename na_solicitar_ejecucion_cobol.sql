set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_solicitar_ejecucion_cobol] 

@id int,
@usuario_cobol nvarchar(25),
@accion nvarchar(50),
@utilizado bit = null output
as

if(@accion = 'solicitar_id')
begin
	insert into solicita_ejecucion_cobol (id_usuario_cobol)
	select usuario_cobol.id_usuario_cobol
	from usuario_cobol
	where usuario_cobol.login = @usuario_cobol

	select solicita_ejecucion_cobol.id_solicita_ejecucion_cobol as id,
	usuario_cobol.id_usuario_cobol
	from solicita_ejecucion_cobol,
	usuario_cobol
	where usuario_cobol.id_usuario_cobol = solicita_ejecucion_cobol.id_usuario_cobol
	and solicita_ejecucion_cobol.id_solicita_ejecucion_cobol = @@identity	
end
else
if(@accion = 'validar_id')
begin
	declare @id_solicita_ejecucion_cobol int

	select @id_solicita_ejecucion_cobol = solicita_ejecucion_cobol.id_solicita_ejecucion_cobol,
	@utilizado = solicita_ejecucion_cobol.utilizado
	from solicita_ejecucion_cobol,
	usuario_cobol
	where usuario_cobol.id_usuario_cobol = solicita_ejecucion_cobol.id_usuario_cobol
	and solicita_ejecucion_cobol.id_solicita_ejecucion_cobol = @id

	update solicita_ejecucion_cobol
	set utilizado = 1
	where id_solicita_ejecucion_cobol = @id_solicita_ejecucion_cobol

	if(@utilizado is null)
		set @utilizado = 1

	return
end