set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/06/12
-- Description:	Se utiliza para conocer las flores ingresadas a traves de la interfaz
-- =============================================

alter PROCEDURE [dbo].[prod_miami_reporte_ventas_ultimo_ano_por_grado_visualiza_parametros] 

@id_tipo_flor int,
@id_variedad_flor int,
@id_grado_flor nvarchar(512),
@accion nvarchar(50),
@fecha datetime = null

as

if(@accion = 'consultar_rango_fechas')
begin
	declare @fecha_inicial datetime,
	@fecha_final datetime

	set language spanish
	set @fecha_inicial = dateadd(wk, -52, dateadd(dd, -7, DATEADD(DAY, 1- DATEPART(DW, @fecha), @fecha)))
	set @fecha_final = dateadd(dd, -7, DATEADD(DAY, 7- DATEPART(DW, @fecha), @fecha))

	select @fecha_inicial as fecha_inicial, @fecha_final as fecha_final
end
else
if(@accion = 'consultar_parametros_reporte')
begin
	create table #grados (id int)

	declare @sql varchar(8000)

	/*crear la insercion para los valores separados por comas*/
	select @sql = 'insert into #grados select '+	replace(@id_grado_flor,',',' union all select ')

	/*cargar todos los valores de la variable @id_grado_flor en la tabla temporal*/
	exec (@SQL)

	create table #temp
	(
		id Int Identity(1,1),
		dato nvarchar(255)
	)

	insert into #temp (dato)
	values ('Flower Type: ')

	insert into #temp (dato)
	values ('Flower Variety: ')

	insert into #temp (dato)
	values ('Flower Grades: ')

	update #temp
	set dato = dato + ltrim(rtrim(nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']'
	from tipo_flor
	where tipo_flor.id_tipo_flor = @id_tipo_flor
	and #temp.id = 1

	if(@id_variedad_flor = 0)
	begin
		update #temp
		set dato = dato + 'All'
		where #temp.id = 2
	end
	else
	begin
		update #temp
		set dato = dato + ltrim(rtrim(nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']'
		from variedad_flor
		where variedad_flor.id_variedad_flor = @id_variedad_flor
		and #temp.id = 2
	end

	insert into #temp (dato)
	select ltrim(rtrim(nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']'
	from grado_flor
	where exists
	(
		select * 
		from #grados
		where #grados.id = grado_flor.id_grado_flor
	)
	order by grado_flor.orden desc

	select dato 
	from #temp
	order by id

	drop table #grados
	drop table #temp
end
else
if(@accion = 'consultar_tipo_flor')
begin
	select id_tipo_flor,
	ltrim(rtrim(nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor
	from tipo_flor
	where disponible = 1
	order by ltrim(rtrim(nombre_tipo_flor))
end
else
if(@accion = 'consultar_variedad_flor')
begin
	select id_tipo_flor,
	id_variedad_flor,
	ltrim(rtrim(nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
	from variedad_flor
	where disponible = 1
	order by ltrim(rtrim(nombre_variedad_flor))
end
else
if(@accion = 'consultar_grado_flor')
begin
	select id_tipo_flor,
	id_grado_flor,
	ltrim(rtrim(nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor
	from grado_flor
	where disponible = 1
	order by orden desc
end