set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/05/15
-- Description:	Reportes y graficos para realizar el seguimiento a Weblabels
-- =============================================

alter PROCEDURE [dbo].[wbl_seguimiento_weblabel] 

@accion nvarchar(100)

as

declare @fecha_inicial datetime,
@fecha_final datetime,
@conteo int,
@dias int,
@cantidad_semanas_atras int,
@tipo_receiving_cvt nvarchar(20),
@tipo_receiving_weblabel nvarchar(20),
@tipo_receiving_weblabel_no_recibido nvarchar(20),
@tipo_receiving_weblabel_omitido nvarchar(20),
@tipo_receiving_regular nvarchar(20),
@nombre_base_datos nvarchar(50),
@fresca nvarchar(50),
@natural nvarchar(50)

set @nombre_base_datos = DB_NAME()
set @fresca = 'BD_Fresca'
set @natural = 'BD_NF'

set @tipo_receiving_cvt = 'CVT'
set @tipo_receiving_weblabel = 'WEBLABEL'
set @tipo_receiving_weblabel_no_recibido = 'WEBLABEL NO RECIBIDO'
set @tipo_receiving_weblabel_omitido = 'WEBLABEL OMITIDO'
set @tipo_receiving_regular = 'REGULAR'

set @fecha_inicial = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),0) 
set @fecha_final = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6) 

create table #fecha
(
	id int identity(1,1),
	fecha_inicial datetime,
	fecha_final datetime
)

set @conteo = 0
set @dias = 0
set @cantidad_semanas_atras = 10

while (@conteo < @cantidad_semanas_atras)
begin
	insert into #fecha (fecha_inicial, fecha_final)
	select dateadd(dd, @dias, @fecha_inicial), dateadd(dd, @dias, @fecha_final)

	set @conteo = @conteo + 1
	set @dias = @dias -7
end

select 
case
	when @nombre_base_datos = @natural then
	case
		when left(idc_pieza , 2) = '9F' or left(idc_pieza , 2) = '9G' then @tipo_receiving_cvt
		when left(idc_pieza , 2) = 'C2' then @tipo_receiving_weblabel
		when left(idc_pieza , 2) = 'C1' then @tipo_receiving_weblabel_no_recibido
		else
		case
			when farm.tiene_weblabel = 1 then @tipo_receiving_weblabel_omitido
			when farm.tiene_weblabel = 0 then @tipo_receiving_regular
		END
	END
	when @nombre_base_datos = @fresca then
	case
		when left(idc_pieza , 2) = '01' or left(idc_pieza , 2) = '02' or left(idc_pieza , 2) = 'B3' then @tipo_receiving_cvt
		when left(idc_pieza , 2) = 'AI' then @tipo_receiving_weblabel
		when left(idc_pieza , 2) = 'AJ' then @tipo_receiving_weblabel_no_recibido
		else
		case
			when farm.tiene_weblabel = 1 then @tipo_receiving_weblabel_omitido
			when farm.tiene_weblabel = 0 then @tipo_receiving_regular
		END
	END
end as tipo_receiving,
pieza.idc_pieza,
#fecha.fecha_inicial,
#fecha.fecha_final,
#fecha.id,
pieza.id_pieza,
farm.idc_farm,
farm.nombre_farm,
farm.tiene_weblabel,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
caja.nombre_caja,
pieza.unidades_por_pieza,
pieza.marca into #temp
from pieza,
guia,
#fecha,
farm,
tipo_flor,
variedad_flor,
grado_flor,
caja,
tipo_caja
where guia.id_guia = pieza.id_guia
and guia.fecha_guia between
#fecha.fecha_inicial and #fecha.fecha_final
and farm.id_farm = pieza.id_farm
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = pieza.id_caja

