/****** Object:  StoredProcedure [dbo].[wbl_eliminar_etiqueta_temp]    Script Date: 10/06/2007 12:39:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_eliminar_etiqueta_temp]

@accion VARCHAR(20),
@idTempFind INT,
@usuario  VARCHAR(255),
@farm VARCHAR(255)

AS

IF(@accion = '1_etiqueta')
BEGIN
	DELETE FROM etiqueta_temp_user
	WHERE idTemp = @idTempFind
END
ELSE 
IF(@accion = 'user_etiquetas')
BEGIN
	DELETE FROM etiqueta_temp_user
	WHERE usuario = @usuario 
	AND farm = @farm 
	AND	unidades_por_caja * cantidad > 0			
END