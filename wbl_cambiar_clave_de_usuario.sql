/****** Object:  StoredProcedure [dbo].[wbl_cambiar_clave_de_usuario]    Script Date: 10/06/2007 12:29:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_cambiar_clave_de_usuario]

@id_usuarios int,
@password nvarchar(255),
@salt nvarchar(50)

AS

UPDATE usuarios
SET password = @password,
salt = @salt
WHERE id_usuarios = @id_usuarios