if(@accion = 'Grafico_tipo_receiving_por_semana')
begin
	/*Grafico 1. Agrupamiento tipos de receiving x semana*/
	select 
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 'Se debe Pegar Etiqueta'
		when tipo_receiving = @tipo_receiving_cvt then @tipo_receiving_cvt
		when tipo_receiving = @tipo_receiving_weblabel then @tipo_receiving_weblabel
	end as agrupamiento_tipo_receiving,
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 1
		when tipo_receiving = @tipo_receiving_weblabel then 2	
		when tipo_receiving = @tipo_receiving_cvt then 3
	end as orden,
	fecha_inicial,
	fecha_final,
	id,
	count(*) as cantidad
	from #temp
	group by 
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 'Se debe Pegar Etiqueta'
		when tipo_receiving = @tipo_receiving_cvt then @tipo_receiving_cvt
		when tipo_receiving = @tipo_receiving_weblabel then @tipo_receiving_weblabel
	end,
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 1
		when tipo_receiving = @tipo_receiving_weblabel then 2	
		when tipo_receiving = @tipo_receiving_cvt then 3
	end,
	fecha_inicial,
	fecha_final,
	id
	order by id desc,
	agrupamiento_tipo_receiving
end
else
if(@accion = 'Grafico_detalle_tipo_receiving_por_semana')
begin
	/*Grafico 2. Detalle tipos de receiving x semana*/
	select tipo_receiving,
	case
		when tipo_receiving = @tipo_receiving_weblabel_omitido then 1
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido then 2
		when tipo_receiving = @tipo_receiving_regular then 3
	end as orden,
	fecha_inicial,
	fecha_final,
	id,
	count(id_pieza) as cantidad 
	from #temp
	where (
		tipo_receiving = @tipo_receiving_weblabel_no_recibido
		or tipo_receiving = @tipo_receiving_weblabel_omitido
		or tipo_receiving = @tipo_receiving_regular
	)
	group by tipo_receiving,
	fecha_inicial,
	fecha_final,
	id
	order by id desc,
	tipo_receiving
end
else
if(@accion = 'Grafico_etiquetas_para_pegar_por_finca')
begin
	/*Grafico 3. Cantidad de etiquetas para pegar x finca*/
	select ROW_NUMBER() OVER(ORDER BY count(id_pieza) desc) as id,
	tipo_receiving,
	case
		when tipo_receiving = @tipo_receiving_weblabel_omitido then 1
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido then 2
		when tipo_receiving = @tipo_receiving_regular then 3
	end as orden,
	idc_farm,
	nombre_farm,
	fecha_inicial,
	fecha_final,
	count(id_pieza) as cantidad
	from #temp
	where (tipo_receiving = @tipo_receiving_weblabel_no_recibido
	or tipo_receiving = @tipo_receiving_weblabel_omitido
	or tipo_receiving = @tipo_receiving_regular)
	and id = 1
	group by tipo_receiving,
	idc_farm,
	nombre_farm,
	fecha_inicial,
	fecha_final
	order by cantidad desc 
end
else
if(@accion = 'reporte_seguimiento_etiquetas_con_problemas')
begin
	/*Reporte para que las personas de Receiving pongan el por qué de los labels con problemas*/
	select tipo_receiving,
	id,
	fecha_inicial,
	fecha_final,
	idc_farm,
	nombre_farm,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_caja,
	nombre_caja,
	unidades_por_pieza,
	count(id_pieza) as cantidad 
	from #temp
	where (tipo_receiving = @tipo_receiving_weblabel_no_recibido
	or tipo_receiving = @tipo_receiving_weblabel_omitido)
	group by tipo_receiving,
	id,
	fecha_inicial,
	fecha_final,
	idc_farm,
	nombre_farm,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_caja,
	nombre_caja,
	unidades_por_pieza 
	order by tipo_receiving,
	id desc,
	fecha_inicial,
	fecha_final,
	idc_farm,
	nombre_farm,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_caja,
	nombre_caja,
	unidades_por_pieza,
	cantidad 
