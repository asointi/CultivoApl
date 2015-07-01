/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[prod_generar_reporte_TV_tablero5]

AS

declare @id int,
@conteo int,
@id_persona_aux int,
@id_persona1 int,
@fecha_aux datetime,
@fecha_consulta datetime

set @fecha_consulta = convert(nvarchar, getdate(), 101)

select p.id_persona into #persona
from labor as l,
detalle_labor as dl, 
detalle_labor_persona as dlp, 
persona as p
where l.id_labor = dl.id_labor
and dl.id_detalle_labor = dlp.id_detalle_labor
and dlp.id_persona = p.id_persona
and l.idc_labor = 'RO'
and convert(datetime, convert(nvarchar, dlp.fecha,101)) = @fecha_consulta
group by p.id_persona

/*calcular datos sobre la produccion de los trabajadores en determinada labor*/
create table #temp
(
	id int identity(1,1),
	id_persona int,
	idc_labor nvarchar(25),
	idc_detalle_labor nvarchar(25),
	fecha datetime
)

insert into #temp 
select persona.id_persona,
labor.idc_labor,
detalle_labor.idc_detalle_labor,
detalle_labor_persona.fecha
from labor, 
detalle_labor, 
detalle_labor_persona, 
persona
where labor.id_labor = detalle_labor.id_labor
and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
and detalle_labor_persona.id_persona = persona.id_persona
and exists
(
	select *
	from #persona
	where #persona.id_persona = persona.id_persona
)
and convert(datetime,convert(nvarchar,detalle_labor_persona.fecha,101)) = @fecha_consulta
order by persona.id_persona, 
detalle_labor_persona.fecha, 
detalle_labor.idc_detalle_labor

alter table #temp
add tiempo int,
persona_activa bit

/*calcular tiempo a las personas que han cerrado tiempo o han cambiado de actividad*/
select @id = count(*) from #temp
set @conteo = 1

while(@conteo < = @id)
begin
	set @fecha_aux = null
	select @id_persona1 = id_persona from #temp where id = @conteo
	select @id_persona_aux = id_persona from #temp where id = @conteo + 1

	select @fecha_aux = fecha 
	from #temp 
	where id = @conteo + 1 
	and @id_persona1 = @id_persona_aux

	update #temp
	set tiempo = datediff(mi, fecha, @fecha_aux)
	where id = @conteo

	set @conteo = @conteo + 1
end

update #temp
set tiempo = 0
where tiempo is null
and idc_detalle_labor = 'ZZZZZZ'

update #temp
set tiempo = 
case
	when datediff(mi, fecha, getdate()) < 0 then 0
	else datediff(mi, fecha, getdate())
end,
persona_activa = 1
where tiempo is null

select ramo_despatado.id_ramo_despatado,
ramo_despatado.idc_ramo_despatado into #ramos_devueltos
from ramo_despatado,
ramo_devuelto
where ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado
and convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha_consulta

alter table #ramos_devueltos
add ramo_real bit

update #ramos_devueltos
set ramo_real = 1
from ramo
where ramo.idc_ramo = #ramos_devueltos.idc_ramo_despatado

update #ramos_devueltos
set ramo_real = 1
from ramo_comprado
where ramo_comprado.idc_ramo_comprado = #ramos_devueltos.idc_ramo_despatado

select ramo_despatado.id_ramo_despatado,
persona.id_persona,
ramo_despatado.idc_ramo_despatado,
ramo_despatado.fecha_lectura,
ramo_despatado.tallos_por_ramo into #ramo
from ramo_despatado,
persona
where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha_consulta
and ramo_despatado.id_persona = persona.id_persona
and not exists
(
	select *
	from #ramos_devueltos
	where #ramos_devueltos.id_ramo_despatado = ramo_despatado.id_ramo_despatado
	and #ramos_devueltos.ramo_real is null
)

alter table #ramo
add id_punto_corte int

update #ramo
set id_punto_corte = punto_corte.id_punto_corte
from punto_corte,
ramo
where ramo.id_punto_corte = punto_corte.id_punto_corte
and ramo.idc_ramo = #ramo.idc_ramo_despatado
and #ramo.tallos_por_ramo <> 12

update #ramo
set id_punto_corte = punto_corte.id_punto_corte
from ramo_comprado,
finca,
finca_asignada,
etiqueta_impresa_finca_asignada,
punto_corte
where ramo_comprado.id_punto_corte = punto_corte.id_punto_corte
and finca.id_finca = finca_asignada.id_finca
and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada
and ramo_comprado.idc_ramo_comprado = #ramo.idc_ramo_despatado
and #ramo.tallos_por_ramo <> 12
and finca.idc_finca <> 'ZX'

update #ramo
set id_punto_corte = 999
from ramo_comprado,
finca,
finca_asignada,
etiqueta_impresa_finca_asignada
where finca.id_finca = finca_asignada.id_finca
and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada
and ramo_comprado.idc_ramo_comprado = #ramo.idc_ramo_despatado
and #ramo.tallos_por_ramo <> 12
and finca.idc_finca = 'ZX'

select 'X 12' as tipo_ramo, 
isnull(sum(tallos_por_ramo), 0) as cantidad_tallos,
'1.3' as factor,
isnull(sum(tallos_por_ramo), 0) * 1.3 as cantidad_tallos_proyectados into #ramo2
from #ramo
where tallos_por_ramo = 12

union all

select 'EEUU',
isnull(sum(tallos_por_ramo), 0),
'1',
isnull(sum(tallos_por_ramo), 0) * 1
from #ramo,
punto_corte
where punto_corte.id_punto_corte = #ramo.id_punto_corte
and punto_corte.idc_punto_corte = ''

