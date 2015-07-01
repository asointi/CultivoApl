set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[cubo_ventas_tabla_pivote] 

as

If exists (select * from sys.objects where object_id = object_id(N'[dbo].[Pivote_Cubo_Ventas]') and type in (N'U'))
drop table [dbo].[Pivote_Cubo_Ventas]

declare @año  int,
@hora_actual datetime

set @hora_actual = getdate()
set @año = datepart(yyyy, dateadd(yyyy, -3, getdate()))

create table Pivote_Cubo_Ventas
(
  refresh_data datetime,
  idc_pieza nvarchar(25),
	Gross_sales decimal(20,4),
	Net_Sales decimal(20,4),
	id_pieza int,
	carrier_code nvarchar(25),
	carrier_name nvarchar(50),
	salesperson_code nvarchar(25),
	salesperson_name nvarchar(50),
	current_salesperson_code nvarchar(25),
	current_salesperson_name nvarchar(50),
	sold_to_code nvarchar(25),
	sold_to_name nvarchar(50),
	ship_to_code nvarchar(25),
	ship_to_name nvarchar(50),
	invoice_type nvarchar(25),
	invoice_type_description nvarchar(50),
	invoice_date datetime,
	invoice_year int,
	invoice_month int,
	invoice_quarter int,
	invoice_week int, 
	invoice_year_iso int, 
	invoice_number nvarchar(25),
	invoice_type_II nvarchar(25),
	farm_code nvarchar(25),
	farm_name nvarchar(50),
	city_code nvarchar(25),
	city_name nvarchar(50),
	farm_type nvarchar(25),
	AWB_status_code nvarchar(25),
	AWB_status_name nvarchar(50),
	AWB_date datetime,
	AWB_year int,
	AWB_month int,
	AWB_quarter int,
	AWB_week int, 
	AWB_year_iso int,
	AWB_number nvarchar(25),
	airline_name nvarchar(50),
	airline_code nvarchar(25),
	box_type nvarchar(25),
	flower_type nvarchar(50),
	variety nvarchar(50),
	grade nvarchar(50),
	color nvarchar(50),
	code nvarchar(25),
	pack int,
	fulls decimal(20,4)
)

select item_factura.id_item_factura,
item_factura.valor_unitario,
case
  when item_factura.cargo_incluido = 0 then isnull(sum(cargo.valor_cargo), 0)
end as cargo_no_incluido into #item_factura
from item_factura,
cargo,
factura
where factura.id_factura = item_factura.id_factura
and cargo.id_item_factura = item_factura.id_item_factura
and datepart(yyyy, factura.fecha_factura) > = @año
group by item_factura.id_item_factura,
item_factura.valor_unitario,
item_factura.cargo_incluido

select item_factura.id_item_factura,
detalle_credito.valor_credito /
(
  select count(p.id_pieza)
  from pieza as p,
  detalle_item_factura as dif
  where p.id_pieza = dif.id_pieza
  and item_factura.id_item_factura = dif.id_item_factura
) as valor_credito into #credito
from item_factura,
factura,
detalle_credito,
credito
where factura.id_factura = item_factura.id_factura
and item_factura.id_item_factura = detalle_credito.id_item_factura
and datepart(yyyy, factura.fecha_factura) > = @año
and credito.id_credito = detalle_credito.id_credito

