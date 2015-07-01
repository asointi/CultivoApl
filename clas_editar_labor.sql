set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 05/10/2009
-- =============================================

alter PROCEDURE [dbo].[clas_editar_labor] 

@idc_labor nvarchar(255),
@nombre_labor nvarchar(255),
@labor_pagada nvarchar(255)

AS

declare @conteo int

select @conteo = count(*) from labor where idc_labor = @idc_labor

if(@conteo = 0)
begin
	insert into labor (idc_labor, nombre_labor, labor_pagada)
	values (@idc_labor, @nombre_labor, Replace(Replace(@labor_pagada, 'S', 1), 'N', 0))
end
else
begin
	update labor
	set nombre_labor = @nombre_labor,
	labor_pagada = Replace(Replace(@labor_pagada, 'S', 1), 'N', 0)
	where idc_labor = @idc_labor
end
