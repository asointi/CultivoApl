/****** Object:  StoredProcedure [dbo].[wbl_agregar_usuario]    Script Date: 10/06/2007 12:26:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[wbl_agregar_usuario]

@usuario NVARCHAR(255),
@nombre NVARCHAR(255),
@password NVARCHAR(255),
@salt NVARCHAR(255)

AS

DECLARE @impresora nvarchar(255)

select @impresora = id_impresora 
from impresora 
where codigo_impresora = 'ZPL_WINPRINT'

INSERT INTO Usuarios (usuario, nombre, password, salt, id_impresora) 
VALUES (@usuario, @nombre, @password, @salt, @impresora)