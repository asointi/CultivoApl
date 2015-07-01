/****** Object:  StoredProcedure [dbo].[wbl_seleccionar_usuario_farm]    Script Date: 10/06/2007 12:54:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_seleccionar_usuario_farm]

@usuario NVARCHAR(255)

AS
BEGIN

SELECT farm
FROM usuario_farm
WHERE usuario = @usuario

END
