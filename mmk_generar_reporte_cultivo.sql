set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[mmk_generar_reporte_cultivo] 

@idc_cliente_despacho_cultivo nvarchar(25),
@fecha_inicial_cultivo datetime,
@fecha_final_cultivo datetime,
@accion_cultivo nvarchar(25)

as

exec bd_fresca.bd_fresca.dbo.mmk_generar_reporte
	@idc_cliente_despacho = @idc_cliente_despacho_cultivo,
	@fecha_inicial = @fecha_inicial_cultivo,
	@fecha_final = @fecha_final_cultivo,
	@accion = @accion_cultivo