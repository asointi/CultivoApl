set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[mmk_consultar_saldos] 

@fecha_inicial datetime,
@fecha_final datetime

as

declare @idc_farm nvarchar(2)

declare @detalle_po table
(
  id_detalle_po int
)

declare @farm_detalle_po table
(
  id_farm_detalle_po int
)

declare @ordenes table
(
	Tipo_orden nvarchar(50),
	fecha_despacho_miami datetime,
	id_farm int,
	idc_farm nvarchar(2),
	nombre_farm nvarchar(50),
	id_tipo_flor int,
	nombre_tipo_flor nvarchar(50),
	id_variedad_flor int,
	nombre_variedad_flor nvarchar(50),
	id_grado_flor int,
	nombre_grado_flor nvarchar(50),
	id_tapa int,
	nombre_tapa nvarchar(50),
	marca nvarchar(5),
	fecha_vuelo datetime,
	unidades int,
	id_solicitud_confirmacion_cultivo int,
	piezas_solicitadas int default(0),
	piezas_pendientes_confirmar int default(0),
	piezas_no_confirmadas int default(0),
	piezas_confirmadas int default(0),
	id_detalle_po int,
	idc_cliente_despacho nvarchar(10),
	nombre_cliente_despacho nvarchar(50),
	po_number nvarchar(25),
	numero_solicitud int,
	piezas_sin_direccion int, 
	piezas_con_direccion int, 
	piezas_flying int, 
	piezas_arriving int,
	piezas_facturadas int, 
	piezas_pendientes_facturacion int
)

declare @pieza table 
(
	numero_solicitud int, 
	direccion_pieza int, 
	id_pieza int,
	disponible bit
)

declare @estado_pieza table
(
	numero_solicitud int, 
	piezas_sin_direccion int, 
	piezas_con_direccion int, 
	piezas_flying int, 
	piezas_arriving int,
	piezas_facturadas int, 
	piezas_pendientes_facturacion int
)

set @idc_farm = 'AM'

insert into @detalle_po (id_detalle_po)
select max(id_detalle_po)
from detalle_po (NOLOCK)
group by id_detalle_po_padre

insert into @farm_detalle_po (id_farm_detalle_po)
select max(id_farm_detalle_po)
from farm_detalle_po (NOLOCK)
group by id_farm_detalle_po_padre

