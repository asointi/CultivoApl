set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[pbinv_precopiar_item]

@id_item_inventario_preventa integer,
@id_temporada_año_origen integer,
@id_temporada_año_destino integer,
@id_cuenta_interna integer,
@copiar_item bit,
@no_copiar_item bit,
@procesado bit

AS

BEGIN

declare @id_item_inventario_preventa_precopia integer
select @id_item_inventario_preventa_precopia = id_item_inventario_preventa_precopia
from item_inventario_preventa_precopia
where id_item_inventario_preventa = @id_item_inventario_preventa
and id_temporada_año_origen = @id_temporada_año_origen
and id_temporada_año_destino = @id_temporada_año_destino
and id_cuenta_interna = @id_cuenta_interna

IF @id_item_inventario_preventa_precopia is null
	BEGIN
		insert into item_inventario_preventa_precopia
			(id_temporada_año_origen
			,id_temporada_año_destino
			,id_item_inventario_preventa
			,id_cuenta_interna
			,copiar_item
			,no_copiar_item
			,procesado)
			values
			(@id_temporada_año_origen
			,@id_temporada_año_destino
			,@id_item_inventario_preventa
			,@id_cuenta_interna
			,@copiar_item
			,@no_copiar_item
			,@procesado)
		
		return scope_identity()
	END
ELSE
	BEGIN
		update item_inventario_preventa_precopia
			set copiar_item = @copiar_item,
				no_copiar_item = @no_copiar_item,
				procesado = @procesado
		where id_item_inventario_preventa_precopia = @id_item_inventario_preventa_precopia
	END
END
