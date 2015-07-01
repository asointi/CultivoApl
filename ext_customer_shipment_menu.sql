/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ext_customer_shipment_menu]

@fecha_inicial datetime,
@fecha_final datetime,
@id_cuenta_externa int,
@con_cargos bit

AS
BEGIN

IF (@fecha_final >= dateadd(dd,0,datediff(dd,0,getdate())))
BEGIN 

	IF(getdate() < dateadd(hh,18,dateadd(dd,0,datediff(dd,0,getdate()))))
		set @fecha_final = dateadd(dd,-1,@fecha_final)
END

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
into #temp1
FROM         
Detalle_Item_Factura, Pieza, Item_Factura, Caja, Tipo_Caja, Factura, Cliente_Despacho, Cliente_Factura,
Farm, Tipo_Flor, Variedad_Flor, Grado_Flor
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
and Factura.fecha_factura between @fecha_inicial and @fecha_final
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
order by fecha_factura DESC
-----
SELECT 
Item_Factura.id_item_factura, Cargo.id_cargo, 
Cargo.valor_cargo * COUNT(Pieza.Id_pieza) AS valor_cargo
into #temp2
FROM Cargo, Item_Factura, Detalle_Item_Factura, Pieza
where Cargo.id_item_factura = Item_Factura.id_item_factura
and Item_Factura.id_item_factura = Detalle_Item_Factura.id_item_factura
and Detalle_Item_Factura.Id_pieza = Pieza.Id_pieza
GROUP BY Item_Factura.id_item_factura, Cargo.id_cargo,Cargo.valor_cargo
----
alter table #temp1
add valor_cargo decimal(20,4) NOT NULL default (0),
valor_unitario decimal(20,4) NOT NULL default (0),
total decimal(20,4) NOT NULL default (0),
promedio decimal (20,4) NOT NULL default (0)
----
update #temp1
set valor_cargo = isnull(#temp2.valor_cargo, 0)
from #temp1, #temp2
where #temp1.id_item_factura=#temp2.id_item_factura
and #temp1.cargo_incluido = 0
----
update #temp1
set valor_unitario = valor_inicial/unidades,
total = valor_inicial + valor_cargo,
promedio = (valor_inicial + valor_cargo)/unidades
----
IF @con_cargos = 1
BEGIN
	select
	idc_cliente_despacho as [Customer Code],
	fecha_factura as [Invoice Date],
	nombre_farm as [Farm],
	nombre_tipo_flor as [Flower Type],
	nombre_variedad_flor as [Flower Variety],
	nombre_grado_flor as [Flower Grade],
	marca as [Mark],
	unidades_por_pieza as [Pack],
	fulls as [Fulls],
	unidades as [Units],
	valor_inicial as [Value],
	valor_unitario as [Unit Cost],
	valor_cargo as [Box Charges],
	total as [Total Cost],
	promedio as [Average],
	nombre_cliente as [Customer],
	numero_factura as [Invoice Number]
	from #temp1
	where cargo_incluido = 0
END
ELSE
BEGIN
	select
	idc_cliente_despacho as [Customer Code],
	fecha_factura as [Invoice Date],
	nombre_farm as [Farm],
	nombre_tipo_flor as [Flower Type],
	nombre_variedad_flor as [Flower Variety],
	nombre_grado_flor as [Flower Grade],
	marca as [Mark],
	unidades_por_pieza as [Pack],
	fulls as [Fulls],
	unidades as [Units],
	valor_inicial as [Value],
	valor_unitario as [Unit Cost],
	total as [Total Cost],
	promedio as [Average],
	nombre_cliente as [Customer],
	numero_factura as [Invoice Number]
	from #temp1
	where cargo_incluido = 1
END
------
drop table #temp2
drop table #temp1
RETURN 
END