/*EDUARDO SIN CONFIRMAR*/
insert into @ordenes
(
	Tipo_orden,
	id_detalle_po,
	po_number,
	numero_solicitud,
	idc_cliente_despacho,
	nombre_cliente_despacho,
	piezas_solicitadas,
	piezas_pendientes_confirmar,
	fecha_despacho_miami,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	marca,
	fecha_vuelo,
	unidades,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	id_farm,
	idc_farm,
	nombre_farm
)
select 'Eduardo sin confirmar',
detalle_po.id_detalle_po,
po.po_number,
dbo.Solicitud_Confirmacion_Mass_Market.numero_solicitud,
ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) as idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
detalle_po.cantidad_piezas as piezas_solicitadas,
farm_detalle_po.cantidad_piezas as piezas_pendientes_confirmar,
po.fecha_despacho_miami,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
detalle_po.marca,
farm_detalle_po.fecha_vuelo,
(
  select sum(unidades)
  from detalle_version_bouquet (NOLOCK)
  where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
) as unidades,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm
from solicitud_confirmacion_mass_market (NOLOCK),
po (NOLOCK),
tapa (NOLOCK),
tipo_flor (NOLOCK),
variedad_flor (NOLOCK),
grado_flor (NOLOCK),
version_bouquet (NOLOCK),
detalle_po (NOLOCK),
caja (NOLOCK),
bouquet (NOLOCK),
farm (NOLOCK),
farm_detalle_po (NOLOCK),
cliente_despacho (NOLOCK),
Solicitud_Confirmacion_Cultivo
where po.numero_solicitud = dbo.Solicitud_Confirmacion_Mass_Market.numero_solicitud
and dbo.Solicitud_Confirmacion_Mass_Market.numero_solicitud > 0
and cliente_despacho.id_despacho = po.id_despacho
and po.id_po = dbo.Detalle_PO.id_po
and not exists
(
  select *
  from cancela_detalle_po (NOLOCK)
  where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and dbo.Farm_Detalle_PO.id_farm_detalle_po = dbo.Solicitud_Confirmacion_Cultivo.id_farm_detalle_po
and Solicitud_Confirmacion_Cultivo.aceptada = 1
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and bouquet.id_bouquet = version_bouquet.id_bouquet
and caja.id_caja = version_bouquet.id_caja
and tipo_flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and dbo.Bouquet.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
and dbo.Bouquet.id_grado_flor = dbo.Grado_Flor.id_grado_flor
and tapa.id_tapa = detalle_po.id_tapa
and farm.id_farm = farm_detalle_po.id_farm
and farm.idc_farm = @idc_farm
and po.fecha_despacho_miami between
@fecha_inicial and @fecha_final
and exists
(
  select *
  from @detalle_po as dp
  where detalle_po.id_detalle_po = dp.id_detalle_po
)
and exists
(
  select *
  from @farm_detalle_po as fdp
  where farm_detalle_po.id_farm_detalle_po = fdp.id_farm_detalle_po
)
and not exists
(
  select *
  from confirmacion_bouquet_cultivo (NOLOCK)
  where dbo.Solicitud_Confirmacion_Cultivo.id_solicitud_confirmacion_cultivo = dbo.Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo
)

/*EDUARDO CONFIRMADO*/
insert into @ordenes
(
	Tipo_orden,
	id_detalle_po,
	po_number,
	numero_solicitud,
	idc_cliente_despacho,
	nombre_cliente_despacho,
	piezas_solicitadas,
	piezas_pendientes_confirmar,
	piezas_no_confirmadas,
	piezas_confirmadas,
	fecha_despacho_miami,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	marca,
	fecha_vuelo,
	unidades,
	id_solicitud_confirmacion_cultivo,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	id_farm,
	idc_farm,
	nombre_farm
)
select 'Eduardo Confirmadas',
detalle_po.id_detalle_po,
po.po_number,
dbo.Solicitud_Confirmacion_Mass_Market.numero_solicitud,
ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) as idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
detalle_po.cantidad_piezas as piezas_solicitadas,
farm_detalle_po.cantidad_piezas as piezas_pendientes_confirmar,
case
  when confirmacion_bouquet_cultivo.aceptada = 0 then confirmacion_bouquet_cultivo.cantidad_piezas
  else 0
end as piezas_no_confirmadas,
case
  when confirmacion_bouquet_cultivo.aceptada = 1 then confirmacion_bouquet_cultivo.cantidad_piezas
  else 0
