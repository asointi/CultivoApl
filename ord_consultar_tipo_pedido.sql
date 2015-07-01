set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_consultar_tipo_pedido]


as 

select tipo_pedido.id_tipo_pedido, 
'[' + tipo_pedido.idc_tipo_pedido + ']' + space(1) + tipo_pedido.nombre_tipo_pedido as nombre_tipo_pedido
from tipo_pedido
order by tipo_pedido.idc_tipo_pedido




