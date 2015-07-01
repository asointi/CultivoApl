USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_adicionales_desde_cultivo]    Script Date: 21/10/2014 3:53:34 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2014/08/20
-- Description:	Trae informacion de recetas de solicitudes de Bouquets desde las comercializadoras
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_consultar_adicionales_desde_cultivo] 

@id_solicitud_confirmacion_cultivo_aux int,
@idc_farm_aux nvarchar(2)

as

set @idc_farm_aux = 'AM'

select id_solicitud_confirmacion_cultivo,
sum(cantidad_piezas) as cantidad_piezas into #confirmacion_bouquet
from bd_cultivo.bd_cultivo.dbo.confirmacion_bouquet
group by id_solicitud_confirmacion_cultivo
union all
select Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo,
sum(Confirmacion_Bouquet_Cultivo.cantidad_piezas) as cantidad_piezas
from Confirmacion_Bouquet_Cultivo
group by Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo

select max(id_detalle_po) as id_detalle_po into #detalle_po
from detalle_po
group by id_detalle_po_padre

select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
from farm_detalle_po
group by id_farm_detalle_po_padre

declare @upc nvarchar(255),
@descripcion nvarchar(255),
@fecha nvarchar(255),
@precio nvarchar(255)

set @upc = 'UPC'
set @descripcion = 'Descripcion'
set @fecha = 'Fecha'
set @precio = 'Precio'
	
select capuchon_cultivo.descripcion,
capuchon_cultivo.idc_capuchon,
capuchon_cultivo.id_capuchon_cultivo,
detalle_po.id_detalle_po,
farm_detalle_po.id_farm_detalle_po,
solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
formula_bouquet.id_formula_bouquet,
sticker.nombre_sticker,
sticker.id_sticker,
comida_bouquet.nombre_comida,
comida_bouquet.id_comida_bouquet,
informacion_upc.nombre_informacion_upc,
UPC_Detalle_PO.valor,
UPC_Detalle_PO.orden,
formato_upc.nombre_formato,
formato_upc.id_formato_upc,
formato_upc.requiere_informacion_adicional into #resultado
from version_bouquet,
detalle_po,
farm_detalle_po,
farm,
solicitud_confirmacion_cultivo,
po,
detalle_version_bouquet left join sticker_bouquet on detalle_version_bouquet.id_detalle_version_bouquet = sticker_bouquet.id_detalle_version_bouquet
left join sticker on sticker.id_sticker = sticker_bouquet.id_sticker
left join formato_upc on formato_upc.id_formato_upc = detalle_version_bouquet.id_formato_upc
left join upc_detalle_po on detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
left join informacion_upc on informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc,
comida_bouquet,
capuchon_formula_bouquet,
capuchon_cultivo,
Formula_Bouquet
where formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and farm.id_farm = farm_detalle_po.id_farm
and solicitud_confirmacion_cultivo.aceptada = 1
and po.id_po = detalle_po.id_po
and not exists
(
	select *
	from cancela_detalle_po
	where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and exists
(
	select *
	from #detalle_po
	where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
)
and exists
(
	select *
	from #farm_detalle_po
	where #farm_detalle_po.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
)
and not exists
(
	select *
	from #confirmacion_bouquet
	where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = #confirmacion_bouquet.id_solicitud_confirmacion_cultivo
	and detalle_po.cantidad_piezas = #confirmacion_bouquet.cantidad_piezas
)
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
and comida_bouquet.id_comida_bouquet = detalle_version_bouquet.id_comida_bouquet
and detalle_version_bouquet.id_detalle_version_bouquet = capuchon_formula_bouquet.id_detalle_version_bouquet
and capuchon_cultivo.id_capuchon_cultivo = capuchon_formula_bouquet.id_capuchon_cultivo
and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo > = 
case
	when @id_solicitud_confirmacion_cultivo_aux = 0 then 1
	else @id_solicitud_confirmacion_cultivo_aux
end
and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo < = 
case
	when @id_solicitud_confirmacion_cultivo_aux = 0 then 99999999
	else @id_solicitud_confirmacion_cultivo_aux
end
and farm.idc_farm  = @idc_farm_aux
--and farm.idc_farm > = 
--case
--	when @idc_farm_aux = '' then '  '
--	else @idc_farm_aux
--end
--and farm.idc_farm < = 
--case
--	when @idc_farm_aux = '' then 'ZZ'
--	else @idc_farm_aux
--end

select 1 as tipo_item,
descripcion + ' [' + idc_capuchon + ']' as nombre_item,
idc_capuchon as idc_item,
id_capuchon_cultivo as id_item,
0 as orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
group by descripcion,
idc_capuchon,
id_capuchon_cultivo,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 2 as tipo_item,
nombre_sticker as nombre_item,
'' as idc_item,
id_sticker as id_item,
0 as orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
where id_sticker is not null
group by nombre_sticker,
id_sticker,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 3 as tipo_item,
nombre_comida as nombre_item,
'' as idc_item,
id_comida_bouquet as id_item,
0 as orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
group by nombre_comida,
id_comida_bouquet,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 4 as tipo_item,
valor as nombre_item,
'' as idc_item,
id_detalle_po as id_item,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
where nombre_informacion_upc = @upc
group by valor,
id_detalle_po,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 5 as tipo_item,
valor as nombre_item,
'' as idc_item,
id_detalle_po as id_item,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
where nombre_informacion_upc = @descripcion
group by valor,
id_detalle_po,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 6 as tipo_item,
valor as nombre_item,
'' as idc_item,
id_detalle_po as id_item,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
where nombre_informacion_upc = @precio
group by valor,
id_detalle_po,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 7 as tipo_item,
valor as nombre_item,
'' as idc_item,
id_detalle_po as id_item,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
where nombre_informacion_upc = @fecha
group by valor,
id_detalle_po,
orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
union all
select 8 as tipo_item,
isnull(nombre_formato, 'REGULAR') as nombre_item,
'' as idc_item,
isnull(id_formato_upc, 1) as id_item,
isnull(requiere_informacion_adicional, 0) as orden,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet
from #resultado
group by nombre_formato,
id_formato_upc,
id_detalle_po,
id_farm_detalle_po,
id_solicitud_confirmacion_cultivo,
id_formula_bouquet,
isnull(requiere_informacion_adicional, 0)

drop table #resultado
drop table #detalle_po
drop table #farm_detalle_po
drop table #confirmacion_bouquet