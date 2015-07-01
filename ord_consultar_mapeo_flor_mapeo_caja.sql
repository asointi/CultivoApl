set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_consultar_mapeo_flor_mapeo_caja]

@id_cliente_pedido int,
@id_tipo_flor nvarchar(10),
@id_variedad_flor nvarchar(10),
@id_grado_flor nvarchar(10),
@id_flor nvarchar(10),
@nombre_mapeo_mark nvarchar(255),
@nombre_mapeo_bouquet nvarchar(255),
@nombre_mapeo_type nvarchar(255),
@nombre_mapeo_grade nvarchar(255),
@numero_surtido nvarchar(255)

as

if(@nombre_mapeo_mark is null)
	set @nombre_mapeo_mark = ''
if(@nombre_mapeo_bouquet is null)
	set @nombre_mapeo_bouquet = ''
if(@nombre_mapeo_type is null)
	set @nombre_mapeo_type = ''
if(@nombre_mapeo_grade is null)
	set @nombre_mapeo_grade = ''
if(@numero_surtido is null)
	set @numero_surtido = '%%'

select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
mapeo_flor.id_mapeo_flor,
mapeo_flor.nombre_mapeo_bouquet,
mapeo_flor.nombre_mapeo_type,
mapeo_flor.nombre_mapeo_grade,
mapeo_flor.nombre_mapeo_mark,
flor.id_flor,
flor.idc_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(variedad_flor.nombre_variedad_flor))+space(1)+rtrim(ltrim(grado_flor.nombre_grado_flor))+space(1)+rtrim(ltrim(grado_flor.medidas)) as nombre_flor,
flor.surtido,
mapeo_caja.id_mapeo_caja,
mapeo_caja.id_caja,
mapeo_caja.nombre_mapeo_pack,
mapeo_caja.nombre_mapeo_box_type,
caja.nombre_caja + space(1) + '[' + tipo_caja.idc_tipo_caja + caja.idc_caja + ']' as nombre_caja,
isnull((
	select numero_surtido
	from mapeo_numero_surtido, 
	surtido_flor
	where mapeo_numero_surtido.id_surtido_flor = surtido_flor.id_surtido_flor
	and mapeo_numero_surtido.nombre_mapeo_mark = isnull(mapeo_flor.nombre_mapeo_mark, '') 
	and mapeo_numero_surtido.id_mapeo_caja = mapeo_caja.id_mapeo_caja
),0)
as numero_surtido,
(
	select surtido_flor.id_surtido_flor
	from mapeo_numero_surtido, surtido_flor
	where mapeo_numero_surtido.id_surtido_flor = surtido_flor.id_surtido_flor
	and mapeo_numero_surtido.nombre_mapeo_mark = isnull(mapeo_flor.nombre_mapeo_mark, '') 
	and mapeo_numero_surtido.id_mapeo_caja = mapeo_caja.id_mapeo_caja
)
as id_surtido_flor,
(
	select mapeo_numero_surtido.id_mapeo_numero_surtido
	from mapeo_numero_surtido, surtido_flor
	where mapeo_numero_surtido.id_surtido_flor = surtido_flor.id_surtido_flor
	and mapeo_numero_surtido.nombre_mapeo_mark = isnull(mapeo_flor.nombre_mapeo_mark, '') 
	and mapeo_numero_surtido.id_mapeo_caja = mapeo_caja.id_mapeo_caja
)
as id_mapeo_numero_surtido,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
mapeo_flor.id_cliente_pedido
into #temp
from mapeo_flor, 
mapeo_caja , 
flor,
variedad_flor, 
grado_flor, 
tipo_flor,
caja, 
tipo_caja
where mapeo_flor.id_mapeo_flor = mapeo_caja.id_mapeo_flor
and mapeo_flor.id_flor = flor.id_flor
and flor.id_variedad_flor = variedad_flor.id_variedad_flor
and flor.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and  tipo_flor.id_tipo_flor LIKE 
CASE 
	WHEN IsNumeric(@id_tipo_flor)=1 THEN @id_tipo_flor 
	ELSE '%%' 
END
and  variedad_flor.id_variedad_flor LIKE 
CASE 
	WHEN IsNumeric(@id_variedad_flor)=1 THEN @id_variedad_flor 
	ELSE '%%' 
END
and  grado_flor.id_grado_flor LIKE 
CASE 
	WHEN IsNumeric(@id_grado_flor)=1 THEN @id_grado_flor 
	ELSE '%%' 
END
and  flor.id_flor LIKE 
CASE 
	WHEN IsNumeric(@id_flor)=1 THEN @id_flor 
	ELSE '%%' 
END
and caja.id_caja = mapeo_caja.id_caja
and caja.id_tipo_caja = tipo_caja.id_tipo_caja
and lower(isnull(mapeo_flor.nombre_mapeo_mark, '')) like '%'+lower(@nombre_mapeo_mark)+'%'
and lower(mapeo_flor.nombre_mapeo_bouquet) like '%'+lower(@nombre_mapeo_bouquet)+'%'
and lower(mapeo_flor.nombre_mapeo_type) like '%'+lower(@nombre_mapeo_type)+'%'
and lower(mapeo_flor.nombre_mapeo_grade) like '%'+lower(@nombre_mapeo_grade)+'%'
and mapeo_flor.id_cliente_pedido > =
case
	when @id_cliente_pedido = 0 then 1
	else @id_cliente_pedido
end
and mapeo_flor.id_cliente_pedido < =
case
	when @id_cliente_pedido = 0 then 99999
	else @id_cliente_pedido
end
and variedad_flor.disponible = 1
and grado_flor.disponible = 1
and caja.disponible = 1

select *
from #temp 
where numero_surtido LIKE 
CASE 
	WHEN IsNumeric(@numero_surtido)=1 THEN @numero_surtido 
	ELSE '%%' 
END
order by 
nombre_mapeo_bouquet,
nombre_mapeo_type,
nombre_mapeo_grade,
id_mapeo_flor,
nombre_mapeo_box_type,
nombre_mapeo_pack

drop table #temp