set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 05/10/2009
-- =============================================

alter PROCEDURE [dbo].[clas_editar_detalle_labor] 

@idc_labor nvarchar(255),
@idc_detalle_labor nvarchar(255),
@nombre_detalle_labor nvarchar(255)

AS

declare @conteo int

select @conteo = count(*) 
from labor, detalle_labor 
where idc_labor = @idc_labor 
and labor.id_labor = detalle_labor.id_labor
and detalle_labor.idc_detalle_labor = @idc_detalle_labor

if(@conteo = 0)
begin
	insert into detalle_labor (id_labor, idc_detalle_labor, nombre_detalle_labor)
	select  labor.id_labor, @idc_detalle_labor, @nombre_detalle_labor
	from labor
	where labor.idc_labor = @idc_labor
end
else
begin
	update detalle_labor
	set nombre_detalle_labor = @nombre_detalle_labor
	where idc_detalle_labor = @idc_detalle_labor
end
