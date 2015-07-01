set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[pbinv_consultar_usuario_cobol]

@idc_cuenta nvarchar(255)

AS

BEGIN

select id_cuenta_interna from Cuenta_Interna
where cuenta = @idc_cuenta

END
