USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[na_reporte_movimiento_personal_por_supervisor]    Script Date: 26/01/2015 2:39:11 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_reporte_movimiento_personal_por_supervisor]

@fecha_inicial datetime,
@fecha_final datetime

AS

declare @conteo int,
@id int,
@fecha_final_aux datetime,
@id_persona int,
@id_persona_aux int,
@dia_ano int,
@dia_ano_aux int

declare @lectura_sublabores table
(
	id int identity(1,1),
	id_detalle_labor_asignada int,
	codigo_sublabor_asignada nvarchar(10),
	nombre_sublabor_asignada nvarchar(50),
	id_detalle_labor_pistoleada int,
	codigo_sublabor_pistoleada nvarchar(10),
	nombre_sublabor_pistoleada nvarchar(50),
	id_persona int,
	nombre_persona nvarchar(50),
	hora_inicial datetime,
	hora_final datetime
)

declare @resultado_agrupado table
(
  id_labor int,
  idc_labor nvarchar(10),
  nombre_labor nvarchar(50),
  id_detalle_labor int,
  idc_detalle_labor nvarchar(10),
  supervisor nvarchar(50),
  nombre_persona nvarchar(50),
  sublabor_entrega nvarchar(10),
  sublabor_recibe nvarchar(10),
  minutos_base int,
  minutos_entregados int,
  minutos_recibidos int,
  minutos_consumo int
)

declare @minutos_por_transaccion table
(
  codigo_sublabor_asignada nvarchar(10),
  nombre_sublabor_asignada nvarchar(50),
  codigo_sublabor_pistoleada nvarchar(10),
  nombre_sublabor_pistoleada nvarchar(50),
  nombre_persona nvarchar(50),
  hora_inicial datetime,
  hora_final datetime,
  minutos_sublabor int,
  minutos_base int,
  entregado int,
  sublabor_entrega nvarchar(10),
  sublabor_recibe nvarchar(10)
)

declare @resultado table
(
  supervisor nvarchar(10),
  nombre_persona nvarchar(50),
  minutos_base int,
  minutos_entregados int,
  minutos_recibidos int,
  sublabor_entrega nvarchar(10),
  sublabor_recibe nvarchar(10)
)

insert into @lectura_sublabores
(
	id_detalle_labor_asignada,
	codigo_sublabor_asignada,
	nombre_sublabor_asignada,
	id_detalle_labor_pistoleada,
	codigo_sublabor_pistoleada,
	nombre_sublabor_pistoleada,
	id_persona,
	nombre_persona,
	hora_inicial
)
select dl.id_detalle_labor,
dl.idc_detalle_labor,
ltrim(rtrim(dl.nombre_detalle_labor)),
detalle_labor.id_detalle_labor,
detalle_labor.idc_detalle_labor,
ltrim(rtrim(Detalle_Labor.nombre_detalle_labor)),
persona.id_persona,
ltrim(rtrim(persona.apellido)) + ' ' + ltrim(rtrim(persona.nombre)),
detalle_labor_persona.fecha 
from Detalle_Labor_Persona (NOLOCK),
detalle_labor (NOLOCK),
detalle_labor as dl (NOLOCK),
persona (NOLOCK)
where persona.id_persona = detalle_labor_persona.id_persona
and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
and cast(Detalle_Labor_Persona.fecha as date) between
@fecha_inicial and @fecha_final
and dl.id_detalle_labor = persona.id_detalle_labor
order by persona.id_persona,
Detalle_Labor_Persona.fecha

select @id = count(*) from @lectura_sublabores
set @conteo = 1

while(@conteo < = @id)
begin
	set @fecha_final_aux = null
	select @id_persona = id_persona,
	@dia_ano = datepart(dy, hora_inicial)
	from @lectura_sublabores where id = @conteo
	
	select @id_persona_aux = id_persona,
	@dia_ano_aux = datepart(dy, hora_inicial) 
	from @lectura_sublabores where id = @conteo + 1

	select @fecha_final_aux = hora_inicial 
	from @lectura_sublabores 
	where id = @conteo + 1 
	and @id_persona = @id_persona_aux
	and @dia_ano = @dia_ano_aux

	update @lectura_sublabores
	set hora_final = @fecha_final_aux
	where id = @conteo

	set @conteo = @conteo + 1
end

delete from @lectura_sublabores
where codigo_sublabor_pistoleada in ('ALMUER', 'ZZZZZZ')

update @lectura_sublabores
set hora_final = dateadd(mi, 1439, convert(datetime, cast(hora_inicial as date)))
where hora_final is null

insert into @minutos_por_transaccion (codigo_sublabor_asignada, nombre_sublabor_asignada, codigo_sublabor_pistoleada, nombre_sublabor_pistoleada, nombre_persona, hora_inicial, hora_final, minutos_sublabor, minutos_base, entregado, sublabor_entrega, sublabor_recibe)
select codigo_sublabor_asignada,
nombre_sublabor_asignada,
codigo_sublabor_pistoleada,
nombre_sublabor_pistoleada,
nombre_persona,
hora_inicial,
hora_final,
datediff(mi, hora_inicial, hora_final),
datediff(mi, hora_inicial, hora_final),
case
	when id_detalle_labor_asignada = id_detalle_labor_pistoleada then 0
	else datediff(mi, hora_inicial, hora_final)
