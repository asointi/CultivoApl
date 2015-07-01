set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[na_editar_concurso_ventas_consultar_peso]

@numero_factura int,
@fecha datetime

AS

declare @conteo int,
@id int,
@idc_tipo_flor nvarchar(4),
@idc_variedad_flor nvarchar(4),
@idc_grado_flor nvarchar(4),
@idc_farm nvarchar(4),
@idc_color nvarchar(4),
@fecha_inicial datetime,
@orden int

create table #temp1
(
	id int identity(1,1),
	fecha datetime,
	idc_tipo_flor nvarchar(4),
	idc_variedad_flor nvarchar(4),
	idc_grado_flor nvarchar(4),
	idc_farm nvarchar(4),
	idc_color nvarchar(4),
	peso decimal(20,4),
	orden int,
	code nvarchar(10) Collate SQL_Latin1_General_CP1_CI_AS
)

insert into #temp1 (fecha,idc_tipo_flor,idc_variedad_flor,idc_grado_flor,idc_farm, idc_color, orden, code)
select Pantalla_Producto_Impulsado.fecha,
Pantalla_Producto_Impulsado.idc_tipo_flor,
Pantalla_Producto_Impulsado.idc_variedad_flor,
Pantalla_Producto_Impulsado.idc_grado_flor,
Pantalla_Producto_Impulsado.idc_farm,
(
	select top 1 color.idc_color
	from color,
	variedad_flor,
	tipo_flor
	where color.id_color = variedad_flor.id_color
	and Pantalla_Producto_Impulsado.idc_variedad_flor = variedad_flor.idc_variedad_flor
	and Pantalla_Producto_Impulsado.idc_tipo_flor = tipo_flor.idc_tipo_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
) AS idc_color,
Pantalla_Producto_Impulsado.orden,
Pantalla_Producto_Impulsado.code
from Pantalla_Producto_Impulsado
where Pantalla_Producto_Impulsado.numero_factura = @numero_factura
and Pantalla_Producto_Impulsado.fecha = @fecha
order by Pantalla_Producto_Impulsado.orden

select @conteo = count(*)
from #temp1

set @id = 1

while (@conteo > 0)
begin
	select @idc_tipo_flor = idc_tipo_flor,
	@idc_variedad_flor = idc_variedad_flor,
	@idc_grado_flor = idc_grado_flor,
	@idc_farm = idc_farm,
	@idc_color = idc_color,
	@fecha_inicial = fecha,
	@orden = orden
	from #temp1
	where id = @id

	create table #temp
	(
		peso decimal(20,4),
		prioridad int
	)

	Create Index [peso_index] ON [#temp] ([peso] ) 
	Create Index [prioridad_index] ON [#temp] ([prioridad] ) 

	declare @peso_aux decimal(20,4)

	/*todos los campos*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	1 as prioridad
	from producto_impulsado,
	variedad_flor,
	grado_flor,
	farm,
	tipo_flor,
	color
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and producto_impulsado.id_color = color.id_color
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and color.idc_color = @idc_color
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and color.id_color = variedad_flor.id_color
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.color_incluyente = 1

	/*Variedad Nula*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	2 as prioridad
	from producto_impulsado,
	farm,
	tipo_flor,
	grado_flor,
	color
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_color = color.id_color
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and farm.idc_farm = @idc_farm
	and color.idc_color = @idc_color
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_variedad_flor is null
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.color_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 1

	/*Color Nulo*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	3 as prioridad
	from producto_impulsado,
	farm,
	tipo_flor,
	grado_flor,
	variedad_flor
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_color is null
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 1


	/*Incluyente en grado sin variedad y sin color*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	4 as prioridad
	from producto_impulsado,
	grado_flor,
	farm,
	tipo_flor
	where producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and producto_impulsado.grado_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.id_color is null
	and producto_impulsado.id_variedad_flor is null

	/*Excluyente en Color sin variedad*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	5 as prioridad
	from producto_impulsado,
	grado_flor,
	farm,
	tipo_flor,
	color
	where producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and producto_impulsado.id_color <> color.id_color
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and farm.idc_farm = @idc_farm
	and color.idc_color =  @idc_color
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and producto_impulsado.grado_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.color_incluyente = 0
	and producto_impulsado.id_variedad_flor is null

	/*Incluyente en variedad sin grado y sin color*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	6 as prioridad
	from producto_impulsado,
	variedad_flor,
	farm,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.id_color is null
	and producto_impulsado.id_grado_flor is null

	/*Incluyente en variedad sin grado y sin color*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	7 as prioridad
	from producto_impulsado,
	farm,
	tipo_flor
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_variedad_flor is null
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.id_color is null
	and producto_impulsado.id_grado_flor is null

	/*Incluyente en variedad sin grado y sin color*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	8 as prioridad
	from producto_impulsado,
	farm,
	tipo_flor,
	color
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_color = color.id_color
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and farm.idc_farm = @idc_farm
	and color.idc_color = @idc_color
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_variedad_flor is null
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.color_incluyente = 1
	and producto_impulsado.id_grado_flor is null

	/*Excluyente en Color sin variedad*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	9 as prioridad
	from producto_impulsado,
	farm,
	tipo_flor,
	color
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and producto_impulsado.id_color <> color.id_color
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and farm.idc_farm = @idc_farm
	and color.idc_color =  @idc_color
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_grado_flor is null
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.color_incluyente = 0
	and producto_impulsado.id_variedad_flor is null

	/*Excluyente en Color sin variedad*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	10 as prioridad
	from producto_impulsado,
	farm,
	color
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_color <> color.id_color
	and farm.idc_farm = @idc_farm
	and color.idc_color =  @idc_color
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_grado_flor is null
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.id_tipo_flor is null
	and producto_impulsado.color_incluyente = 0
	and producto_impulsado.id_variedad_flor is null

	select top 1 @peso_aux = peso
	from #temp
	where peso is not null
	order by prioridad 

	if(@peso_aux is null)
		set @peso_aux = 0

	update #temp1
	set peso = @peso_aux
	where id = @id

	drop table #temp

	set @conteo = @conteo - 1
	set @id = @id + 1
	set @peso_aux = null
end

update #temp1
set peso = 1
from #temp1,
vendedor
where 
(
	#temp1.peso = 0
	or #temp1.peso is null
)
and
(
	#temp1.code like '3%'
	or #temp1.code like '4%'
	or #temp1.code like '5%'
	or #temp1.code like '6%'
	or #temp1.code like '7%'
)
and isnumeric(#temp1.code) = 1
and 
(
	len(rtrim(ltrim(#temp1.code))) = 3
	or len(rtrim(ltrim(#temp1.code))) = 4
)
and right(#temp1.code, len(rtrim(ltrim(#temp1.code))) -1) = vendedor.idc_vendedor
AND #TEMP1.FECHA > = CONVERT(DATETIME, '2010-15-11')
AND #TEMP1.FECHA < = CONVERT(DATETIME, '2011-20-02')


select orden,
peso 
from #temp1
order by orden

drop table #temp1

delete from Pantalla_Producto_Impulsado
where numero_factura = @numero_factura
and fecha = @fecha
