/****** Object:  StoredProcedure [dbo].[pbinv_eliminar_preventa_sin_confirmar]    Script Date: 10/06/2007 13:33:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[pbinv_eliminar_preventa_sin_confirmar]

@id_preventa_sin_confirmar integer, 
@id_cuenta_interna integer

as

declare @cuenta nvarchar(255)
select @cuenta = cuenta from Cuenta_Interna where id_cuenta_interna = @id_cuenta_interna

if (@id_preventa_sin_confirmar not in (select isnull(id_preventa_sin_confirmar, 0) from Item_Preventa))
begin
	insert into Log_Cuenta_Interna (id_cuenta_interna, fecha, mensaje)
	select @id_cuenta_interna, getdate(), 'preventa sin confirmar eliminada por: '+ @cuenta+space(1)+', '+
	'datos de la preventa sin confirmar eliminada: '+space(1)+'cuenta interna: '+Cuenta_Interna.cuenta 
	+space(1)+'cantidad piezas: '+convert(nvarchar, Preventa_Sin_Confirmar.cantidad_piezas)
	+space(1)+'fecha despacho: '+convert(nvarchar, Preventa_Sin_Confirmar.fecha_despacho, 101)
	+space(1)+'transportador: '+Transportador.idc_transportador
	+space(1)+'cliente_despacho: '+Cliente_Despacho.idc_cliente_despacho
	+space(1)+'valor unitario: '+convert(nvarchar, Preventa_Sin_Confirmar.valor_unitario)
	+space(1)+'tapa: '+Tapa.idc_tapa
	+space(1)+'tipo caja: '+Tipo_Caja.idc_tipo_caja
	+space(1)+'tipo flor: '+Tipo_Flor.idc_tipo_flor
	+space(1)+'variedad flor: '+Variedad_Flor.idc_variedad_flor
	+space(1)+'grado flor: '+Grado_Flor.idc_grado_flor
	+space(1)+'unidades por pieza: '+convert(nvarchar, Item_Inventario_Preventa.unidades_por_pieza)
	+space(1)+'marca: '+Item_Inventario_Preventa.marca
	from Preventa_Sin_Confirmar, 
	Transportador, 
	Cliente_Despacho,
	Tapa, 
	Tipo_Caja, 
	Tipo_Flor, 
	Variedad_Flor, 
	Grado_Flor, 
	Item_Inventario_Preventa, 
	Cuenta_Interna
	where 
	Preventa_Sin_Confirmar.id_preventa_sin_confirmar = @id_preventa_sin_confirmar
	and Preventa_Sin_Confirmar.id_item_inventario_preventa = Item_Inventario_Preventa.id_item_inventario_preventa
	and Preventa_Sin_Confirmar.id_transportador = Transportador.id_transportador
	and Preventa_Sin_Confirmar.id_despacho = Cliente_Despacho.id_despacho
	and Preventa_Sin_Confirmar.id_cuenta_interna = Cuenta_Interna.id_cuenta_interna
	and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
	and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
	and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
	and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
	and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	delete from Preventa_Sin_Confirmar where id_preventa_sin_confirmar = @id_preventa_sin_confirmar
end
else
return -1