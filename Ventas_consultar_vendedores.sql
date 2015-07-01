create PROCEDURE [dbo].[Ventas_consultar_vendedores] 

as

DECLARE @fecha_inicial_semana datetime,
@fecha_final_semana datetime,
@fecha_inicial_mes datetime,
@fecha_final_mes datetime

/*ingresar el primer y ùltimo dìa de la semana inmediatamente anterior*/
SELECT @fecha_inicial_semana = DATEADD(WK, DATEDIFF(WK,0,dateadd(wk, -1, GETDATE())),0)
SELECT @fecha_final_semana = @fecha_inicial_semana + 6

/*ingresar el primer y ùltimo dìa del mes inmediatamente anterior*/
SELECT @fecha_inicial_mes = DATEADD(m, DATEDIFF(m,0,dateadd(m, 0, GETDATE())),0)
SELECT @fecha_final_mes = @fecha_final_semana

/*consultar los vendedores con ventas de tipo Open Market y PreBook en el mes corrido*/
select vendedor.id_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
vendedor.correo,
vendedor.idc_vendedor into #vendedores
from pieza,
detalle_item_factura,
item_factura,
factura,
vendedor,
cliente_factura,
cliente_despacho,
tipo_factura,
farm,
tipo_farm
where pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and cliente_despacho.id_despacho = factura.id_despacho
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and farm.id_farm = pieza.id_farm
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and tipo_farm.codigo <> 'D'
and tipo_factura.idc_tipo_factura in ('1', '4')
and factura.fecha_factura between
@fecha_inicial_mes and @fecha_final_mes

union all

/*consultar los vendedores con ventas de tipo Open Market y PreBook en  la semana inmediatamente anterior*/
select vendedor.id_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
vendedor.correo,
vendedor.idc_vendedor
from pieza,
detalle_item_factura,
item_factura,
factura,
vendedor,
cliente_factura,
cliente_despacho,
tipo_factura,
farm,
tipo_farm
where pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and cliente_despacho.id_despacho = factura.id_despacho
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and farm.id_farm = pieza.id_farm
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and tipo_farm.codigo <> 'D'
and tipo_factura.idc_tipo_factura in ('1', '4')
and factura.fecha_factura between
@fecha_inicial_semana and @fecha_final_semana

select id_vendedor,
nombre_vendedor,
correo,
convert(nvarchar, @fecha_inicial_semana, 103) + ' - ' + convert(nvarchar, @fecha_final_semana, 103) as fecha
from #vendedores
where correo is not null
and len(correo) > 7
and idc_vendedor not in ('020', '40', '500', '900', '990', '995', '997')
group by id_vendedor,
nombre_vendedor,
correo

drop table #vendedores

