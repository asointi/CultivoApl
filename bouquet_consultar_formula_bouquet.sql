USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_formula_bouquet]    Script Date: 20/08/2014 9:51:31 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/29
-- Description:	Trae informacion de recetas de solicitudes de Bouquets desde las comercializadoras
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_consultar_formula_bouquet] 

@accion nvarchar(255),
@id_solicitud_confirmacion_cultivo int,
@idc_farm nvarchar(2)

as

if(@accion = 'consultar_adicionales')
begin
	exec bd_fresca.bd_fresca.dbo.bouquet_consultar_adicionales_desde_cultivo
	@id_solicitud_confirmacion_cultivo_aux = @id_solicitud_confirmacion_cultivo,
	@idc_farm_aux = @idc_farm
end
else
if(@accion = 'consultar_recetas')
begin
	exec bd_fresca.bd_fresca.dbo.bouquet_consultar_formulas_desde_cultivo
	@id_solicitud_confirmacion_cultivo_aux = @id_solicitud_confirmacion_cultivo,
	@idc_farm_aux = @idc_farm
end