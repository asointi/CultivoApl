set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_ejecucion_dts_trx_desde_cultivo]

AS

exec bd_fresca.bd_fresca.dbo.na_consultar_ejecucion_dts_trx