end
else
if(@accion = 'grafico_seguimiento_fincas_con_problemas')
begin
	declare @cantidad_meses int

	set @fecha_final = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6) 

	select @cantidad_meses = 36 + datepart(mm, @fecha_final)

	set @conteo = 0

	delete from #fecha

	while (@conteo < @cantidad_meses)
	begin 
		insert into #fecha (fecha_inicial, fecha_final)
		SELECT dateadd(mm, -@conteo, convert(datetime,CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@fecha_final)-1),@fecha_final),101))),
		dateadd(mm, -@conteo, convert(datetime, convert(nvarchar, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@fecha_final)+1,0)), 101)))

		set @conteo = @conteo + 1
	end

	select 
	case
		when @nombre_base_datos = @natural then
		case
			when left(idc_pieza , 2) = '9F' or left(idc_pieza , 2) = '9G' then @tipo_receiving_cvt
			when left(idc_pieza , 2) = 'C2' then @tipo_receiving_weblabel
			when left(idc_pieza , 2) = 'C1' then @tipo_receiving_weblabel_no_recibido
			else
			case
				when farm.tiene_weblabel = 1 then @tipo_receiving_weblabel_omitido
				when farm.tiene_weblabel = 0 then @tipo_receiving_regular
			END
		END
		when @nombre_base_datos = @fresca then
		case
			when left(idc_pieza , 2) = '01' or left(idc_pieza , 2) = '02' or left(idc_pieza , 2) = 'B3' then @tipo_receiving_cvt
			when left(idc_pieza , 2) = 'AI' then @tipo_receiving_weblabel
			when left(idc_pieza , 2) = 'AJ' then @tipo_receiving_weblabel_no_recibido
			else
			case
				when farm.tiene_weblabel = 1 then @tipo_receiving_weblabel_omitido
				when farm.tiene_weblabel = 0 then @tipo_receiving_regular
			END
		END
	end as tipo_receiving,
	pieza.idc_pieza,
	#fecha.fecha_inicial,
	#fecha.fecha_final,
	#fecha.id,
	pieza.id_pieza,
	farm.idc_farm,
	farm.nombre_farm,
	farm.tiene_weblabel,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	caja.nombre_caja,
	pieza.unidades_por_pieza,
	pieza.marca into #resultado
	from pieza,
	guia,
	#fecha,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	caja,
	tipo_caja
	where guia.id_guia = pieza.id_guia
	and guia.fecha_guia between
	#fecha.fecha_inicial and #fecha.fecha_final
	and farm.id_farm = pieza.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and grado_flor.id_grado_flor = pieza.id_grado_flor
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = pieza.id_caja
	and farm.idc_farm in
	(
		select idc_farm
		from #temp
		where (tipo_receiving = @tipo_receiving_weblabel_no_recibido
		or tipo_receiving = @tipo_receiving_weblabel_omitido)
		and id = 1
		group by idc_farm
	)

	/*Grafico 4. Fincas con problemas de labels*/
	select 
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 'Se debe Pegar Etiqueta'
		when tipo_receiving = @tipo_receiving_cvt then @tipo_receiving_cvt
		when tipo_receiving = @tipo_receiving_weblabel then @tipo_receiving_weblabel
	end as agrupamiento_tipo_receiving,
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 1
		when tipo_receiving = @tipo_receiving_weblabel then 2	
		when tipo_receiving = @tipo_receiving_cvt then 3
	end as orden,
	fecha_inicial,
	fecha_final,
	left(convert(nvarchar, fecha_inicial, 7), 3) + space(1) + convert(nvarchar,datepart(yyyy, fecha_inicial)) as fecha_formateada,
	id,
	idc_farm,
	nombre_farm,
	count(*) as cantidad
	from #resultado
	group by 
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 'Se debe Pegar Etiqueta'
		when tipo_receiving = @tipo_receiving_cvt then @tipo_receiving_cvt
		when tipo_receiving = @tipo_receiving_weblabel then @tipo_receiving_weblabel
	end,
	case
		when tipo_receiving = @tipo_receiving_weblabel_no_recibido or tipo_receiving = @tipo_receiving_weblabel_omitido or tipo_receiving = @tipo_receiving_regular then 1
		when tipo_receiving = @tipo_receiving_weblabel then 2	
		when tipo_receiving = @tipo_receiving_cvt then 3
	end,
	fecha_inicial,
	fecha_final,
	id,
	idc_farm,
	nombre_farm
	order by idc_farm,
	nombre_farm,
	id desc,
	agrupamiento_tipo_receiving


	drop table #resultado
end

DROP TABLE #FECHA
drop table #temp