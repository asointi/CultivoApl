/****** Object:  StoredProcedure [dbo].[gc_log_cuenta_interna]    Script Date: 10/06/2007 11:38:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_log_cuenta_interna]

@id_cuenta_interna int,
@mensaje nvarchar(255)

AS

INSERT INTO Log_Cuenta_Interna
(
id_cuenta_interna,
mensaje,
fecha
)
VALUES(
@id_cuenta_interna,
@mensaje,
getdate()
)

