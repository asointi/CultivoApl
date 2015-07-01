set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/10/10
-- Description:	genera los datos para un reporte comparativo de ventas entre Fresca y Natural
-- =============================================

create PROCEDURE [dbo].[ventas_miami_reporte_precios_por_fecha_desde_cultivo] 

as

drop table Detalle_Facturacion_Dia_Por_Fecha

Create table [Detalle_Facturacion_Dia_Por_Fecha]
(
	[id_detalle_facturacion_dia_por_fecha] Integer Identity(1,1) NOT NULL,
	[comercializadora] Nvarchar(255) NOT NULL,
	[fecha] Datetime NOT NULL,
	[fulles] Decimal(20,4) NOT NULL,
	[unidades] Integer NOT NULL,
	[valor] Decimal(20,4) NOT NULL,
Primary Key ([id_detalle_facturacion_dia_por_fecha])
) 

EXEC BD_FRESCA.BD_FRESCA.DBO.ventas_miami_reporte_precios_por_fecha

EXEC BD_NF.BD_NF.DBO.ventas_miami_reporte_precios_por_fecha

SELECT *
FROM DETALLE_FACTURACION_DIA_POR_FECHA
