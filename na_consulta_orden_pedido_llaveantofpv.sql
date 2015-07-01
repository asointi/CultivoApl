--Create table [Log_Orden_Pedido_Padre]
--(
--	[id_log_orden_pedido_padre] Int Identity(1,1) NOT NULL,
--	[idc_orden_pedido] Nvarchar(255) NULL,
--	[id_orden_pedido_padre] Integer NULL,
--	[id_orden_pedido] Integer NULL,
--	[id_orden_pedido_maxima] Integer NULL,
--	[resultado] Integer NULL,
--Primary Key ([id_log_orden_pedido_padre])
--) 


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_consulta_orden_pedido_llaveantofpv]

@idc_orden_pedido nvarchar(20)

as

declare @id_orden_pedido int,
@id_orden_pedido_ingresada int,
@id_orden_pedido_padre int,
@resultado int

select @id_orden_pedido_padre = id_orden_pedido_padre,
@id_orden_pedido_ingresada = id_orden_pedido
from orden_pedido
where convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido)

select @id_orden_pedido = max(id_orden_pedido)
from orden_pedido,
tipo_factura
where id_orden_pedido_padre = @id_orden_pedido_padre
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura <> '7'

if(@id_orden_pedido is null)
begin
	set @resultado = -1
end
else
if(@id_orden_pedido = @id_orden_pedido_padre)
begin
	set @resultado = 0
end
else
if(@id_orden_pedido_ingresada < @id_orden_pedido)
begin
	set @resultado = 1
end
else
if(@id_orden_pedido_ingresada > = @id_orden_pedido)
begin
	set @resultado = 0
end

insert into Log_Orden_Pedido_Padre (idc_orden_pedido, id_orden_pedido_padre, id_orden_pedido, id_orden_pedido_maxima, resultado)
values (@idc_orden_pedido, @id_orden_pedido_padre, @id_orden_pedido_ingresada, @id_orden_pedido, @resultado)

select @resultado as resultado