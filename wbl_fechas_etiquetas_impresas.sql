set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[wbl_fechas_etiquetas_impresas]

@usuarioin NVARCHAR(255),
@farmin NVARCHAR(255)

AS

SELECT distinct 
convert(nvarchar,fecha,111)+ ' ' + convert(nvarchar,fecha,8) as fecha, 
count(*) as piezas, 
DATEPART (dw , fecha)
FROM etiqueta
WHERE farm = @farmin 
AND usuario = @usuarioin 
AND (convert(datetime, convert(nvarchar, fecha, 111), 111) > = convert(datetime, convert(nvarchar, getdate()-10, 111), 111))
GROUP BY fecha
ORDER BY fecha DESC