end,
case
	when id_detalle_labor_asignada = id_detalle_labor_pistoleada then ''
	else  codigo_sublabor_asignada
end,
case
	when id_detalle_labor_asignada = id_detalle_labor_pistoleada then ''
	else  codigo_sublabor_pistoleada
end
from @lectura_sublabores

insert into @resultado (supervisor, nombre_persona, minutos_base, minutos_entregados, minutos_recibidos, sublabor_entrega, sublabor_recibe)
select codigo_sublabor_asignada,
nombre_persona,
sum(minutos_base),
sum(entregado),
0,
case
	when codigo_sublabor_asignada = codigo_sublabor_pistoleada then  ''
	else codigo_sublabor_pistoleada
end,
''
from @minutos_por_transaccion
group by codigo_sublabor_asignada,
nombre_persona,
codigo_sublabor_pistoleada
union all
select codigo_sublabor_pistoleada,
nombre_persona,
0,
0,
sum(entregado),
'',
case
	when codigo_sublabor_asignada = codigo_sublabor_pistoleada then  ''
	else codigo_sublabor_asignada
end
from @minutos_por_transaccion
group by codigo_sublabor_pistoleada,
nombre_persona,
codigo_sublabor_asignada

insert into @resultado_agrupado (id_labor, idc_labor, nombre_labor, id_detalle_labor, idc_detalle_labor, supervisor, nombre_persona, sublabor_entrega, sublabor_recibe, minutos_base, minutos_entregados, minutos_recibidos, minutos_consumo)
select labor.id_labor,
labor.idc_labor,
ltrim(rtrim(labor.nombre_labor)),
detalle_labor.id_detalle_labor,
supervisor,
supervisor + ' - ' + ltrim(rtrim(Detalle_Labor.nombre_detalle_labor)),
nombre_persona,
sublabor_entrega,
sublabor_recibe,
sum(minutos_base),
sum(minutos_entregados),
sum(minutos_recibidos),
sum(minutos_base+minutos_recibidos-minutos_entregados)
from @resultado as r,
detalle_labor (NOLOCK),
labor (NOLOCK)
where detalle_labor.idc_detalle_labor = r.supervisor
and labor.id_labor = Detalle_Labor.id_labor
group by labor.id_labor,
labor.idc_labor,
ltrim(rtrim(labor.nombre_labor)),
detalle_labor.id_detalle_labor,
supervisor,
ltrim(rtrim(Detalle_Labor.nombre_detalle_labor)),
nombre_persona,
sublabor_entrega,
sublabor_recibe
order by supervisor,
nombre_persona

select id_labor,
idc_labor,
nombre_labor,
id_detalle_labor,
supervisor,
nombre_persona,
sum(minutos_base) as minutos,
'' as sublabor,
1 as tipo_sublabor,
'PROPIAS' as nombre_tipo_sublabor 
from @resultado_agrupado as r
where minutos_base > 0
group by id_labor,
idc_labor,
nombre_labor,
id_detalle_labor,
supervisor,
nombre_persona
union all
select r.id_labor,
idc_labor,
nombre_labor,
r.id_detalle_labor,
supervisor,
nombre_persona,
sum(minutos_entregados)*-1,
sublabor_entrega + ' - ' + ltrim(rtrim(detalle_labor.nombre_detalle_labor)),
2,
'ENTREGADAS'
from @resultado_agrupado as r,
detalle_labor (NOLOCK)
where r.sublabor_entrega = detalle_labor.idc_detalle_labor
and sublabor_recibe = ''
and minutos_recibidos = 0
and sublabor_entrega <> ''
group by r.id_labor,
r.idc_labor,
r.nombre_labor,
r.id_detalle_labor,
supervisor,
nombre_persona,
sublabor_entrega,
ltrim(rtrim(detalle_labor.nombre_detalle_labor))
union all
select r.id_labor,
idc_labor,
nombre_labor,
r.id_detalle_labor,
supervisor,
nombre_persona,
sum(minutos_recibidos),
sublabor_recibe + ' - ' + ltrim(rtrim(detalle_labor.nombre_detalle_labor)),
3,
'RECIBIDAS'
from @resultado_agrupado as r,
detalle_labor (NOLOCK)
where r.sublabor_recibe = detalle_labor.idc_detalle_labor
and sublabor_entrega = ''
and minutos_entregados = 0
and sublabor_recibe <> ''
group by r.id_labor,
idc_labor,
nombre_labor,
r.id_detalle_labor,
supervisor,
nombre_persona,
sublabor_recibe,
ltrim(rtrim(detalle_labor.nombre_detalle_labor))