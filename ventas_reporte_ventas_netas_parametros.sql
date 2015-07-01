set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/06/20
-- Description:	Se utiliza para generar el reporte de ventas netas en las comercializadoras
-- =============================================

alter PROCEDURE [dbo].[ventas_reporte_ventas_netas_parametros] 

@fecha_ini datetime,
@fecha_fin datetime,
@tipo_venta_inicial nvarchar(5),
@tipo_venta_final nvarchar(5),
@finca_inicial_fresca nvarchar(2),
@finca_final_fresca nvarchar(2),
@variedad_inicial_fresca nvarchar(4),
@variedad_final_fresca nvarchar(4),
@finca_inicial_natural nvarchar(2),
@finca_final_natural nvarchar(2),
@variedad_inicial_natural nvarchar(4),
@variedad_final_natural nvarchar(4)

as 

drop table reporte_ventas_netas

create table reporte_ventas_netas 
(
	comercializadora nvarchar(50),
	idc_tipo_flor nvarchar(5),
	nombre_tipo_flor nvarchar(100),
	idc_variedad_flor nvarchar(5),
	nombre_variedad_flor nvarchar(100),
	fulles decimal(20,4),
	unidades int,
	total decimal(20,4),
	cargo decimal(20,4)
)

exec bd_fresca.bd_fresca.dbo.ventas_miami_reporte_ventas_netas_fresca

@fecha_inicial = @fecha_ini,
@fecha_final = @fecha_fin,
@idc_finca_inicial = @finca_inicial_fresca,
@idc_finca_final = @finca_final_fresca,
@idc_variedad_flor_inicial = @variedad_inicial_fresca,
@idc_variedad_flor_final = @variedad_final_fresca,
@idc_tipo_venta_inicial = @tipo_venta_inicial,
@idc_tipo_venta_final = @tipo_venta_final


exec bd_nf.bd_nf.dbo.ventas_miami_reporte_ventas_netas_natural

@fecha_inicial = @fecha_ini,
@fecha_final = @fecha_fin,
@idc_tipo_venta_inicial = @tipo_venta_inicial,
@idc_tipo_venta_final = @tipo_venta_final,
@idc_finca_inicial_natural = @finca_inicial_natural,
@idc_finca_final_natural = @finca_final_natural,
@idc_variedad_flor_inicial_natural = @variedad_inicial_natural,
@idc_variedad_flor_final_natural = @variedad_final_natural


select comercializadora,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
fulles,
unidades,
total,
cargo 
from reporte_ventas_netas