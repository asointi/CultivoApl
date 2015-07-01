/****** Object:  StoredProcedure [dbo].[pbinv_registrar_preventa_sin_confirmar_cobol]    Script Date: 10/06/2007 13:37:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_registrar_preventa_sin_confirmar_cobol]

@id_item_inventario_preventa integer, 
@id_cuenta_interna integer,
@idc_transportador NVARCHAR(3),
@idc_cliente_despacho NVARCHAR(7),
@cantidad_piezas integer,
@valor_unitario decimal(20,4),
@fecha_despacho datetime


AS

declare @id_transportador integer, @id_despacho integer
select @id_transportador = id_transportador from transportador where idc_transportador = @idc_transportador
select @id_despacho = id_despacho from Cliente_Despacho where idc_cliente_despacho = @idc_cliente_despacho
BEGIN

insert into Preventa_Sin_Confirmar (id_cuenta_interna, id_item_inventario_preventa, cantidad_piezas, id_transportador, id_despacho, valor_unitario, fecha_despacho)
values (@id_cuenta_interna, @id_item_inventario_preventa, @cantidad_piezas, @id_transportador, @id_despacho, @valor_unitario, @fecha_despacho)
select scope_identity()
return scope_identity()
END