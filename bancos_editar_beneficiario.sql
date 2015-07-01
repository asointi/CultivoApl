SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[bancos_editar_beneficiario] 

@accion nvarchar(255)

AS

if(@accion = 'consultar')
begin
	select persona_contable.id_persona_contable,
	persona_contable.idc_persona_contable,
	ltrim(rtrim(persona_contable.nombre_persona)) as nombre_persona,
	persona_contable.direccion,
	persona_contable.telefono 
	from persona_contable
	order by nombre_persona
end

