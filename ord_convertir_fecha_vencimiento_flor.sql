set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_convertir_fecha_vencimiento_flor]

@fecha_vencimiento_flor nvarchar(255)

AS

declare @fecha_complementaria nvarchar(255)

set @fecha_complementaria = '/12/31'

set @fecha_vencimiento_flor = convert(datetime, @fecha_vencimiento_flor)

set @fecha_vencimiento_flor = convert(nvarchar,datepart(dy,@fecha_vencimiento_flor))+'/'+convert(nvarchar,datepart(dy,convert(nvarchar,datepart(yyyy, @fecha_vencimiento_flor))+@fecha_complementaria)-datepart(dy,@fecha_vencimiento_flor))	

select @fecha_vencimiento_flor as fecha_vencimiento_flor