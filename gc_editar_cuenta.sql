/****** Object:  StoredProcedure [dbo].[gc_editar_cuenta]    Script Date: 10/06/2007 11:23:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_editar_cuenta]

@accion nvarchar(50),
@id_cuenta_interna int,
@cuenta nvarchar(255),
@nombre nvarchar(255),
@clave_hash nvarchar(255),
@aleatorio nvarchar(255),
@esta_activo bit,
@acceso_externo bit,
@correo nvarchar(255),
@telefono nvarchar(255),
@observacion ntext,
@debe_cambiar_clave bit,
@fecha_expiracion_clave datetime,
@id_periodo_expiracion_password int,
@id_usuario int

AS

DECLARE @mensaje nvarchar(255)
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO cuenta_interna
	(
	cuenta,
	nombre,
	fecha_creacion,
	clave_hash,
	aleatorio,
	esta_activo,
	acceso_externo,
	correo,
	telefono,
	observacion,
	debe_cambiar_clave_prox_login,
	fecha_expiracion_clave,
	id_periodo_expiracion_password
	)
	VALUES(
	@cuenta,
	@nombre,
	getdate(),
	@clave_hash,
	@aleatorio,
	@esta_activo,
	@acceso_externo,
	@correo,
	@telefono,
	@observacion,
	@debe_cambiar_clave,
	@fecha_expiracion_clave,
	@id_periodo_expiracion_password
	)

	return scope_identity()
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE cuenta_interna
	SET	cuenta = @cuenta,
		nombre = @nombre,
		esta_activo = @esta_activo,
		acceso_externo = @acceso_externo,
		correo = @correo,
		telefono = @telefono,
		observacion = @observacion,
		debe_cambiar_clave_prox_login = @debe_cambiar_clave,
		fecha_expiracion_clave=	@fecha_expiracion_clave,
		id_periodo_expiracion_password = @id_periodo_expiracion_password
	WHERE id_cuenta_interna = @id_cuenta_interna
END

ELSE IF @accion = 'eliminar'
BEGIN
   	DECLARE @nombre_c nvarchar(255)
	SELECT @nombre_c = nombre 
	FROM cuenta_interna WHERE id_cuenta_interna = @id_cuenta_interna
       
	DELETE cuenta_interna
	WHERE id_cuenta_interna = @id_cuenta_interna
END
