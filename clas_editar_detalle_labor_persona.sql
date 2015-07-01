set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 05/10/2009
-- =============================================

alter PROCEDURE [dbo].[clas_editar_detalle_labor_persona] 

@idc_labor nvarchar(2),
@idc_detalle_labor nvarchar(10),
@idc_persona nvarchar(10),
@fecha nvarchar(15),
@hora nvarchar(15),
@comentario nvarchar(512)

AS

if(len(@hora) = 7)
	set @hora = '0' + @hora

select @hora = substring(@hora, 1,2) + ':' +
substring(@hora, 3,2) + ':' +
substring(@hora, 5,2) + ':' +
substring(@hora, 7,2)

insert into detalle_labor_persona (id_detalle_labor, id_persona, fecha, comentario)
select  detalle_labor.id_detalle_labor, 
persona.id_persona, 
convert(datetime,@fecha) + cast(@hora as datetime),
@comentario
from labor,
detalle_labor,
persona
where labor.idc_labor = @idc_labor
and detalle_labor.idc_detalle_labor = @idc_detalle_labor
and persona.idc_persona = @idc_persona
and labor.id_labor = detalle_labor.id_labor