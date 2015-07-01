set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_ejecucion_dts_trx]

AS

declare @fresca nvarchar(50),
@natural nvarchar(50)

set @fresca = 'FRESCA FARMS'
set @natural = 'NATURAL FLOWERS'

select @fresca as comercializadora,
fecha_dts_transaccional as fecha
from configuracion_bd
union all 
select @natural as comercializadora,
fecha_dts_transaccional as fecha
from bd_nf.bd_nf.dbo.configuracion_bd