set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[inv_inventario_disponible_natural]

@accion nvarchar(255)

AS

declare @cantidad_dias_atras_inventario int,
@id_estado_pieza_open_market int,
@id_estado_pieza_hold int,
@cantidad_maxima int,
@query nvarchar(max),
@nombre_columna nvarchar(255),
@conteo int

select @cantidad_dias_atras_inventario = cantidad_dias_atras_inventario from configuracion_bd
select @id_estado_pieza_open_market = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Open Market'
select @id_estado_pieza_hold = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Hold'

select identity(int, 1,1) as id,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
farm.id_farm,
tapa.id_tapa,
caja.id_caja,
estado_pieza.id_estado_pieza,
color.id_color,
pieza.marca as code,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
color.nombre_color,
tipo_flor.nombre_tipo_flor,
pieza.unidades_por_pieza into #inventario
from pieza, 
tipo_flor,
variedad_flor,
grado_flor,
farm,
tipo_farm,
tipo_caja,
caja, 
color, 
tapa,
estado_pieza
where tipo_farm.id_tipo_farm = farm.id_tipo_farm
and tipo_farm.codigo <> 'D'
and pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and estado_pieza.id_estado_pieza in (@id_estado_pieza_open_market)
and pieza.disponible = 1
and pieza.tiene_marca = 0
and pieza.direccion_pieza <> 0
and pieza.direccion_pieza <> 6
and not exists
(
	select * 
	from detalle_item_factura
	where pieza.id_pieza = detalle_item_factura.id_pieza
)
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and pieza.id_farm = farm.id_farm
and pieza.id_caja = caja.id_caja
and caja.id_tipo_caja = tipo_caja.id_tipo_caja
and variedad_flor.id_color = color.id_color
and pieza.id_tapa = tapa.id_tapa
group by tipo_flor.id_tipo_flor,
color.id_color,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
farm.id_farm,
tapa.id_tapa,
caja.id_caja,
estado_pieza.id_estado_pieza,
pieza.marca,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
color.nombre_color,
tipo_flor.nombre_tipo_flor,
pieza.unidades_por_pieza
having 
count(pieza.id_pieza) > 0
order by tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
pieza.unidades_por_pieza

alter table #inventario
add precio decimal(20,4)

select id_variedad_flor,
id_grado_flor, 
code,
max(id_valor_producto) as id_valor_producto into #precio
from valor_producto 
where convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,101)) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101))
group by id_variedad_flor,
id_grado_flor,
code

alter table #precio
add precio decimal(20,4)

update #precio
set precio = valor_producto.precio
from valor_producto
where valor_producto.id_valor_producto = #precio.id_valor_producto

/*actualizar el precio de cada pieza*/
update #inventario
set precio = #precio.precio
from #precio
where #inventario.id_variedad_flor = #precio.id_variedad_flor
and #inventario.id_grado_flor = #precio.id_grado_flor
and #inventario.code = #precio.code

/*borrar items del inventario que no tengan precio vigente*/
delete from #inventario where precio is null

