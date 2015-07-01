set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/09/13
-- Description:	ejecuta el DTS de listas de la comercializadora desde el cultivo
-- =============================================

create PROCEDURE [dbo].[na_ejecutar_dts_listas_comercializadora] 

@comercializadora nvarchar(25)

as

if(@comercializadora = 'Fresca')
begin
	UPDATE [BD_FRESCA].[BD_Fresca].[dbo].[GLOBALES_SQL]
	SET dts_pendiente = 1
end
else
if(@comercializadora = 'Natural')
begin
	UPDATE [BD_NF].[BD_NF].[dbo].[GLOBALES_SQL]
	SET dts_pendiente = 1
end