insert into Pivote_Cubo_Ventas
(
  refresh_data,
  idc_pieza,
	Gross_sales,
	Net_Sales,
	id_pieza,
	carrier_code,
	carrier_name,
	salesperson_code,
	salesperson_name,
	current_salesperson_code,
	current_salesperson_name,
	sold_to_code,
	sold_to_name,
	ship_to_code,
	ship_to_name,
	invoice_type,
	invoice_type_description,
	invoice_date,
	invoice_year,
	invoice_month,
	invoice_quarter,
	invoice_week, 
	invoice_year_iso, 
	invoice_number,
	invoice_type_II,
	farm_code,
	farm_name,
	city_code,
	city_name,
	farm_type,
	AWB_status_code,
	AWB_status_name,
	AWB_date,
	AWB_year,
	AWB_month,
	AWB_quarter,
	AWB_week, 
	AWB_year_iso,
	AWB_number,
	airline_name,
	airline_code,
	box_type,
	flower_type,
	variety,
	grade,
	color,
	code,
	pack,
	fulls
)
select @hora_actual,
pieza.idc_pieza,
(isnull(item_factura.valor_unitario, 0) * isnull(pieza.unidades_por_pieza, 0)) + isnull(#item_factura.cargo_no_incluido, 0) as Gross_sales,
(isnull(item_factura.valor_unitario, 0) * isnull(pieza.unidades_por_pieza, 0)) + isnull(#item_factura.cargo_no_incluido, 0) + 
isnull((
  select sum(#credito.valor_credito)
  from #credito
  where item_factura.id_item_factura = #credito.id_item_factura
), 0) as Net_Sales,
pieza.id_pieza,
transportador.idc_transportador as carrier_code,
transportador.nombre_transportador as carrier_name,
vendedor.idc_vendedor as salesperson_code,
ltrim(rtrim(vendedor.nombre)) as salesperson_name,
v.idc_vendedor as current_salesperson_code,
ltrim(rtrim(v.nombre)) as current_salesperson_name,
cliente_factura.idc_cliente_factura as sold_to_code,
(
  select ltrim(rtrim(cd.nombre_cliente))
  from cliente_despacho as cd (NOLOCK)
  where cd.idc_cliente_despacho = cliente_factura.idc_cliente_factura
) as sold_to_name,
cliente_despacho.idc_cliente_despacho as ship_to_code,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as ship_to_name,
tipo_factura.nombre_tipo_factura as invoice_type,
tipo_factura.descripcion_tipo_factura as invoice_type_description,
factura.fecha_factura as invoice_date,
datepart(yyyy, factura.fecha_factura) as invoice_year,
datepart(m, factura.fecha_factura) as invoice_month,
datepart(qq, factura.fecha_factura) as invoice_quarter,
DATEPART(ISO_WEEK, factura.fecha_factura) AS invoice_week, 
CASE 
  WHEN (datepart(WEEK, factura.fecha_factura) < 5) AND (datepart(ISO_WEEK, factura.fecha_factura) > 50) THEN datepart(yyyy, factura.fecha_factura) - 1 
  WHEN (datepart(WEEK, factura.fecha_factura) > 50) AND (datepart(ISO_WEEK, factura.fecha_factura) < 5) THEN datepart(yyyy, factura.fecha_factura) + 1 
  ELSE datepart(yyyy, factura.fecha_factura) 
END AS invoice_year_iso, 
factura.idc_llave_factura + factura.idc_numero_factura as invoice_number,
tipo_factura.orden_fija as invoice_type_II,
farm.idc_farm as farm_code,
ltrim(rtrim(farm.nombre_farm)) as farm_name,
ciudad.idc_ciudad as city_code,
ltrim(rtrim(ciudad.nombre_ciudad)) as city_name,
tipo_farm.idc_tipo_farm as farm_type,
estado_guia.idc_estado_guia as AWB_status_code,
estado_guia.nombre_estado_guia as AWB_status_name,
guia.fecha_guia as AWB_date,
datepart(yyyy, guia.fecha_guia) as AWB_year,
datepart(m, guia.fecha_guia) as AWB_month,
datepart(qq, guia.fecha_guia) as AWB_quarter,
DATEPART(ISO_WEEK, guia.fecha_guia) AS AWB_week, 
CASE 
  WHEN (datepart(WEEK, guia.fecha_guia) < 5) AND (datepart(ISO_WEEK, guia.fecha_guia) > 50) THEN datepart(yyyy, guia.fecha_guia) - 1 
  WHEN (datepart(WEEK, guia.fecha_guia) > 50) AND (datepart(ISO_WEEK, guia.fecha_guia) < 5) THEN datepart(yyyy, guia.fecha_guia) + 1 
  ELSE datepart(yyyy, guia.fecha_guia) 
END AS AWB_year_iso,
guia.idc_guia as AWB_number,
ltrim(rtrim(aerolinea.nombre_aerolinea)) as airline_name,
aerolinea.idc_aerolinea as airline_code,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as box_type,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as flower_type,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as variety,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as grade,
ltrim(rtrim(color.nombre_color)) as color,
pieza.marca as code,
pieza.unidades_por_pieza as pack,
tipo_caja.factor_a_full as fulls
from factura,
item_factura,
#item_factura,
detalle_item_factura (NOLOCK),
pieza (NOLOCK),
transportador (NOLOCK),
vendedor (NOLOCK),
vendedor as v (NOLOCK),
cliente_despacho (NOLOCK),
cliente_factura (NOLOCK),
tipo_factura (NOLOCK),
farm (NOLOCK),
ciudad (NOLOCK),
tipo_farm (NOLOCK),
guia (NOLOCK),
estado_guia (NOLOCK),
caja (NOLOCK),
tipo_caja (NOLOCK),
tipo_flor (NOLOCK),
variedad_flor (NOLOCK),
grado_flor (NOLOCK),
color (NOLOCK),
aerolinea (NOLOCK)
where pieza.id_pieza = dbo.Detalle_Item_Factura.Id_pieza
and item_factura.id_item_factura = dbo.Detalle_Item_Factura.id_item_factura
and factura.id_factura = dbo.Item_Factura.id_factura
and item_factura.id_item_factura = #item_factura.id_item_factura
and dbo.Transportador.id_transportador = factura.id_transportador
and vendedor.id_vendedor = dbo.Factura.id_vendedor
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and cliente_despacho.id_despacho = factura.id_despacho
and v.id_vendedor = dbo.Cliente_Factura.id_vendedor
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and farm.id_farm = pieza.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and guia.id_guia = pieza.id_guia
and estado_guia.id_estado_guia = guia.id_estado_guia
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and tipo_flor.id_tipo_flor = dbo.Variedad_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = dbo.Grado_Flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and color.id_color = variedad_flor.id_color
and aerolinea.id_aerolinea = guia.id_aerolinea
and datepart(yyyy, factura.fecha_factura) > = @año

drop table #item_factura
drop table #credito