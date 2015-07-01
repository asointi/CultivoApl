SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_eliminar_preventa_web]

@id_temporada_ano int,
@id_farm int,
@id_tapa int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tipo_caja int,
@unidades_por_pieza int,
@marca nvarchar(10)

AS

insert into log_info (fecha, mensaje)
select getdate(),
'SP pbinv_eliminar_preventa_web' + ', ' + 
'@id_temporada_ano: ' + convert(nvarchar, @id_temporada_ano) + ', ' + 
'@id_farm: ' + convert(nvarchar, @id_farm) + ', ' + 
'@id_tapa: ' + convert(nvarchar, @id_tapa) + ', ' + 
'@id_variedad_flor: ' + convert(nvarchar, @id_variedad_flor) + ', ' + 
'@id_grado_flor: ' + convert(nvarchar, @id_grado_flor) + ', ' + 
'@id_tipo_caja: ' + convert(nvarchar, @id_tipo_caja) + ', ' + 
'@unidades_por_pieza: ' + convert(nvarchar, @unidades_por_pieza) + ', ' + 
'@marca: ' + @marca

select item_inventario_preventa.id_item_inventario_preventa into #temp
from item_inventario_preventa,
inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_farm = @id_farm
and inventario_preventa.id_temporada_año = @id_temporada_ano
and id_variedad_flor = @id_variedad_flor
and id_grado_flor = @id_grado_flor
and id_tapa = @id_tapa
and marca = @marca
and id_tipo_caja = @id_tipo_caja
and unidades_por_pieza = @unidades_por_pieza

delete from detalle_item_inventario_preventa
where id_item_inventario_preventa in
(
	select id_item_inventario_preventa
	from #temp
)

delete from item_inventario_preventa
where id_item_inventario_preventa in
(
	select id_item_inventario_preventa
	from #temp
)

drop table #temp