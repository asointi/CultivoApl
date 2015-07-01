/****** Object:  StoredProcedure [dbo].[pbinv_registrar_preventa_sin_confirmar]    Script Date: 10/06/2007 13:37:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_registrar_preventa_sin_confirmar]

@id_item_inventario_preventa integer, 
@id_cuenta_interna integer,
@id_transportador integer,
@id_despacho integer,
@cantidad_piezas integer,
@valor_unitario decimal(20,4),
@fecha_despacho datetime

AS

BEGIN

insert into Preventa_Sin_Confirmar (id_cuenta_interna, id_item_inventario_preventa, cantidad_piezas, id_transportador, id_despacho, valor_unitario, fecha_despacho)
values (@id_cuenta_interna, @id_item_inventario_preventa, @cantidad_piezas, @id_transportador, @id_despacho, @valor_unitario, @fecha_despacho)

END