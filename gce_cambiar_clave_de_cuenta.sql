/****** Object:  StoredProcedure [dbo].[gce_cambiar_clave_de_cuenta]    Script Date: 10/06/2007 11:41:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gce_cambiar_clave_de_cuenta]

@id_cuenta_externa int,
@clave_hash nvarchar(255),
@aleatorio nvarchar(255)

AS  

UPDATE cuenta_externa
SET clave_hash = @clave_hash,
aleatorio = @aleatorio
WHERE id_cuenta_externa = @id_cuenta_externa
