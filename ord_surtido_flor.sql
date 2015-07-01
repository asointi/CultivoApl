set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_surtido_flor]

@id_flor int,
@id_caja int,
@id_cliente_pedido int

as

select surtido_flor.id_surtido_flor, 
convert(nvarchar,surtido_flor.numero_surtido) + space(1) + '(' + convert(nvarchar,sum(item_surtido_flor.cantidad_ramos)) + space(1) + 'ramos' + ')' as numero_surtido 
from surtido_flor,
flor,
version_surtido_flor,
item_surtido_flor, 
version_surtido_flor as v1,
cliente_despacho,
cliente_pedido
where surtido_flor.id_flor = flor.id_flor
and flor.id_flor = @id_flor
and surtido_flor.id_caja = @id_caja
and surtido_flor.id_cliente_despacho = cliente_despacho.id_cliente_despacho
and cliente_despacho.id_cliente_despacho = cliente_pedido.id_cliente_despacho
and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
and surtido_flor.disponible = 1
and flor.surtido = 1
and version_surtido_flor.id_surtido_flor = surtido_flor.id_surtido_flor
and version_surtido_flor.id_surtido_flor = item_surtido_flor.id_surtido_flor
and version_surtido_flor.id_version_surtido_flor = item_surtido_flor.id_version_surtido_flor
and version_surtido_flor.id_version_surtido_flor <= v1.id_version_surtido_flor
and version_surtido_flor.id_surtido_flor = v1.id_surtido_flor
group by surtido_flor.id_surtido_flor, 
surtido_flor.numero_surtido, 
version_surtido_flor.id_version_surtido_flor
having version_surtido_flor.id_version_surtido_flor = max(v1.id_version_surtido_flor)
order by surtido_flor.numero_surtido 