end as piezas_confirmadas,
po.fecha_despacho_miami,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
detalle_po.marca,
farm_detalle_po.fecha_vuelo,
(
  select sum(unidades)
  from detalle_version_bouquet (NOLOCK)
  where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
) as unidades,
solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm
from solicitud_confirmacion_mass_market (NOLOCK),
po (NOLOCK),
tapa (NOLOCK),
tipo_flor (NOLOCK),
variedad_flor (NOLOCK),
grado_flor (NOLOCK),
version_bouquet (NOLOCK),
detalle_po (NOLOCK),
caja (NOLOCK),
bouquet (NOLOCK),
farm (NOLOCK),
farm_detalle_po (NOLOCK),
cliente_despacho (NOLOCK),
Solicitud_Confirmacion_Cultivo,
confirmacion_bouquet_cultivo (NOLOCK)
where po.numero_solicitud = dbo.Solicitud_Confirmacion_Mass_Market.numero_solicitud
and dbo.Solicitud_Confirmacion_Mass_Market.numero_solicitud > 0
and dbo.Solicitud_Confirmacion_Cultivo.id_solicitud_confirmacion_cultivo = dbo.Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo
and cliente_despacho.id_despacho = po.id_despacho
and po.id_po = dbo.Detalle_PO.id_po
and not exists
(
  select *
  from cancela_detalle_po (NOLOCK)
  where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and dbo.Farm_Detalle_PO.id_farm_detalle_po = dbo.Solicitud_Confirmacion_Cultivo.id_farm_detalle_po
and Solicitud_Confirmacion_Cultivo.aceptada = 1
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and bouquet.id_bouquet = version_bouquet.id_bouquet
and caja.id_caja = version_bouquet.id_caja
and tipo_flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and dbo.Bouquet.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
and dbo.Bouquet.id_grado_flor = dbo.Grado_Flor.id_grado_flor
and tapa.id_tapa = detalle_po.id_tapa
and farm.id_farm = farm_detalle_po.id_farm
and farm.idc_farm = @idc_farm
and po.fecha_despacho_miami between
@fecha_inicial and @fecha_final
and exists
(
  select *
  from @detalle_po as dp
  where detalle_po.id_detalle_po = dp.id_detalle_po
)
and exists
(
  select *
  from @farm_detalle_po as fdp
  where farm_detalle_po.id_farm_detalle_po = fdp.id_farm_detalle_po
)

/*JULIA SIN CONFIRMAR*/
insert into @ordenes
(
	Tipo_orden,
	id_detalle_po,
	po_number,
	numero_solicitud,
	idc_cliente_despacho,
	nombre_cliente_despacho,
	piezas_solicitadas,
	piezas_pendientes_confirmar,
	fecha_despacho_miami,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	marca,
	fecha_vuelo,
	unidades,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	id_farm,
	idc_farm,
	nombre_farm
)
select 'Julia sin confirmar',
detalle_po.id_detalle_po,
po.po_number,
dbo.solicitud_confirmacion_orden_especial.numero_solicitud,
ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) as idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
detalle_po.cantidad_piezas as piezas_solicitadas,
farm_detalle_po.cantidad_piezas as piezas_pendientes_confirmar,
po.fecha_despacho_miami,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
detalle_po.marca,
farm_detalle_po.fecha_vuelo,
(
  select sum(unidades)
  from detalle_version_bouquet (NOLOCK)
  where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
) as unidades,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm
from solicitud_confirmacion_orden_especial (NOLOCK),
po (NOLOCK),
tapa (NOLOCK),
tipo_flor (NOLOCK),
variedad_flor (NOLOCK),
grado_flor (NOLOCK),
version_bouquet (NOLOCK),
detalle_po (NOLOCK),
caja (NOLOCK),
bouquet (NOLOCK),
farm_detalle_po (NOLOCK),
farm (NOLOCK),
Solicitud_Confirmacion_Cultivo (NOLOCK),
cliente_despacho (NOLOCK)
where dbo.Farm_Detalle_PO.id_farm_detalle_po = dbo.Solicitud_Confirmacion_Cultivo.id_farm_detalle_po
and Solicitud_Confirmacion_Cultivo.aceptada = 1
and cliente_despacho.id_despacho = po.id_despacho
and po.numero_solicitud = dbo.solicitud_confirmacion_orden_especial.numero_solicitud
and dbo.solicitud_confirmacion_orden_especial.numero_solicitud > 0
and po.id_po = dbo.Detalle_PO.id_po
and not exists
(
  select *
  from cancela_detalle_po (NOLOCK)
  where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and bouquet.id_bouquet = version_bouquet.id_bouquet
and caja.id_caja = version_bouquet.id_caja
and tipo_flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and dbo.Bouquet.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
and dbo.Bouquet.id_grado_flor = dbo.Grado_Flor.id_grado_flor
and tapa.id_tapa = detalle_po.id_tapa
and farm.id_farm = farm_detalle_po.id_farm
and farm.idc_farm = @idc_farm
and po.fecha_despacho_miami between
@fecha_inicial and @fecha_final
and exists
(
  select *
  from @detalle_po as dp
  where detalle_po.id_detalle_po = dp.id_detalle_po
)
and exists
(
  select *
  from @farm_detalle_po as fdp
  where farm_detalle_po.id_farm_detalle_po = fdp.id_farm_detalle_po
)
and not exists
(
  select *
  from confirmacion_bouquet_cultivo (NOLOCK) 
  where dbo.Solicitud_Confirmacion_Cultivo.id_solicitud_confirmacion_cultivo = dbo.Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo
)

/*JULIA CONFIRMADO - RECHAZADO POR FINCA*/
insert into @ordenes
(
	Tipo_orden,
	id_detalle_po,
	po_number,
	numero_solicitud,
	idc_cliente_despacho,
	nombre_cliente_despacho,
	piezas_solicitadas,
	piezas_pendientes_confirmar,
	piezas_no_confirmadas,
	fecha_despacho_miami,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	marca,
	fecha_vuelo,
	unidades,
	id_solicitud_confirmacion_cultivo,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	id_farm,
	idc_farm,
	nombre_farm
)
select 'Julia Confirmado',
detalle_po.id_detalle_po,
po.po_number,
solicitud_confirmacion_orden_especial.numero_solicitud,
ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) as idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
detalle_po.cantidad_piezas,
farm_detalle_po.cantidad_piezas,
confirmacion_bouquet_cultivo.cantidad_piezas,
po.fecha_despacho_miami,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
detalle_po.marca,
farm_detalle_po.fecha_vuelo,
(
  select sum(unidades)
  from detalle_version_bouquet (NOLOCK)
  where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
) as unidades,
solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm
from solicitud_confirmacion_orden_especial (NOLOCK),
po (NOLOCK),
tipo_flor (NOLOCK),
variedad_flor (NOLOCK),
grado_flor (NOLOCK),
tapa (NOLOCK),
farm (NOLOCK),
detalle_po (NOLOCK),
farm_detalle_po (NOLOCK),
solicitud_confirmacion_cultivo (NOLOCK),
confirmacion_bouquet_cultivo (NOLOCK),
cliente_despacho (NOLOCK),
version_bouquet (NOLOCK),
bouquet (NOLOCK)
where po.numero_solicitud = dbo.solicitud_confirmacion_orden_especial.numero_solicitud
and dbo.solicitud_confirmacion_orden_especial.numero_solicitud > 0
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and bouquet.id_bouquet = version_bouquet.id_bouquet
and po.id_po = dbo.Detalle_PO.id_po
and cliente_despacho.id_despacho = po.id_despacho
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
and confirmacion_bouquet_cultivo.aceptada = 0
and tipo_flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = dbo.Grado_Flor.id_tipo_flor
and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
and grado_flor.id_grado_flor = bouquet.id_grado_flor
and tapa.id_tapa = detalle_po.id_tapa
and farm.id_farm = farm_detalle_po.id_farm
and farm.idc_farm = @idc_farm
and po.fecha_despacho_miami between
@fecha_inicial and @fecha_final

