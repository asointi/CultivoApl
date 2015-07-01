set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_llaveantofpv_proceso_automatico]

@idc_orden_pedido_padre nvarchar(20),
@idc_orden_pedido nvarchar(20)

as

declare @id_orden_pedido int,
@id_orden_pedido_padre_original int,
@id_orden_pedido_maxima int

select @id_orden_pedido = id_orden_pedido
from orden_pedido
where convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido)

select @id_orden_pedido_padre_original = id_orden_pedido
from orden_pedido
where convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido_padre)

select @id_orden_pedido_maxima = max(id_orden_pedido)
from orden_pedido
where id_orden_pedido_padre = @id_orden_pedido_padre_original
and id_orden_pedido <> @id_orden_pedido

if(@id_orden_pedido_padre_original < @id_orden_pedido_maxima)
begin
	declare @subject1 nvarchar(255)
	
	set @subject1 = 'La LlaveAntOfpv: ' + convert(nvarchar,@idc_orden_pedido_padre) + ' ha sido utilizada en más de una ocasión'

	EXEC msdb.dbo.sp_send_dbmail 
		@recipients = 'dpineros@natuflora.net;juancvc@natuflora.net',--'dpineros@natuflora.net;carlos@natuflora.net;ricardo@natuflora.net;juancvc@natuflora.net',
		@subject = @subject1,
		@body =  '',
		@body_format = 'text'
end
