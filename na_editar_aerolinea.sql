SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[na_editar_aerolinea]

AS

SELECT *
FROM aerolinea
ORDER BY nombre_aerolinea