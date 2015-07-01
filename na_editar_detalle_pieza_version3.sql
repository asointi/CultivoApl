set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_detalle_pieza_version3]

@accion nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_pieza nvarchar(255),
@comentario nvarchar(1024),
@cantidad_tallos int

AS

declare @conteo int

select @conteo = count(*)
from tipo_flor,
variedad_flor,
grado_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor

if(@accion = 'insertar')
begin
	if(@conteo = 0)
	begin
		select @conteo = count(*)
		from pieza,
		detalle_pieza_comentario
		where pieza.idc_pieza = @idc_pieza
		and pieza.id_pieza = detalle_pieza_comentario.id_pieza
		and detalle_pieza_comentario.cantidad_tallos = @cantidad_tallos
		and ltrim(rtrim(detalle_pieza_comentario.comentario)) = ltrim(rtrim(@comentario))

		if(@conteo = 0)
		begin
			insert into detalle_pieza_comentario (id_pieza, cantidad_tallos, comentario)
			select pieza.id_pieza, @cantidad_tallos, @comentario
			from pieza
			where pieza.idc_pieza = @idc_pieza

			select 1 as result
		end
		else
		begin
			select -1 as result
		end
	end
	else
	begin
		select @conteo = count(*)
		from variedad_flor,
		grado_flor,
		tipo_flor,
		pieza,
		detalle_pieza
		where tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and pieza.idc_pieza = @idc_pieza
		and pieza.id_pieza = detalle_pieza.id_pieza
		and detalle_pieza.id_variedad_flor = variedad_flor.id_variedad_flor
		and detalle_pieza.id_grado_flor = grado_flor.id_grado_flor
		and detalle_pieza.cantidad_tallos = @cantidad_tallos

		if(@conteo = 0)
		begin
			insert into detalle_pieza (id_pieza, id_variedad_flor, id_grado_flor, cantidad_tallos)
			select pieza.id_pieza, variedad_flor.id_variedad_flor, grado_flor.id_grado_flor, @cantidad_tallos
			from variedad_flor,
			grado_flor,
			tipo_flor,
			pieza
			where tipo_flor.idc_tipo_flor = @idc_tipo_flor
			and variedad_flor.idc_variedad_flor = @idc_variedad_flor
			and grado_flor.idc_grado_flor = @idc_grado_flor
			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
			and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
			and pieza.idc_pieza = @idc_pieza

			select 1 as result
		end
		else
		begin
			select -1 as result
		end
	end
end
else
if(@accion = 'consultar')
begin
	create table #temp 
	(
		idc_tipo_flor nvarchar(2),
		nombre_tipo_flor nvarchar(255),
		idc_variedad_flor nvarchar(2),
		nombre_variedad_flor nvarchar(255),
		idc_grado_flor nvarchar(2),
		nombre_grado_flor nvarchar(255),
		cantidad_tallos int,
		comentario nvarchar(1024),
		idc_ramo nvarchar(255)
	)

	insert into #temp 
	(
		idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		cantidad_tallos,
		comentario,
		idc_ramo
	)
	select tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	sum(detalle_pieza.cantidad_tallos) as cantidad_tallos,
	null as comentario,
	null as idc_ramo
	from detalle_pieza,
	pieza,
	variedad_flor,
	tipo_flor,
	grado_flor
	where pieza.idc_pieza = @idc_pieza
	and pieza.id_pieza = detalle_pieza.id_pieza
	and detalle_pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and detalle_pieza.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	group by tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor

	insert into #temp 
	(
		idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		cantidad_tallos,
		comentario,
		idc_ramo
	)
	select 
	'' as idc_tipo_flor,
	'' as nombre_tipo_flor,
	'' as idc_variedad_flor,
	'' as nombre_variedad_flor,
	'' as idc_grado_flor,
	'' as nombre_grado_flor,
	sum(detalle_pieza_comentario.cantidad_tallos) as cantidad_tallos,
	detalle_pieza_comentario.comentario,
	'' as idc_ramo
	from detalle_pieza_comentario,
	pieza
	where pieza.idc_pieza = @idc_pieza
	and pieza.id_pieza = detalle_pieza_comentario.id_pieza
	group by detalle_pieza_comentario.comentario
	order by detalle_pieza_comentario.comentario

	insert into #temp 
	(
		idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		cantidad_tallos,
		comentario,
		idc_ramo
	)
	select tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	sum(ramo.tallos_por_ramo) as cantidad_tallos,
	null as comentario,
	ramo.idc_ramo
	from ramo,
	pieza,
	variedad_flor,
	tipo_flor,
	grado_flor
	where pieza.idc_pieza = @idc_pieza
	and pieza.id_pieza = ramo.id_pieza
	and ramo.id_variedad_flor = variedad_flor.id_variedad_flor
	and ramo.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	group by tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ramo.idc_ramo

	select idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	sum(cantidad_tallos) as cantidad_tallos,
	comentario,
	idc_ramo
	from #temp
	group by idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	comentario,
	idc_ramo
	order by nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor
	
	drop table #temp
end