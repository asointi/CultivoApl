set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[editar_persona] 
	@numero_identificacion int,
	@nombres nvarchar(50),
	@apellidos nvarchar(50),
	@id_estado int,
	@id_identificacion int,
	@accion nvarchar(30)	

AS
declare @Registros int

if (@accion = 'no_asignado')
begin
	select per.id_persona, (per.nombres + ' ' + per.apellidos) AS nombre
	from Persona as per, Estado_Persona as est, Tipo_Identificacion as tip
	where est.id_estado = per.id_estado
	AND tip.id_identificacion = per.id_identificacion
	AND per.id_estado = 2
end

if (@accion = 'todos')
begin
	select per.numero_identificacion, per.nombres, per.apellidos,
	est.estado, tip.tipo
	from Persona as per, Estado_Persona as est, Tipo_Identificacion as tip
	where est.id_estado = per.id_estado
	AND tip.id_identificacion = per.id_identificacion
end

if(@accion = 'insertar')
begin
	select @Registros = count(*)
	from Persona
	where ltrim(rtrim(nombres)) = ltrim(rtrim(@nombres))
	and ltrim(rtrim(numero_identificacion)) = ltrim(rtrim(@numero_identificacion))

	if(@Registros = 0)
	begin
		insert into Persona (numero_identificacion, nombres, apellidos, id_estado, id_identificacion)
		values (@numero_identificacion, @nombres, @apellidos, @id_estado, @id_identificacion)
		select 1 as ins
	end
	else
	begin
		select -1 as persona_existe
	end
end

if(@accion = 'eliminar')
begin
	delete from Persona
end