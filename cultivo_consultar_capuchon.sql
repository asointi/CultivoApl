set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[cultivo_consultar_capuchon]

AS

SELECT id_capuchon,
idc_capuchon,
descripcion,
ancho_superior,
ancho_inferior,
alto,
decorado
FROM capuchon_cultivo 
where disponible = 1
ORDER BY descripcion
