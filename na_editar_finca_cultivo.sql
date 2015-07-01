set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/09
-- Description:	consulta las fincas en el cultivo
-- =============================================

create PROCEDURE [dbo].[na_editar_finca_cultivo] 

@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select finca.id_finca,
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca
	from finca
	order by nombre_finca
end