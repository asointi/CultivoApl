alter PROCEDURE [dbo].[pbinv_items_repetidos_inventario_version2]

@idc_cliente nvarchar(15),
@idc_farm nvarchar(5),
@idc_tapa nvarchar(5),
@idc_tipo_caja nvarchar(5),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@unidades_por_pieza int,
@fecha nvarchar(20)

as

declare @id_tapa_aux int,
@idc_tapa_aux nvarchar(3),
@nombre_tapa_aux nvarchar(20),
@nombre_base_datos nvarchar(20),
@id_farm int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tapa int,
@id_tapa_switch int,
@id_tipo_caja int,
@conteo int,
@fecha_inicial_temporada datetime

set @nombre_base_datos = DB_NAME()

select @id_tapa_aux = isnull(tapa.id_tapa, 0)
from grupo_cliente_factura,
cliente_factura,
cliente_despacho,
tapa
where grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and tapa.id_tapa = grupo_cliente_factura.id_tapa
and ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) = ltrim(rtrim(@idc_cliente))

select @id_farm = id_farm from farm where idc_farm = @idc_farm

select @id_variedad_flor = variedad_flor.id_variedad_flor 
from variedad_flor, 
tipo_flor 
where variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor 
and variedad_flor.idc_variedad_flor = @idc_variedad_flor

select @id_grado_flor = grado_flor.id_grado_flor 
from grado_flor, 
tipo_flor 
where grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor

select @id_tapa_switch = isnull(id_tapa, 0) from tapa where idc_tapa = @idc_tapa

if(@nombre_base_datos = 'BD_NF')
begin
	set @id_tapa = 
	case
		when @id_tapa_switch = @id_tapa_aux and @idc_farm = 'N4' then 74
		else @id_tapa_switch
	end
end
else
begin
	set @id_tapa = @id_tapa_switch
end

select @id_tipo_caja = id_tipo_caja from tipo_caja where idc_tipo_caja = @idc_tipo_caja

select @fecha_inicial_temporada = fecha_inicial 
from temporada_cubo where convert(datetime,@fecha) 
between fecha_inicial and fecha_final

select count(*) as cantidad_items,
isnull((
	select max(convert(int, iip.empaque_principal))
	from inventario_preventa as ip,
	item_inventario_preventa as iip,
	detalle_item_inventario_preventa as diip
	where ip.id_farm = @id_farm
	and ip.id_inventario_preventa = iip.id_inventario_preventa
	and iip.id_item_inventario_preventa = diip.id_item_inventario_preventa
	and iip.id_tapa = @id_tapa
	and iip.id_variedad_flor = @id_variedad_flor
	and iip.id_grado_flor = @id_grado_flor
	and iip.unidades_por_pieza = @unidades_por_pieza
	and diip.fecha_disponible_distribuidora = convert(datetime, @fecha_inicial_temporada)
), 0) as empaque_principal
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and item_inventario_preventa.id_tapa = @id_tapa
and inventario_preventa.id_farm = @id_farm
and item_inventario_preventa.id_tipo_caja = @id_tipo_caja
and item_inventario_preventa.id_variedad_flor = @id_variedad_flor
and item_inventario_preventa.id_grado_flor = @id_grado_flor
and item_inventario_preventa.unidades_por_pieza = @unidades_por_pieza
and detalle_item_inventario_preventa.fecha_disponible_distribuidora = convert(datetime, @fecha_inicial_temporada)