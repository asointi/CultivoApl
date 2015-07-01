set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_editar_archivo_resultado_mapeo]

@numero_consecutivo int,
@id_cliente_pedido int,
@correo_para nvarchar(255),
@correo_copia nvarchar(1024),
@correo_asunto nvarchar(512),
@correo_body nvarchar(max),
@items_con_error image,
@items_no_mapeados image,
@items_mapeados image,
@archivo_original image,
@accion nvarchar(255)

as

declare @id_archivo_orden_pedido int,
@conteo int

select @id_archivo_orden_pedido = id_archivo_orden_pedido
from archivo_orden_pedido
where id_cliente_pedido = @id_cliente_pedido
and numero_consecutivo = @numero_consecutivo

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from archivo_orden_pedido,
	archivo_resultado_mapeo
	where archivo_orden_pedido.id_archivo_orden_pedido = archivo_resultado_mapeo.id_archivo_orden_pedido
	and archivo_orden_pedido.id_archivo_orden_pedido = @id_archivo_orden_pedido

	if(@conteo = 0)
	begin
		insert into archivo_resultado_mapeo 
		(
			id_archivo_orden_pedido,
			correo_para,
			correo_copia,
			correo_asunto,
			correo_body,
			items_con_error,
			items_no_mapeados,
			items_mapeados,
			archivo_original
		)
		values
		(
			@id_archivo_orden_pedido,
			@correo_para,
			@correo_copia,
			@correo_asunto,
			@correo_body,
			@items_con_error,
			@items_no_mapeados,
			@items_mapeados,
			@archivo_original
		)
	end
end
else
if(@accion = 'consultar')
begin
	select correo_para,
	correo_copia,
	correo_asunto,
	correo_body,
	items_con_error,
	items_no_mapeados,
	items_mapeados,
	archivo_original
	from archivo_resultado_mapeo
	where id_archivo_orden_pedido = @id_archivo_orden_pedido	
end
else
if(@accion = 'consultar_listado')
begin
	select archivo_orden_pedido.numero_consecutivo
	from archivo_orden_pedido,
	archivo_resultado_mapeo,
	cliente_pedido
	where archivo_orden_pedido.id_archivo_orden_pedido = archivo_resultado_mapeo.id_archivo_orden_pedido
	and cliente_pedido.id_cliente_pedido = archivo_orden_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
	order by archivo_orden_pedido.numero_consecutivo
end