/****** Object:  StoredProcedure [dbo].[gce_editar_cuenta]    Script Date: 10/06/2007 11:42:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[gce_editar_cuenta]
@accion nvarchar(50),
@id_cuenta_externa int,
@cuenta nvarchar(255),
@nombre nvarchar(255),
@clave_hash nvarchar(255),
@aleatorio nvarchar(255),
@esta_activo bit,
@correo nvarchar(255),
@telefono nvarchar(255),
@observacion ntext

AS

DECLARE @mensaje nvarchar(255)
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO cuenta_externa
	(
	cuenta,
	nombre,
	fecha_creacion,
	clave_hash,
	aleatorio,
	esta_activo,
	correo,
	telefono,
	observacion
	)
	VALUES(
	@cuenta,
	@nombre,
	getdate(),
	@clave_hash,
	@aleatorio,
	@esta_activo,
	@correo,
	@telefono,
	@observacion
	)

END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE cuenta_externa
	SET	cuenta = @cuenta,
		nombre = @nombre,
		esta_activo = @esta_activo,
		correo = @correo,
		telefono = @telefono,
		observacion = @observacion
	WHERE id_cuenta_externa = @id_cuenta_externa
END

ELSE IF @accion = 'eliminar'
BEGIN   
	DELETE cuenta_externa
	WHERE id_cuenta_externa = @id_cuenta_externa
END
