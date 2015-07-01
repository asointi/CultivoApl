SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_log_orden_pedido]

@idc_orden_pedido nvarchar(20),
@usuario_cobol nvarchar(50),
@accion nvarchar(50),
@fecha_inicial datetime,
@fecha_final datetime

as

if(@accion = 'insertar')
begin
	begin try
		insert into log_orden_pedido (usuario_cobol, idc_orden_pedido)
		values (@usuario_cobol, @idc_orden_pedido)

		select 1 as resultado
	end try
	begin catch
		select -1 as resultado
	end catch
end
else
if(@accion = 'consultar')
begin
	select log_orden_pedido.id_log_orden_pedido,
	log_orden_pedido.idc_orden_pedido,
	log_orden_pedido.usuario_cobol,
	log_orden_pedido.fecha_transaccion
	from log_orden_pedido
	where convert(int,idc_orden_pedido) > =
	case
		when @idc_orden_pedido = '' then 0 
		else convert(int,@idc_orden_pedido)
	end
	and convert(int,idc_orden_pedido) < =
	case
		when @idc_orden_pedido = '' then 999999999 
		else convert(int,@idc_orden_pedido)
	end
	and convert(datetime,convert(nvarchar, fecha_transaccion, 101)) between
	@fecha_inicial and @fecha_final
	order by log_orden_pedido.fecha_transaccion
end