/****** Object:  StoredProcedure [dbo].[bouquet_consultar_fecha_vuelo]    Script Date: 05/12/2014 10:56:36 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/13
-- Description:	consultar la informacion de fecha de vuelo
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_consultar_fecha_vuelo] 

@fecha datetime,
@id_farm int = null,
@accion nvarchar(255) = null

as

set language spanish

if(@accion is null)
begin
	select [dbo].[calcular_dia_vuelo_mass_market] (@fecha, 'ZW') as fecha
end
else
if(@accion = 'consultar_fecha_por_finca')
begin
	declare @idc_farm nvarchar(2)

	select @idc_farm = idc_farm
	from farm
	where id_farm = @id_farm

	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-7, @idc_farm)) as fecha into #fechas
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-6, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-5, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-4, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-3, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-2, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha-1, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+1, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+2, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+3, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+4, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+5, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+6, @idc_farm))
	union all
	select datepart(dw,[dbo].[calcular_dia_vuelo_mass_market] (@fecha+7, @idc_farm))

	select fecha
	from #fechas
	group by fecha
	order by fecha

	drop table #fechas
end