set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/09/06
-- Description:	Maneja todo lo relacionado con las personas responsables de Weblabels
-- =============================================

create PROCEDURE [dbo].[wbl_editar_persona_etiqueta] 

@accion nvarchar(255),
@nombre_persona nvarchar(255),
@correo nvarchar(255),
@msn nvarchar(255),
@telefono_fijo1 nvarchar(255),
@telefono_fijo2 nvarchar(255),
@telefono_movil nvarchar(255),
@activo bit,
@id_persona_etiqueta int

as

if(@accion = 'consultar_persona')
begin
	select id_persona_etiqueta,
	nombre_persona,
	correo,
	msn,
	telefono_fijo1,
	telefono_fijo2,
	telefono_movil,
	case
		when (
			select persona_etiqueta_activa
			from configuracion_bd
			where configuracion_bd.persona_etiqueta_activa = Persona_Etiqueta.id_Persona_Etiqueta
			) is null then 0
		else 1
	end as activo
	from Persona_Etiqueta
	order by nombre_persona
end
else
if(@accion = 'consultar_persona_activa')
begin
	select id_persona_etiqueta,
	nombre_persona,
	correo,
	msn,
	telefono_fijo1,
	telefono_fijo2,
	telefono_movil
	from Persona_Etiqueta,
	configuracion_bd
	where configuracion_bd.persona_etiqueta_activa = Persona_Etiqueta.id_Persona_Etiqueta
end
else
if(@accion = 'modificar_persona')
begin
	update Persona_Etiqueta
	set nombre_persona = @nombre_persona,
	correo = @correo,
	msn = @msn,
	telefono_fijo1 = @telefono_fijo1,
	telefono_fijo2 = @telefono_fijo2,
	telefono_movil = @telefono_movil
	where id_persona_etiqueta = @id_persona_etiqueta

	if(@activo = 1)
	begin
		update configuracion_bd
		set persona_etiqueta_activa = @id_persona_etiqueta
	end
end
else
if(@accion = 'eliminar_persona')
begin
	delete from Persona_Etiqueta
	where id_persona_etiqueta = @id_persona_etiqueta
	and 
	(	
		select persona_etiqueta_activa
		from configuracion_bd
	) <> @id_persona_etiqueta
end
else
if(@accion = 'insertar_persona')
begin
	insert into Persona_Etiqueta (nombre_persona, correo, msn, telefono_fijo1, telefono_fijo2, telefono_movil)
	values (@nombre_persona, @correo, @msn, @telefono_fijo1, @telefono_fijo2, @telefono_movil)

	declare @id_persona_etiqueta_aux int

	set @id_persona_etiqueta_aux = scope_identity()

	if(@activo = 1)
		begin
			update configuracion_bd
			set persona_etiqueta_activa = @id_persona_etiqueta_aux
		end
end