/*JULIA CONFIRMADO - APROBADO POR FINCA*/
insert into @ordenes
(
	Tipo_orden,
	id_detalle_po,
	po_number,
	numero_solicitud,
	idc_cliente_despacho,
	nombre_cliente_despacho,
	piezas_solicitadas,
	piezas_pendientes_confirmar,
	piezas_confirmadas,
	fecha_despacho_miami,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	marca,
	fecha_vuelo,
	unidades,
	id_solicitud_confirmacion_cultivo,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	id_farm,
	idc_farm,
	nombre_farm
)
select 'Julia Confirmado',
detalle_po.id_detalle_po,
po.po_number,
solicitud_confirmacion_orden_especial.numero_solicitud,
ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) as idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
detalle_po.cantidad_piezas,
farm_detalle_po.cantidad_piezas,
orden_pedido.cantidad_piezas,
orden_pedido.fecha_inicial,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
detalle_po.marca,
dbo.calcular_dia_vuelo_preventa(orden_pedido.fecha_inicial, farm.idc_farm) as fecha_vuelo,
orden_pedido.unidades_por_pieza,
solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm
from solicitud_confirmacion_orden_especial (NOLOCK),
po (NOLOCK),
confirmacion_orden_especial_cultivo (NOLOCK),
orden_especial_confirmada (NOLOCK),
orden_pedido (NOLOCK),
tipo_flor (NOLOCK),
variedad_flor (NOLOCK),
grado_flor (NOLOCK),
tapa (NOLOCK),
farm (NOLOCK),
detalle_po (NOLOCK),
farm_detalle_po (NOLOCK),
solicitud_confirmacion_cultivo (NOLOCK),
confirmacion_bouquet_cultivo (NOLOCK),
cliente_despacho (NOLOCK)
where po.numero_solicitud = dbo.solicitud_confirmacion_orden_especial.numero_solicitud
and dbo.solicitud_confirmacion_orden_especial.numero_solicitud > 0
and po.id_po = dbo.Detalle_PO.id_po
and cliente_despacho.id_despacho = po.id_despacho
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
and dbo.Solicitud_Confirmacion_Orden_Especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and dbo.Confirmacion_Orden_Especial_Cultivo.id_confirmacion_orden_especial_cultivo = dbo.Orden_Especial_Confirmada.id_confirmacion_orden_especial_cultivo
and orden_pedido.id_orden_pedido = dbo.Orden_Especial_Confirmada.id_orden_pedido
and tipo_flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = dbo.Grado_Flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tapa.id_tapa = orden_pedido.id_tapa
and farm.id_farm = orden_pedido.id_farm
and farm.idc_farm = @idc_farm
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final

