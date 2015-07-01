/****** Object:  StoredProcedure [dbo].[wbl_recuperar_usuario]    Script Date: 10/06/2007 12:50:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_recuperar_usuario]

@usuario NVARCHAR(255)

AS

SELECT id_usuarios, 
usuario, 
codigo_impresora, 
nombre, 
password, 
salt
FROM Usuarios, 
Impresora
WHERE usuario = @usuario 
AND Impresora.id_impresora = Usuarios.id_impresora
