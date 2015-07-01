set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_detalle_labor_persona]

@fecha nvarchar(8), 
@hora nvarchar(8),
@idc_persona nvarchar(25)

as

update detalle_labor_persona
set fecha_lectura = [dbo].[concatenar_fecha_hora_COBOL] (@fecha, @hora)
from persona
where persona.id_persona = detalle_labor_persona.id_persona
and persona.idc_persona = @idc_persona
and convert(datetime,convert(nvarchar,detalle_labor_persona.fecha, 101)) = convert(datetime,@fecha)