SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[prod_generar_reporte_TV_tablero_tiempo_faltante]

AS

select dato, convert(int,replace(valor, ',', '')) as valor
from pantalla_TV_tablero9
where tipo_dato = 'Entradas'
and dato = 'Falta'
union all 
select dato, convert(int,replace(valor, ',', ''))
from pantalla_TV_tablero9
where tipo_dato = 'Ramos_Despatados'
and dato = '30 mi'
union all 
select dato, convert(int,replace(valor, ',', ''))
from pantalla_TV_tablero9
where tipo_dato = 'Ramos_Despatados'
and dato = '60 mi'

