/****** Object:  StoredProcedure [dbo].[gc_cambiar_clave_de_cuenta]    Script Date: 10/06/2007 11:21:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_cambiar_clave_de_cuenta]

@id_cuenta_interna int,
@clave_hash nvarchar(255),
@aleatorio nvarchar(255),
@id_usuario int

AS

DECLARE @mensaje nvarchar(255)    

UPDATE cuenta_interna
SET clave_hash = @clave_hash,
aleatorio = @aleatorio
WHERE id_cuenta_interna = @id_cuenta_interna