/*Si existen varias lineas con el mismo numero de solicitud, el acumulado de estas piezas
se repetira en ellas. Una de las formas de corregir este problema es comparar ademas de este
numero el tipo, variedad, grado, finca, marca y empaque de la pieza con lo que se envio por parte de Eduardo.
Sin embargo no se realiza, pues esto se corregira cuando Eduardo ingrese las ordenes en vez de viviana.*/

/*traer las piezas que han sido confirmadas para luedo restarlas o ubicarlas en una direcci[on o estado de guia*/
insert into @pieza (numero_solicitud, id_pieza, disponible, direccion_pieza)
select pieza.numero_solicitud_finca,
pieza.id_pieza,
pieza.disponible,
pieza.direccion_pieza
from pieza
where pieza.numero_solicitud_finca is not null
and pieza.numero_solicitud_finca > 0

insert into @estado_pieza (numero_solicitud, piezas_sin_direccion, piezas_con_direccion, piezas_flying, piezas_arriving, piezas_facturadas, piezas_pendientes_facturacion)
select numero_solicitud,
sum(
case
	when direccion_pieza = 0 then 1
	else 0
end
) as piezas_sin_direccion,
sum(
case
	when direccion_pieza > 8 then 1
	else 0
end
) as piezas_con_direccion,
sum(
case
	when direccion_pieza = 6 then 1
	else 0
end
) as piezas_flying,
sum(
case
	when direccion_pieza = 8 then 1
	else 0
end
) as piezas_arriving,
sum(
case
	when disponible = 0 then 1
	else 0
end
) as piezas_facturadas,
sum(
case
	when disponible = 1 then 1
	else 0
end
) as piezas_pendientes_facturacion
from @pieza
group by numero_solicitud

update @ordenes
set piezas_sin_direccion = ep.piezas_sin_direccion, 
piezas_con_direccion = ep.piezas_con_direccion, 
piezas_flying = ep.piezas_flying, 
piezas_arriving = ep.piezas_arriving,
piezas_facturadas = ep.piezas_facturadas,
piezas_pendientes_facturacion = ep.piezas_pendientes_facturacion
from @estado_pieza as ep,
@ordenes as o
where o.numero_solicitud = ep.numero_solicitud

select Tipo_orden,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
marca,
fecha_despacho_miami,
fecha_vuelo,
idc_cliente_despacho,
nombre_cliente_despacho,
po_number,
numero_solicitud,
id_tipo_flor,
id_variedad_flor,
id_grado_flor,
id_tapa,
id_farm,
idc_farm,
nombre_farm,
sum(isnull(piezas_confirmadas, 0) - isnull(piezas_flying, 0) - isnull(piezas_arriving, 0) - isnull(piezas_con_direccion, 0) - isnull(piezas_sin_direccion, 0)) as piezas_pendientes_volar, 
sum(piezas_sin_direccion) as piezas_sin_direccion, 
sum(piezas_con_direccion) as piezas_con_direccion, 
sum(piezas_flying) as piezas_flying, 
sum(piezas_arriving) as piezas_arriving,
sum(unidades) as unidades,
sum(piezas_solicitadas) as piezas_solicitadas,
sum(isnull(piezas_solicitadas, 0) - isnull(piezas_confirmadas, 0) - isnull(piezas_no_confirmadas, 0)) as piezas_pendientes_confirmar,
sum(piezas_no_confirmadas) as piezas_no_confirmadas,
sum(piezas_confirmadas) as piezas_confirmadas,
sum(piezas_facturadas) as piezas_facturadas,
sum(piezas_pendientes_facturacion) as piezas_pendientes_facturacion
from @ordenes
group by Tipo_orden,
fecha_despacho_miami,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
marca,
fecha_vuelo,
id_detalle_po,
idc_cliente_despacho,
nombre_cliente_despacho,
po_number,
numero_solicitud,
id_tipo_flor,
id_variedad_flor,
id_grado_flor,
id_tapa,
id_farm,
idc_farm,
nombre_farm
order by numero_solicitud