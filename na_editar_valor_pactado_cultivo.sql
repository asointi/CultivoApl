set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_valor_pactado_cultivo]

@accion nvarchar(255),
@idc_orden_pedido nvarchar(255),
@fecha nvarchar(255),
@valor_pactado decimal(20,4)

AS

if(@accion = 'consultar')
begin
	declare @id_orden_pedido_padre int, @idc_orden_pedido_padre nvarchar(255), @cantidad int
	select @id_orden_pedido_padre = id_orden_pedido, @idc_orden_pedido_padre = idc_orden_pedido 
	from orden_pedido
	where id_orden_pedido = (select id_orden_pedido_padre from orden_pedido where idc_orden_pedido = @idc_orden_pedido)

	select id_orden_pedido into #ordenes
	from orden_pedido
	where id_orden_pedido_padre = @id_orden_pedido_padre

	select @cantidad = count(*)
	from valor_pactado_cultivo
	where id_orden_pedido in (select id_orden_pedido from #ordenes)
	and valor_pactado_cultivo.fecha < = convert(datetime,@fecha)
	group by valor_pactado_cultivo.id_orden_pedido, valor_pactado_cultivo.valor_pactado, valor_pactado_cultivo.fecha

	if(@cantidad > = 1)
	begin
		select top 1 @idc_orden_pedido_padre as idc_orden_pedido, valor_pactado_cultivo.valor_pactado 
		from valor_pactado_cultivo
		where id_orden_pedido in (select id_orden_pedido from #ordenes)
		and valor_pactado_cultivo.fecha < = convert(datetime,@fecha)
		group by valor_pactado_cultivo.id_orden_pedido, valor_pactado_cultivo.valor_pactado, valor_pactado_cultivo.fecha
		order by valor_pactado_cultivo.fecha desc
	end
	else
	begin
		select @idc_orden_pedido_padre as idc_orden_pedido, 0 as valor_pactado
	end
end
else
if(@accion = 'modificar')
begin
declare @conteo int

select @conteo = count(*)
from orden_pedido, valor_pactado_cultivo 
where idc_orden_pedido = @idc_orden_pedido
and orden_pedido.id_orden_pedido = valor_pactado_cultivo.id_orden_pedido
and convert(nvarchar,valor_pactado_cultivo.fecha,101) = convert(nvarchar,convert(datetime,@fecha),101)

	if(@conteo < 1)
	begin
		insert into valor_pactado_cultivo (id_orden_pedido, valor_pactado, fecha)
		select orden_pedido.id_orden_pedido, @valor_pactado, @fecha
		from orden_pedido where idc_orden_pedido = @idc_orden_pedido
	end
	else
	begin
		update valor_pactado_cultivo
		set valor_pactado = @valor_pactado
		from orden_pedido
		where orden_pedido.idc_orden_pedido = @idc_orden_pedido
		and orden_pedido.id_orden_pedido = valor_pactado_cultivo.id_orden_pedido
		and convert(nvarchar,valor_pactado_cultivo.fecha,101) = convert(nvarchar,convert(datetime,@fecha),101)
	end
end
