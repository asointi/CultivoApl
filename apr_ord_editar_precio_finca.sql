set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_editar_precio_finca]

@id_item_orden_sin_aprobar int,
@valor_pactado decimal(20,4)

as

declare @valor_pactado_cobol decimal(20,4),
@nombre_base_datos nvarchar(255)

set @nombre_base_datos = DB_NAME()

if(@nombre_base_datos = 'BD_Fresca')
begin
	select @valor_pactado_cobol = item_orden_sin_aprobar.valor_pactado_cobol
	from item_orden_sin_aprobar
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

	if(@valor_pactado_cobol > @valor_pactado)
	begin
		update item_orden_sin_aprobar
		set valor_pactado_interno = @valor_pactado
		where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
	end
end
else
begin
	update item_orden_sin_aprobar
	set valor_pactado_interno = @valor_pactado
	where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
end