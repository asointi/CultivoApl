set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_consultar_cliente_despacho_por_codigo]

@idc_cliente_despacho nvarchar(25)

AS

select id_despacho,
idc_cliente_despacho,
ltrim(rtrim(nombre_cliente)) as nombre_cliente,
ltrim(rtrim(contacto)) as contacto,
ltrim(rtrim(direccion)) as direccion,
ltrim(rtrim(ciudad)) as ciudad,
estado,
telefono,
fax,
requiere_precio_retail,
requiere_upc_date,
delivery_cube_rate,
delivery_fuel_surcharge,
delivery_piece_fee
from cliente_despacho
where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho