/****** Object:  StoredProcedure [dbo].[gce_log_cuenta_externa]    Script Date: 10/06/2007 11:53:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[gce_log_cuenta_externa]

@id_cuenta_externa int,
@mensaje nvarchar(1024)

AS

INSERT INTO Log_Cuenta_Externa
(
id_cuenta_externa,
mensaje,
fecha
)
VALUES
(
@id_cuenta_externa,
@mensaje,
getdate()
)
