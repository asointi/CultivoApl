/****** Object:  StoredProcedure [dbo].[ext_customer_gross_sales_goals]    Script Date: 10/06/2007 10:57:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ext_customer_gross_sales_goals]

AS
BEGIN

declare @fecha_last_year datetime, @fecha_last_week datetime, @id_cuenta_externa integer, @tipo_orden nvarchar(255), @idc_tipo_farm_direct nvarchar(255), @idc_tipo_farm_not_define nvarchar(255)

set @fecha_last_year = getdate()-364
set @fecha_last_week = getdate()-7
set @id_cuenta_externa = 5
set @tipo_orden = 'Not S.O.'
set @idc_tipo_farm_direct = 'Direct' 
set @idc_tipo_farm_not_define = 'Not Define'

CREATE TABLE #tempyear (idc_cliente_despacho NVARCHAR(255), 
nombre_cliente NVARCHAR(255), 
numero_factura NVARCHAR(255), 
fecha_factura DATETIME, 
id_item_factura INTEGER, 
cargo_incluido BIT, 
nombre_farm NVARCHAR(255), 
nombre_tipo_flor NVARCHAR(255), 
nombre_variedad_flor NVARCHAR(255), 
nombre_grado_flor NVARCHAR(255), 
marca NVARCHAR(255), 
unidades_por_pieza INTEGER,
fulls DECIMAL(20,4), 
unidades INTEGER, 
valor_inicial DECIMAL(20,4))
		
INSERT INTO #tempyear (idc_cliente_despacho, 
nombre_cliente, 
numero_factura, 
fecha_factura, 
id_item_factura, 
cargo_incluido, 
nombre_farm, 
nombre_tipo_flor, 
nombre_variedad_flor, 
nombre_grado_flor, 
marca, 
unidades_por_pieza,
fulls, 
unidades, 
valor_inicial)

SELECT	
Cliente_Despacho.idc_cliente_despacho,
Cliente_Despacho.nombre_cliente,
factura.idc_llave_factura+factura.idc_numero_factura as numero_factura, 
Factura.fecha_factura,
Detalle_Item_Factura.id_item_factura,
Item_Factura.cargo_incluido,
Farm.nombre_farm,
Tipo_Flor.nombre_tipo_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.nombre_grado_flor,
Pieza.marca,
Pieza.unidades_por_pieza, 
sum(Tipo_Caja.factor_a_full) as fulls,
sum(Pieza.unidades_por_pieza) as unidades,
isnull(sum(Item_Factura.valor_unitario * Pieza.unidades_por_pieza), 0) as valor_inicial
FROM         
Detalle_Item_Factura, Pieza, Item_Factura, Caja, Tipo_Caja, Factura, Cliente_Despacho, Cliente_Factura,
Farm, Tipo_Flor, Variedad_Flor, Grado_Flor, Tipo_Factura, Tipo_Farm
WHERE
Detalle_Item_Factura.Id_pieza = Pieza.Id_pieza
and Detalle_Item_Factura.id_item_factura = Item_Factura.id_item_factura
and Pieza.id_caja = Caja.id_caja
and Caja.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Factura.id_factura=Item_Factura.id_factura
and Factura.id_despacho=Cliente_Despacho.id_despacho
and Cliente_Despacho.id_cliente_factura=Cliente_Factura.id_cliente_factura
and Cliente_Factura.id_cliente_factura in 
(
SELECT cf.id_cliente_factura
FROM cliente_factura as cf, cliente_despacho as cd, cuenta_externa_cliente_factura as ce
WHERE cf.id_cliente_factura = cd.id_cliente_factura 
and cf.idc_cliente_factura = cd.idc_cliente_despacho
and cf.id_cliente_factura = ce.id_cliente_factura
and ce.id_cuenta_externa = @id_cuenta_externa
)
and Farm.id_farm=Pieza.id_farm
and Variedad_Flor.id_variedad_flor=Pieza.id_variedad_flor
and Variedad_Flor.id_tipo_flor=Tipo_Flor.id_tipo_flor
and Grado_Flor.id_grado_flor=Pieza.id_grado_flor
and Grado_Flor.id_tipo_flor=Tipo_Flor.id_tipo_flor
and Factura.id_tipo_factura = Tipo_Factura.id_tipo_factura
and Tipo_Factura.orden_fija = @tipo_orden
and Farm.id_tipo_farm = Tipo_Farm.id_tipo_farm
and Tipo_Farm.id_tipo_farm in (select id_tipo_farm from tipo_farm where idc_tipo_farm <> @idc_tipo_farm_direct and idc_tipo_farm <> @idc_tipo_farm_not_define)
and convert(nvarchar, Factura.fecha_factura, 101) = convert(nvarchar, @fecha_last_year, 101)
group by Cliente_Despacho.idc_cliente_despacho,
Cliente_Factura.id_cliente_factura,
Cliente_Despacho.idc_cliente_despacho, 
Cliente_Despacho.nombre_cliente,
factura.idc_llave_factura+factura.idc_numero_factura, 
Factura.fecha_factura,
Detalle_Item_Factura.id_item_factura,
Item_Factura.cargo_incluido,
Farm.nombre_farm,
Tipo_Flor.nombre_tipo_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.nombre_grado_flor,
Pieza.marca,
Pieza.unidades_por_pieza
-----
SELECT 
Item_Factura.id_item_factura, Cargo.id_cargo, 
Cargo.valor_cargo * COUNT(Pieza.Id_pieza) AS valor_cargo
into #temp2
FROM Cargo , Item_Factura , Detalle_Item_Factura , Pieza
where Cargo.id_item_factura = Item_Factura.id_item_factura
and Item_Factura.id_item_factura = Detalle_Item_Factura.id_item_factura
and Detalle_Item_Factura.Id_pieza = Pieza.Id_pieza
GROUP BY Item_Factura.id_item_factura, Cargo.id_cargo,Cargo.valor_cargo
----
alter table #tempyear
add valor_cargo_year decimal(20,4) NOT NULL default (0),
valor_unitario_year decimal(20,4) NOT NULL default (0),
total_year decimal(20,4) NOT NULL default (0),
promedio_year decimal (20,4) NOT NULL default (0)
----
update #tempyear
set valor_cargo_year = isnull(#temp2.valor_cargo, 0)
from #tempyear, #temp2
where #tempyear.id_item_factura=#temp2.id_item_factura
and #tempyear.cargo_incluido = 0
----
update #tempyear
set valor_unitario_year = valor_inicial/unidades,
total_year = valor_inicial + valor_cargo_year,
promedio_year = (valor_inicial + valor_cargo_year)/unidades
-----------------------------------------
CREATE TABLE #tempweek (idc_cliente_despacho NVARCHAR(255), 
nombre_cliente NVARCHAR(255), 
numero_factura NVARCHAR(255), 
fecha_factura DATETIME, 
id_item_factura INTEGER, 
cargo_incluido BIT, 
nombre_farm NVARCHAR(255), 
nombre_tipo_flor NVARCHAR(255), 
nombre_variedad_flor NVARCHAR(255), 
nombre_grado_flor NVARCHAR(255), 
marca NVARCHAR(255), 
unidades_por_pieza INTEGER,
fulls DECIMAL(20,4), 
unidades INTEGER, 
valor_inicial DECIMAL(20,4))
------------------
INSERT INTO #tempweek (idc_cliente_despacho, 
nombre_cliente, 
numero_factura, 
fecha_factura, 
id_item_factura, 
cargo_incluido, 
nombre_farm, 
nombre_tipo_flor, 
nombre_variedad_flor, 
nombre_grado_flor, 
marca, 
unidades_por_pieza,
fulls, 
unidades, 
valor_inicial)
SELECT	
Cliente_Despacho.idc_cliente_despacho,
Cliente_Despacho.nombre_cliente,
factura.idc_llave_factura+factura.idc_numero_factura as numero_factura, 
Factura.fecha_factura,
Detalle_Item_Factura.id_item_factura,
Item_Factura.cargo_incluido,
Farm.nombre_farm,
Tipo_Flor.nombre_tipo_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.nombre_grado_flor,
Pieza.marca,
Pieza.unidades_por_pieza, 
sum(Tipo_Caja.factor_a_full) as fulls,
sum(Pieza.unidades_por_pieza) as unidades,
isnull(sum(Item_Factura.valor_unitario * Pieza.unidades_por_pieza), 0) as valor_inicial
FROM         
Detalle_Item_Factura, Pieza, Item_Factura, Caja, Tipo_Caja, Factura, Cliente_Despacho, Cliente_Factura,
Farm, Tipo_Flor, Variedad_Flor, Grado_Flor, Tipo_Factura, Tipo_Farm
WHERE
Detalle_Item_Factura.Id_pieza = Pieza.Id_pieza
and Detalle_Item_Factura.id_item_factura = Item_Factura.id_item_factura
and Pieza.id_caja = Caja.id_caja
and Caja.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Factura.id_factura=Item_Factura.id_factura
and Factura.id_despacho=Cliente_Despacho.id_despacho
and Cliente_Despacho.id_cliente_factura=Cliente_Factura.id_cliente_factura
and Cliente_Factura.id_cliente_factura in 
(
SELECT cf.id_cliente_factura
FROM cliente_factura as cf, cliente_despacho as cd, cuenta_externa_cliente_factura as ce
WHERE cf.id_cliente_factura = cd.id_cliente_factura 
and cf.idc_cliente_factura = cd.idc_cliente_despacho
and cf.id_cliente_factura = ce.id_cliente_factura
and ce.id_cuenta_externa = @id_cuenta_externa
)
and Farm.id_farm=Pieza.id_farm
and Variedad_Flor.id_variedad_flor=Pieza.id_variedad_flor
and Variedad_Flor.id_tipo_flor=Tipo_Flor.id_tipo_flor
and Grado_Flor.id_grado_flor=Pieza.id_grado_flor
and Grado_Flor.id_tipo_flor=Tipo_Flor.id_tipo_flor
and Factura.id_tipo_factura = Tipo_Factura.id_tipo_factura
and Tipo_Factura.orden_fija = @tipo_orden
and Farm.id_tipo_farm = Tipo_Farm.id_tipo_farm
and Tipo_Farm.id_tipo_farm in 
(
select id_tipo_farm from tipo_farm where idc_tipo_farm <> @idc_tipo_farm_direct and idc_tipo_farm <> @idc_tipo_farm_not_define)
and convert(nvarchar, Factura.fecha_factura, 101) = convert(nvarchar, @fecha_last_week, 101
)
group by Cliente_Despacho.idc_cliente_despacho,
Cliente_Factura.id_cliente_factura,
Cliente_Despacho.idc_cliente_despacho, 
Cliente_Despacho.nombre_cliente,
factura.idc_llave_factura+factura.idc_numero_factura, 
Factura.fecha_factura,
Detalle_Item_Factura.id_item_factura,
Item_Factura.cargo_incluido,
Farm.nombre_farm,
Tipo_Flor.nombre_tipo_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.nombre_grado_flor,
Pieza.marca,
Pieza.unidades_por_pieza
-----
alter table #tempweek
add valor_cargo_week decimal(20,4) NOT NULL default (0),
valor_unitario_week decimal(20,4) NOT NULL default (0),
total_week decimal(20,4) NOT NULL default (0),
promedio_week decimal (20,4) NOT NULL default (0)
----
update #tempweek
set valor_cargo_week = isnull(#temp2.valor_cargo, 0)
from #tempweek, #temp2
where #tempweek.id_item_factura=#temp2.id_item_factura
and #tempweek.cargo_incluido = 0
----
update #tempweek
set valor_unitario_week = valor_inicial/unidades,
total_week = valor_inicial + valor_cargo_week,
promedio_week = (valor_inicial + valor_cargo_week)/unidades
--------------------------------
create table #union (idc_cliente nvarchar(255), 
nombre_tipo_flor nvarchar(255), 
nombre_variedad_flor nvarchar(255), 
nombre_grado_flor nvarchar(255), 
unidades_year integer, 
gross_sales_year decimal(20,4), 
gross_unit_price_year decimal(20,4), 
unidades_week integer, 
gross_sales_week decimal(20,4), 
gross_unit_price_week decimal(20,4))
insert into #union (idc_cliente, nombre_tipo_flor, nombre_variedad_flor, nombre_grado_flor, unidades_year, gross_sales_year, gross_unit_price_year)
select 
ltrim(rtrim(convert(nvarchar, idc_cliente_despacho))),
ltrim(rtrim(convert(nvarchar, nombre_tipo_flor))),
ltrim(rtrim(convert(nvarchar, nombre_variedad_flor))),
ltrim(rtrim(convert(nvarchar, nombre_grado_flor))),
unidades,
total_year, 
promedio_year
from #tempyear

--------------------------------
insert into #union (idc_cliente, nombre_tipo_flor, nombre_variedad_flor, nombre_grado_flor, unidades_week, gross_sales_week, gross_unit_price_week)
select 
ltrim(rtrim(convert(nvarchar, idc_cliente_despacho))),
ltrim(rtrim(convert(nvarchar, nombre_tipo_flor))),
ltrim(rtrim(convert(nvarchar, nombre_variedad_flor))),
ltrim(rtrim(convert(nvarchar, nombre_grado_flor))),
unidades,
total_week, 
promedio_week
from #tempweek
------------------------
select 
ltrim(rtrim(convert(nvarchar, idc_cliente))) as idc_cliente,
ltrim(rtrim(convert(nvarchar, nombre_tipo_flor))) as nombre_tipo_flor,
ltrim(rtrim(convert(nvarchar, nombre_variedad_flor))) as nombre_variedad_flor,
ltrim(rtrim(convert(nvarchar, nombre_grado_flor))) as nombre_grado_flor,
sum(unidades_week) as units_sold_last_week,
sum(gross_sales_week) as gross_sales_last_week, 
avg(gross_unit_price_week) as gross_unit_price_last_week,
sum(unidades_year) as units_sold_last_year,
sum(gross_sales_year) as gross_sales_last_year, 
avg(gross_unit_price_year) as gross_unit_price_last_year,
isnull(sum(gross_sales_year)*1.10,0) as gross_sales_goals
from #union
group by 
ltrim(rtrim(convert(nvarchar, idc_cliente))),
ltrim(rtrim(convert(nvarchar, nombre_tipo_flor))),
ltrim(rtrim(convert(nvarchar, nombre_variedad_flor))),
ltrim(rtrim(convert(nvarchar, nombre_grado_flor)))
order by 
idc_cliente,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor
-----------------------
drop table #tempyear
drop table #tempweek
drop table #temp2
drop table #union
end