union all

select 'RUSIA',
isnull(sum(tallos_por_ramo), 0),
'1.25',
isnull(sum(tallos_por_ramo), 0) * 1.25
from #ramo,
punto_corte
where punto_corte.id_punto_corte = #ramo.id_punto_corte
and (punto_corte.idc_punto_corte = 'R'
or punto_corte.idc_punto_corte = 'Q')

union all

select 'REEMBONCHE',
isnull(sum(tallos_por_ramo), 0),
'1.3',
isnull(sum(tallos_por_ramo), 0) * 1.3
from #ramo
where id_punto_corte = 999

union all

select 'SIN PIST',
isnull(sum(tallos_por_ramo), 0),
'1',
isnull(sum(tallos_por_ramo), 0)
from #ramo
where id_punto_corte is null
and tallos_por_ramo <> 12

union all

select top 1 'Total Tallos',
isnull((
	select sum(tallos_por_ramo)
	from #ramo
), 0),
null,
isnull((
	isnull((
		select sum(tallos_por_ramo) * 1.3 as cantidad_tallos_proyectados
		from #ramo
		where tallos_por_ramo = 12
	), 0) + 
	isnull((
		select sum(tallos_por_ramo) * 1
		from #ramo,
		punto_corte
		where punto_corte.id_punto_corte = #ramo.id_punto_corte
		and punto_corte.idc_punto_corte = ''
	), 0) +
	isnull((
		select sum(tallos_por_ramo) * 1.25
		from #ramo,
		punto_corte
		where punto_corte.id_punto_corte = #ramo.id_punto_corte
		and (punto_corte.idc_punto_corte = 'R'
		or punto_corte.idc_punto_corte = 'Q')
	), 0) + 
	isnull((
		select sum(tallos_por_ramo) * 1.3
		from #ramo
		where id_punto_corte = 999
	), 0) +
	isnull((
		select sum(tallos_por_ramo)
		from #ramo
		where id_punto_corte is null
		and tallos_por_ramo <> 12
	), 0)
), 0) from #ramo

select 'Postcosecha' as labor,
(
	select count(distinct id_persona)
	from #temp
	where persona_activa = 1
	and idc_labor = 'RO'
) as cantidad_personas,
(
	select convert(decimal(20,4), sum(tiempo))/60
	from #temp
	where idc_labor = 'RO'
) as horas_acumuladas,
(
	select isnull(sum(tallos_por_ramo), 0)
	from ramo_despatado
	where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha_consulta
) as tallos_bonchados,
(
	select isnull(sum(tallos_por_ramo), 0)
	from ramo_despatado
	where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha_consulta
) /
CASE 
	WHEN 
	(
		select convert(decimal(20,4),sum(tiempo))/60
		from #temp
		where idc_labor = 'RO'
	) = convert(decimal(20,4),0) THEN NULL
	ELSE
	(
		select convert(decimal(20,4),sum(tiempo))/60
		from #temp
		where idc_labor = 'RO'
	)
END as rendimiento  into #temp2
union all
select 'Bonchado',
(
	select count(distinct id_persona)
	from #temp
	where persona_activa = 1
	and idc_detalle_labor = 'CLASRO'
) as cantidad_personas,
(
	select convert(decimal(20,4),sum(tiempo))/60
	from #temp
	where idc_detalle_labor = 'CLASRO'
) as horas_acumuladas,
(
	select isnull(sum(tallos_por_ramo), 0)
	from ramo_despatado
	where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha_consulta
) as tallos_bonchados,
(
	select isnull(sum(tallos_por_ramo), 0)
	from ramo_despatado
	where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha_consulta
) /
CASE 
	WHEN 
	(
		select convert(decimal(20,4),sum(tiempo))/60
		from #temp
		where idc_detalle_labor = 'CLASRO'
	) = convert(decimal(20,4),0) THEN NULL
	ELSE
	(
		select convert(decimal(20,4),sum(tiempo))/60
		from #temp
		where idc_detalle_labor = 'CLASRO'
	)
END as rendimiento

update postcosecha_pantalla
set cantidad_personas = #temp2.cantidad_personas, 
horas_acumuladas = #temp2.horas_acumuladas, 
tallos_bonchados = #temp2.tallos_bonchados, 
rendimiento = #temp2.rendimiento
from #temp2
where postcosecha_pantalla.labor = #temp2.labor

update ramo_pantalla
set cantidad_tallos = #ramo2.cantidad_tallos, 
factor = #ramo2.factor, 
cantidad_tallos_proyectados = #ramo2.cantidad_tallos_proyectados
from #ramo2
where ramo_pantalla.tipo_ramo = #ramo2.tipo_ramo 

update ramo_pantalla
set cantidad_tallos = null,
cantidad_tallos_proyectados = null
where not exists
(
	select * 
	from #ramo2
	where ramo_pantalla.tipo_ramo = #ramo2.tipo_ramo 
)

update ramo_pantalla
set factor = (select convert(int,round(convert(decimal(20,1),rendimiento), 0)) from #temp2 where labor = 'Postcosecha')
where tipo_ramo = 'Total Tallos'

update postcosecha_pantalla
set tallos_bonchados = ramo_pantalla.cantidad_tallos,
rendimiento = ramo_pantalla.cantidad_tallos / postcosecha_pantalla.horas_acumuladas
from ramo_pantalla
where ramo_pantalla.tipo_ramo = 'Total Tallos'

drop table #ramo
drop table #ramo2
drop table #temp
drop table #temp2
drop table #ramos_devueltos
drop table #persona

update configuracion_bd
set fecha_actualizacion_televisores = getdate()