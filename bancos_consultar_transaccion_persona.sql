SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[bancos_consultar_transaccion_persona] 

@idc_persona_contable nvarchar(255)

AS


select count(*) as existe
from persona_contable,
transaccion_bancaria
where ltrim(rtrim(idc_persona_contable)) = ltrim(rtrim(@idc_persona_contable))
and persona_contable.id_persona_contable = transaccion_bancaria.id_persona_contable