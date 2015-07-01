/****** Object:  StoredProcedure [dbo].[awb_consultar_tablero_guias_version2]    Script Date: 04/02/2013 10:36:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[awb_consultar_tablero_guias_version2]

@estado nvarchar(255),
@ciudad nvarchar(255) = null,
@aerolinea nvarchar(255) = null

AS

declare @flying nvarchar(2),
@arriving nvarchar(2),
@warehouse nvarchar(2),
@fecha_corte_guias datetime,
@fecha datetime,
@fecha_final datetime,
@id int,
@conteo int,
@id_guia int

create table #temp (id int)

create table #visualizar_datos
(
	id_guia int,
	dato nvarchar(max) null default('Info Receiving'),
	dato_estados_guias nvarchar(max) null default('')
)

create table #guia
(
	id int identity (1,1),
	id_guia int
)

create table #fechas
(
	id int identity (1,1),
	id_guia int,
	fecha_inicial datetime,
	fecha_final datetime
)

create table #direccion_pieza
(
	id int identity (1,1),
	id_guia int,
	id_estado_guia int,
	id_pieza int,
	factor_a_full decimal(20,3),
	fecha_transaccion datetime,
	fecha_inicial datetime null,
	fecha_final datetime null,
	idc_direccion_pieza int,
	id_direccion_pieza int,
	fecha_salida datetime,
	fecha_llegada datetime,
	fecha_llamada_pq datetime,
	fecha_llegada_pq datetime,
	fecha_paso_pq datetime,
	fecha_conductor_llega_a_aerolinea datetime,
	fecha_llegada_vuelo_a_natural datetime,
	fecha_estado datetime
)

create table #detalle_informacion_guias
(
	id int identity (1,1),
	id_guia int,
	id_estado_guia int,
	fecha datetime,
	Estado nvarchar(50)
)

select @fecha_corte_guias = fecha_corte_guias from configuracion_bd
set @flying = '6'
set @arriving = '8'
set @warehouse = 'A'

if(@estado = 'Todas')
begin
	insert into #temp (id)
	select id_estado_guia from estado_guia
	where idc_estado_guia <> 'C'
end
else
begin
	insert into #temp (id)
	select id_estado_guia from estado_guia
	where idc_estado_guia = @flying
	union all
	select id_estado_guia from estado_guia
	where idc_estado_guia = @arriving
end

select guia.id_guia,
estado_guia.id_estado_guia,
estado_guia.idc_estado_guia, 
estado_guia.nombre_estado_guia,
max(fecha_estado_guia.fecha_transaccion) as fecha_transaccion into #estado_guias
from guia,
fecha_estado_guia,
estado_guia,
#temp
where guia.id_guia = fecha_estado_guia.id_guia
and estado_guia.id_estado_guia = fecha_estado_guia.id_estado_guia
and estado_guia.id_estado_guia = #temp.id
and guia.fecha_guia > = @fecha_corte_guias
group by guia.id_guia,
estado_guia.id_estado_guia,
estado_guia.nombre_estado_guia,
estado_guia.idc_estado_guia

insert into #direccion_pieza 
(
	id_guia, 	
	id_estado_guia,
	fecha_salida,
	fecha_llegada,
	fecha_llamada_pq,
	fecha_llegada_pq,
	fecha_paso_pq,
	fecha_conductor_llega_a_aerolinea,
	fecha_llegada_vuelo_a_natural,
	fecha_estado,
	id_pieza, 
	factor_a_full, 
	fecha_transaccion, 
	idc_direccion_pieza, 
	id_direccion_pieza
)
select guia.id_guia,
estado_guia.id_estado_guia,
guia.fecha_salida,
guia.fecha_llegada,
guia.fecha_llamada_pq,
guia.fecha_llegada_pq,
guia.fecha_paso_pq,
guia.fecha_conductor_llega_a_aerolinea,
guia.fecha_llegada_vuelo_a_natural,
guia.fecha_transaccion as fecha_estado,
pieza.id_pieza,
tipo_caja.factor_a_full,
direccion_pieza.fecha_transaccion,
direccion_pieza.idc_direccion_pieza,
direccion_pieza.id_direccion_pieza
from pieza,
direccion_pieza,
guia,
estado_guia,
caja,
tipo_caja
where pieza.id_pieza = direccion_pieza.id_pieza
and guia.id_guia = pieza.id_guia
and estado_guia.id_estado_guia = guia.id_estado_guia
and estado_guia.idc_estado_guia in ('6', '8')
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
order by guia.id_guia,
direccion_pieza.fecha_transaccion 

insert into #guia (id_guia)
select id_guia
from #direccion_pieza
group by id_guia
order by id_guia

select @conteo = count(*) from #guia
set @id = 1

while(@id < = @conteo)
begin
	select @id_guia = id_guia from #guia where id = @id

	select @fecha = min(fecha_transaccion)
	from #direccion_pieza
	where fecha_inicial is null
	and id_guia = @id_guia

	while(@fecha is not null)
	begin
		update #direccion_pieza
		set fecha_inicial = @fecha
		where fecha_transaccion between
		@fecha and dateadd(mi, 60, @fecha)
		and id_guia = @id_guia

		select @fecha_final = max(fecha_transaccion)
		from #direccion_pieza
		where fecha_inicial is not null
		and id_guia = @id_guia

		update #direccion_pieza
		set fecha_final = @fecha_final
		where fecha_inicial = @fecha
		and id_guia = @id_guia
		
		select @fecha = min(fecha_transaccion)
		from #direccion_pieza
		where fecha_inicial is null
		and id_guia = @id_guia
	end

	set @id = @id + 1
end

insert into #fechas (id_guia, fecha_inicial, fecha_final)
select id_guia,
fecha_inicial,
fecha_final
from #direccion_pieza
group by id_guia,
fecha_inicial,
fecha_final
order by id_guia,
fecha_inicial,
fecha_final

insert into #visualizar_datos (id_guia)
select #fechas.id_guia
from #fechas
group by #fechas.id_guia

select id_guia,
id_estado_guia,
fecha_salida,
fecha_llegada,
fecha_llamada_pq,
fecha_llegada_pq,
fecha_paso_pq,
fecha_conductor_llega_a_aerolinea,
fecha_llegada_vuelo_a_natural into #informacion_guias
from #direccion_pieza
group by
id_guia,
id_estado_guia,
fecha_salida,
fecha_llegada,
fecha_llamada_pq,
fecha_llegada_pq,
fecha_paso_pq,
fecha_conductor_llega_a_aerolinea,
fecha_llegada_vuelo_a_natural

insert into #detalle_informacion_guias
(
	id_guia,
	id_estado_guia,
	fecha,
	Estado
)
select id_guia,
id_estado_guia,
fecha_salida as fecha,
'Departure' as Estado
from #informacion_guias
where fecha_salida is not null
group by id_guia,
id_estado_guia,
fecha_salida
union all
select id_guia,
id_estado_guia,
fecha_llegada,
'Arrival  '
from #informacion_guias
where fecha_llegada is not null
group by id_guia,
id_estado_guia,
fecha_llegada
union all
select id_guia,
id_estado_guia,
fecha_llamada_pq,
'Called PQ'
from #informacion_guias
where fecha_llamada_pq is not null
group by id_guia,
id_estado_guia,
fecha_llamada_pq
union all
select id_guia,
id_estado_guia,
fecha_llegada_pq,
'Arrived PQ'
from #informacion_guias
where fecha_llegada_pq is not null
group by id_guia,
id_estado_guia,
fecha_llegada_pq
union all
select id_guia,
id_estado_guia,
fecha_paso_pq,
'Passed PQ'
from #informacion_guias
where fecha_paso_pq is not null
group by id_guia,
id_estado_guia,
fecha_paso_pq
union all
select id_guia,
id_estado_guia,
fecha_conductor_llega_a_aerolinea,
'Drv. arr airl'
from #informacion_guias
where fecha_conductor_llega_a_aerolinea is not null
group by id_guia,
id_estado_guia,
fecha_conductor_llega_a_aerolinea
union all
select id_guia,
id_estado_guia,
fecha_llegada_vuelo_a_natural,
'Trk. Arr NF'
from #informacion_guias
where fecha_llegada_vuelo_a_natural is not null
group by id_guia,
id_estado_guia,
fecha_llegada_vuelo_a_natural
union all
select #estado_guias.id_guia,
#estado_guias.id_estado_guia,
#estado_guias.fecha_transaccion,
CASE
	WHEN LEN(#estado_guias.nombre_estado_guia) < 7 THEN #estado_guias.nombre_estado_guia + '  '
	ELSE #estado_guias.nombre_estado_guia
END
from #estado_guias
where exists
(
	select *
	from #guia
	where #guia.id_guia = #estado_guias.id_guia
)
group by #estado_guias.id_guia,
#estado_guias.id_estado_guia,
#estado_guias.fecha_transaccion,
CASE
	WHEN LEN(#estado_guias.nombre_estado_guia) < 7 THEN #estado_guias.nombre_estado_guia + '  '
	ELSE #estado_guias.nombre_estado_guia
END
order by id_guia,
fecha

select @conteo = count(*) from #fechas
set @id = 1

while(@id < = @conteo)
begin
	select @id_guia = id_guia from #fechas where id = @id

	update #visualizar_datos
	set dato = dato + char(13) +
	(
		select char(9) + char(9) + convert(nvarchar, #fechas.fecha_final, 101) + char(9) +
		left(convert(nvarchar, #fechas.fecha_final, 108), 5) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza)) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 6 and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza))	from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza))	from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1) and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza))	from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 6  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia	and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1)  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + char(9) +
		convert(nvarchar,
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 6 and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) +
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) +
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1) and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) +
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) 
		) + char(9) + 
		convert(nvarchar,
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 6  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + 
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + 
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1)  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza)) + 
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #fechas.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #fechas.fecha_final group by #direccion_pieza.id_pieza))
		)
		from #fechas
		where #fechas.id = @id
	)
	where #visualizar_datos.id_guia = @id_guia

	set @id = @id + 1
end

select @conteo = count(*) from #detalle_informacion_guias
set @id = 1

while(@id < = @conteo)
begin
	select @id_guia = id_guia from #detalle_informacion_guias where id = @id

	update #visualizar_datos
	set dato_estados_guias = dato_estados_guias + char(13) +
	(
		select #detalle_informacion_guias.Estado + char(9) + convert(nvarchar, #detalle_informacion_guias.fecha, 101) + char(9) +
		left(convert(nvarchar, #detalle_informacion_guias.fecha, 108), 5) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza)) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 6 and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza))	from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza))	from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1) and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,count(#direccion_pieza.id_pieza))	from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 6  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1) and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		(select convert(nvarchar,isnull(sum(#direccion_pieza.factor_a_full), 0)) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + char(9) +
		convert(nvarchar,
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 6 and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) +
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) + 
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1) and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) +
		(select count(#direccion_pieza.id_pieza) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza))
		) + char(9) + 
		convert(nvarchar,
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 6  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) +
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 8  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) +
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and (#direccion_pieza.idc_direccion_pieza > 8 or #direccion_pieza.idc_direccion_pieza = 1) and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza)) +
		(select isnull(sum(#direccion_pieza.factor_a_full), 0) from #direccion_pieza where #detalle_informacion_guias.id_guia = #direccion_pieza.id_guia	and #direccion_pieza.idc_direccion_pieza = 0  and #direccion_pieza.id_direccion_pieza in (select max(#direccion_pieza.id_direccion_pieza) from #direccion_pieza where #direccion_pieza.fecha_transaccion < = #detalle_informacion_guias.fecha group by #direccion_pieza.id_pieza))
		)
		from #detalle_informacion_guias
		where #detalle_informacion_guias.id = @id
	)
	where #visualizar_datos.id_guia = @id_guia

	set @id = @id + 1
end

select guia.id_guia,
guia.idc_guia,
guia.id_ciudad,
guia.id_aerolinea,
guia.id_dia_guia,
guia.id_mes_guia,
guia.fecha_guia,
guia.fecha_cambio_estado,
guia.numero_vuelo,
guia.fecha_salida,
guia.fecha_llegada,
guia.fecha_llamada_terminal,
guia.fecha_llamada_pq,
guia.fecha_paso_pq,
guia.nota_pq,
guia.vuelos_adelante_para_pq,
guia.fecha_transaccion,
guia.valor_impuesto,
guia.valor_flete,
estado_guia.id_estado_guia,
estado_guia.idc_estado_guia,
estado_guia.nombre_estado_guia,
ciudad.codigo_aeropuerto as idc_ciudad,
aerolinea.nombre_aerolinea,
guia.fecha_guia as awb_date,
RIGHT(guia.idc_guia,4) as awb_number,
LEFT(guia.idc_guia,3) as idc_airline,
(select #estado_guias.fecha_transaccion from #estado_guias where guia.id_guia = #estado_guias.id_guia and #estado_guias.idc_estado_guia = @flying) as fecha_flying,
(select #estado_guias.fecha_transaccion from #estado_guias where guia.id_guia = #estado_guias.id_guia and #estado_guias.idc_estado_guia = @arriving) as fecha_arriving,
(select #estado_guias.fecha_transaccion from #estado_guias where guia.id_guia = #estado_guias.id_guia and #estado_guias.idc_estado_guia = @warehouse) as fecha_warehouse,
[dbo].[formato_fecha] (guia.fecha_salida, 'puntual') as fecha_salida_formato,
[dbo].[formato_fecha] (guia.fecha_llegada, 'puntual') as fecha_llegada_formato,
[dbo].[formato_fecha] (guia.fecha_llamada_terminal, 'puntual') as fecha_llamada_terminal_formato,
[dbo].[formato_fecha] (guia.fecha_llamada_pq, 'puntual') as fecha_llamada_pq_formato,
[dbo].[formato_fecha] (guia.fecha_paso_pq, 'puntual') as fecha_paso_pq_formato,
[dbo].[formato_fecha] (guia.fecha_guia, 'general') as awb_date_formato,
[dbo].[formato_fecha] ((select #estado_guias.fecha_transaccion from #estado_guias where guia.id_guia = #estado_guias.id_guia and #estado_guias.idc_estado_guia = @flying), 'puntual') as fecha_flying_formato,
[dbo].[formato_fecha] ((select #estado_guias.fecha_transaccion from #estado_guias where guia.id_guia = #estado_guias.id_guia and #estado_guias.idc_estado_guia = @arriving), 'puntual') as fecha_arriving_formato,
[dbo].[formato_fecha] ((select #estado_guias.fecha_transaccion from #estado_guias where guia.id_guia = #estado_guias.id_guia and #estado_guias.idc_estado_guia = @warehouse), 'puntual') as fecha_warehouse_formato,
(select count(pieza.id_pieza) from pieza where guia.id_guia = pieza.id_guia) as cantidad_piezas,
(
	select sum(tipo_caja.factor_a_full) 
	from tipo_caja, 
	caja, 
	pieza
	where tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = pieza.id_caja
	and guia.id_guia = pieza.id_guia
) as nombre_terminal,
(
	guia.idc_guia + char(9) + 'Temperature: ' + isnull(convert(nvarchar,convert(decimal(20,1),guia.temperatura)), '') + char(13) + 
case
	WHEN	(select dato_estados_guias from #visualizar_datos where #visualizar_datos.id_guia = guia.id_guia) IS NULL AND
			(select dato from #visualizar_datos where #visualizar_datos.id_guia = guia.id_guia) IS NULL THEN ''
	ELSE
	(
		char(9) + char(9) + 'date' + char(9) + char(9) +
		'time' + char(9) +
		'p-fly' + char(9) +
		'p-arr' + char(9) +
		'p-wah' + char(9) +
		'p-prb' + char(9) +
		'f-fly' + char(9) +
		'f-arr' + char(9) +
		'f-wah' + char(9) +
		'f-prb' + char(9) +
		'p-total' + char(9) +
		'f-total'
	)
END
) as encabezado,
(select dato_estados_guias from #visualizar_datos where #visualizar_datos.id_guia = guia.id_guia) as estado_guia,
(select dato from #visualizar_datos where #visualizar_datos.id_guia = guia.id_guia) as lectura_piezas into #resultado
from guia,
estado_guia,
ciudad,
aerolinea
where estado_guia.id_estado_guia = guia.id_estado_guia
and ciudad.id_ciudad = guia.id_ciudad
and aerolinea.id_aerolinea = guia.id_aerolinea
and ciudad.codigo_aeropuerto > =
case
	when @ciudad = '>>ALL' then '   '
	else @ciudad
end
and ciudad.codigo_aeropuerto < =
case
	when @ciudad = '>>ALL' then 'ZZZ'
	else @ciudad
end
and aerolinea.nombre_aerolinea > =
case
	when @aerolinea = '>>ALL' then '                    '
	else @aerolinea
end
and aerolinea.nombre_aerolinea < =
case
	when @aerolinea = '>>ALL' then 'ZZZZZZZZZZZZZZZZZZZZ'
	else @aerolinea
end
and estado_guia.id_estado_guia in (select id from #temp)
and guia.fecha_guia > = @fecha_corte_guias

select * 
from #resultado
where cantidad_piezas > 0
order by fecha_guia DESC

drop table #temp
drop table #estado_guias
drop table #resultado
drop table #direccion_pieza
drop table #guia
drop table #fechas
drop table #visualizar_datos
drop table #informacion_guias
drop table #detalle_informacion_guias