if(@accion = 'consultar_color_rosa')
begin
	select nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	id_tipo_flor into #rosa_spray
	from #inventario
	where id_tipo_flor = 88
	group by nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	id_tipo_flor

	select id_tipo_flor,
	nombre_tipo_flor into #matriz_color_rosa_spray
	from #rosa_spray
	group by id_tipo_flor,
	nombre_tipo_flor
	order by id_tipo_flor

	create table #color_agrupado_rosa_spray
	(
		id_tipo_flor int, 
		nombre_variedad_flor nvarchar(255)
	)

	set @cantidad_maxima = 50
	set @conteo = 1

	while(@cantidad_maxima > = @conteo)
	begin
		set @nombre_columna = null
		set @nombre_columna = 'Z' + convert(nvarchar,@conteo)

		insert into #color_agrupado_rosa_spray (id_tipo_flor, nombre_variedad_flor)
		select id_tipo_flor,
		nombre_variedad_flor
		from #rosa_spray	
		where id_variedad_flor in
		(
			select max(c.id_variedad_flor)
			from #rosa_spray as c
			group by c.id_tipo_flor
		)
		group by id_tipo_flor,
		nombre_variedad_flor

		set @query = null
		set @query = 'ALTER TABLE #matriz_color_rosa_spray ADD '+ @nombre_columna + ' nvarchar(255)'

		exec (@query)

		set @query = null
		set @query = 'update #matriz_color_rosa_spray set ' + @nombre_columna + ' = #color_agrupado_rosa_spray.nombre_variedad_flor from #color_agrupado_rosa_spray where #matriz_color_rosa_spray.id_tipo_flor = #color_agrupado_rosa_spray.id_tipo_flor' 

		exec (@query)

		set @conteo = @conteo + 1

		delete from #rosa_spray
		where id_variedad_flor in
		(
			select max(c.id_variedad_flor)
			from #rosa_spray as c
			group by c.id_tipo_flor
		)

		delete from #color_agrupado_rosa_spray
	end

	select nombre_color,
	id_color,
	nombre_variedad_flor, 
	id_variedad_flor,
	count(*) as cantidad into #color
	from #inventario
	where id_tipo_flor = 87
	and id_color not in (3,30)

	group by nombre_color,
	nombre_variedad_flor,
	id_variedad_flor,
	id_color

	select id_color,
	nombre_color into #matriz_color
	from #color
	group by id_color,
	nombre_color
	order by id_color

	create table #color_agrupado 
	(
		id_color int, 
		nombre_variedad_flor nvarchar(255)
	)

	set @cantidad_maxima = 50
	set @conteo = 1

	while(@cantidad_maxima > = @conteo)
	begin
		set @nombre_columna = null
		set @nombre_columna = 'Z' + convert(nvarchar,@conteo)

		insert into #color_agrupado (id_color, nombre_variedad_flor)
		select id_color,
		nombre_variedad_flor
		from #color	
		where id_variedad_flor in
		(
			select max(c.id_variedad_flor)
			from #color as c
			group by c.id_color
		)
		group by id_color,
		nombre_variedad_flor

		set @query = null
		set @query = 'ALTER TABLE #matriz_color ADD '+ @nombre_columna + ' nvarchar(255)'

		exec (@query)

		set @query = null
		set @query = 'update #matriz_color set ' + @nombre_columna + ' = #color_agrupado.nombre_variedad_flor from #color_agrupado where #matriz_color.id_color = #color_agrupado.id_color' 

		exec (@query)

		set @conteo = @conteo + 1

		delete from #color
		where id_variedad_flor in
		(
			select max(c.id_variedad_flor)
			from #color as c
			group by c.id_color
		)

		delete from #color_agrupado
	end

	select * into #matriz_color2
	from #matriz_color
	order by nombre_color

	select * 
	from #matriz_color2
	union all
	select * 
	from #matriz_color_rosa_spray

	drop table #matriz_color
	drop table #matriz_color2
	drop table #matriz_color_rosa_spray
	drop table #color_agrupado
	drop table #color_agrupado_rosa_spray
end
else
if(@accion = 'consultar_primer_inventario')
begin
	select @conteo = count(*)
	from #inventario
	where id_tipo_flor not in (87,88)

	set @conteo = @conteo/2 

	select id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	precio
	from #inventario
	where id < = @conteo
	and id_tipo_flor not in (87,88)
	group by id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	precio
end
else
if(@accion = 'consultar_segundo_inventario')
begin
	select @conteo = count(*)
	from #inventario
	where id_tipo_flor not in (87,88)

	set @conteo = @conteo/2 

	select id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	precio
	from #inventario
	where id > @conteo
	and id_tipo_flor not in (87,88)
	group by id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	precio
end
else
if(@accion = 'consultar_colores_rosa_precio')
begin
	select id_color,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	precio
	from #inventario
	where id_tipo_flor = 87
	and id_color in (3,30)
	group by id_color,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	precio
end