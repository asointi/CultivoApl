set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_concurso_ventas_version2]

@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@idc_grado_flor nvarchar(2),
@idc_color nvarchar(2),
@idc_farm nvarchar(2),
@fecha_inicial datetime,
@fecha_final datetime,
@peso decimal(20,4),
@variedad_flor_incluyente bit,
@grado_flor_incluyente bit,
@farm_incluyente bit,
@color_incluyente bit,
@tipo_flor_incluyente bit,
@accion nvarchar(255),
@id_producto_impulsado int

AS

declare @id_color int,
@id_tipo_flor int,
@id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_producto_impulsado_aux int

if(@accion = 'insertar')
begin
	select @id_color = color.id_color
	from color
	where color.idc_color = @idc_color

	select @id_tipo_flor = tipo_flor.id_tipo_flor
	from tipo_flor
	where tipo_flor.idc_tipo_flor = @idc_tipo_flor

	select @id_variedad_flor = variedad_flor.id_variedad_flor
	from tipo_flor,
	variedad_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor

	select @id_grado_flor = grado_flor.id_grado_flor
	from tipo_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor

	select @id_farm = farm.id_farm
	from farm
	where farm.idc_farm = @idc_farm

	insert into producto_impulsado (id_color, id_tipo_flor, id_variedad_flor, id_grado_flor, id_farm, fecha_inicial, fecha_final, peso, variedad_flor_incluyente, grado_flor_incluyente, farm_incluyente, color_incluyente, tipo_flor_incluyente)
	values (@id_color, @id_tipo_flor, @id_variedad_flor, @id_grado_flor, @id_farm, @fecha_inicial, @fecha_final, @peso, @variedad_flor_incluyente, @grado_flor_incluyente, @farm_incluyente, @color_incluyente, @tipo_flor_incluyente)

	set @id_producto_impulsado_aux = scope_identity()

	select @id_producto_impulsado_aux as id_producto_impulsado
end
else
if(@accion = 'consultar')
begin
	create table #temp
	(
		peso decimal(20,4),
		prioridad int
	)

	Create Index [peso_index] ON [#temp] ([peso] ) 
	Create Index [prioridad_index] ON [#temp] ([prioridad] ) 

	declare @peso_aux decimal(20,4)

	insert into #temp (peso, prioridad)
	/*todos los campos*/
	select producto_impulsado.peso,
	1 as prioridad
	from producto_impulsado,
	variedad_flor,
	grado_flor,
	farm,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
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
	
	/*Incluyente en grado sin variedad*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	2 as prioridad
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
	and producto_impulsado.variedad_flor_incluyente = 0

	/*Incluyente en grado sin finca*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	3 as prioridad
	from producto_impulsado,
	grado_flor,
	variedad_flor,
	tipo_flor
	where producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and producto_impulsado.grado_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 0
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.variedad_flor_incluyente = 1

	/*Incluyente en grado sin variedad y sin finca*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	4 as prioridad
	from producto_impulsado,
	grado_flor,
	tipo_flor
	where producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and producto_impulsado.grado_flor_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.variedad_flor_incluyente = 0
	and producto_impulsado.farm_incluyente = 0

	/*Incluyente en variedad sin grado*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	5 as prioridad
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
	and producto_impulsado.grado_flor_incluyente = 0

	/*Incluyente en variedad sin finca*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	6 as prioridad
	from producto_impulsado,
	variedad_flor,
	grado_flor,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 0
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 1

	/*Incluyente en variedad sin grado y sin finca*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	7 as prioridad
	from producto_impulsado,
	variedad_flor,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 0
	and producto_impulsado.farm_incluyente = 0

	/*Incluyente en finca sin variedad*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	8 as prioridad
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
	and producto_impulsado.variedad_flor_incluyente = 0
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 1

	/*Incluyente en finca sin grado*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	9 as prioridad
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
	and producto_impulsado.grado_flor_incluyente = 0

	/*Incluyente en finca sin variedad y grado*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	9 as prioridad
	from producto_impulsado,
	farm,
	tipo_flor
	where producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.variedad_flor_incluyente = 0
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 0

	/*Incluyente en color sin grado*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	10 as prioridad
	from producto_impulsado,
	variedad_flor,
	color,
	farm,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_color = color.id_color
	and producto_impulsado.id_farm = farm.id_farm
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and color.idc_color = @idc_color
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and variedad_flor.id_color = color.id_color
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 0
	and producto_impulsado.color_incluyente = 1

	/*Incluyente en color sin finca*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	11 as prioridad
	from producto_impulsado,
	variedad_flor,
	color,
	grado_flor,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_color = color.id_color
	and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and color.idc_color = @idc_color
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and variedad_flor.id_color = color.id_color
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 1
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 0
	and producto_impulsado.color_incluyente = 1

	/*Incluyente en color sin finca y sin grado*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	12 as prioridad
	from producto_impulsado,
	variedad_flor,
	color,
	tipo_flor
	where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
	and producto_impulsado.id_color = color.id_color
	and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and color.idc_color = @idc_color
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and variedad_flor.id_color = color.id_color
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and producto_impulsado.variedad_flor_incluyente = 1
	and producto_impulsado.farm_incluyente = 0
	and producto_impulsado.tipo_flor_incluyente = 1
	and producto_impulsado.grado_flor_incluyente = 0
	and producto_impulsado.color_incluyente = 1

	/*Incluyente en tipo*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	13 as prioridad
	from producto_impulsado,
	tipo_flor
	where producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_variedad_flor is null
	and producto_impulsado.id_grado_flor is null
	and producto_impulsado.id_farm is null
	and producto_impulsado.id_color is null
	and producto_impulsado.tipo_flor_incluyente = 1

	/*Incluyente en finca*/
	insert into #temp (peso, prioridad)
	select producto_impulsado.peso,
	14 as prioridad
	from producto_impulsado,
	farm
	where producto_impulsado.id_farm = farm.id_farm
	and farm.idc_farm = @idc_farm
	and @fecha_inicial > = producto_impulsado.fecha_inicial
	and @fecha_inicial < = producto_impulsado.fecha_final
	and producto_impulsado.id_variedad_flor is null
	and producto_impulsado.id_grado_flor is null
	and producto_impulsado.id_tipo_flor is null
	and producto_impulsado.id_color is null
	and producto_impulsado.farm_incluyente = 1

/*Excluyente en grado*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
15 as prioridad
from producto_impulsado,
grado_flor,
farm,
variedad_flor,
tipo_flor
where producto_impulsado.id_grado_flor <> grado_flor.id_grado_flor
and producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_farm = farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.variedad_flor_incluyente = 1

/*Excluyente en grado sin variedad*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
16 as prioridad
from producto_impulsado,
grado_flor,
farm,
tipo_flor
where producto_impulsado.id_grado_flor <> grado_flor.id_grado_flor
and producto_impulsado.id_farm = farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.variedad_flor_incluyente = 0

/*Excluyente en grado sin finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
17 as prioridad
from producto_impulsado,
grado_flor,
variedad_flor,
tipo_flor
where producto_impulsado.id_grado_flor <> grado_flor.id_grado_flor
and producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.variedad_flor_incluyente = 1

/*Excluyente en grado sin variedad y sin finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
18 as prioridad
from producto_impulsado,
grado_flor,
tipo_flor
where producto_impulsado.id_grado_flor <> grado_flor.id_grado_flor
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.variedad_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 0

/*Excluyente en variedad*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
19 as prioridad
from producto_impulsado,
variedad_flor,
grado_flor,
farm,
tipo_flor
where producto_impulsado.id_variedad_flor <> variedad_flor.id_variedad_flor
and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
and producto_impulsado.id_farm = farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 1

/*Excluyente en variedad sin grado*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
20 as prioridad
from producto_impulsado,
variedad_flor,
farm,
tipo_flor
where producto_impulsado.id_variedad_flor <> variedad_flor.id_variedad_flor
and producto_impulsado.id_farm = farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 0

/*Excluyente en variedad sin finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
21 as prioridad
from producto_impulsado,
variedad_flor,
grado_flor,
tipo_flor
where producto_impulsado.id_variedad_flor <> variedad_flor.id_variedad_flor
and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 1

/*Excluyente en variedad sin grado y sin finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
22 as prioridad
from producto_impulsado,
variedad_flor,
tipo_flor
where producto_impulsado.id_variedad_flor <> variedad_flor.id_variedad_flor
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 0

/*Excluyente en finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
23 as prioridad
from producto_impulsado,
grado_flor,
variedad_flor,
farm,
tipo_flor
where producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
and producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_farm <> farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 1
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 1

/*Excluyente en finca sin variedad*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
24 as prioridad
from producto_impulsado,
grado_flor,
farm,
tipo_flor
where producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
and producto_impulsado.id_farm <> farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 0
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 1

/*Excluyente en finca sin grado*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
25 as prioridad
from producto_impulsado,
variedad_flor,
farm,
tipo_flor
where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_farm <> farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 1
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 0

/*Excluyente en color*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
26 as prioridad
from producto_impulsado,
variedad_flor,
grado_flor,
color,
farm,
tipo_flor
where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
and producto_impulsado.id_color <> color.id_color
and producto_impulsado.id_farm = farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and color.idc_color = @idc_color
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and variedad_flor.id_color = color.id_color
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 1
and producto_impulsado.farm_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 1
and producto_impulsado.color_incluyente = 0

/*Excluyente en color sin grado*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
27 as prioridad
from producto_impulsado,
variedad_flor,
color,
farm,
tipo_flor
where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_color <> color.id_color
and producto_impulsado.id_farm = farm.id_farm
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and color.idc_color = @idc_color
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and variedad_flor.id_color = color.id_color
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 1
and producto_impulsado.farm_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.color_incluyente = 0

/*Excluyente en color sin finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
28 as prioridad
from producto_impulsado,
variedad_flor,
color,
grado_flor,
tipo_flor
where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_color <> color.id_color
and producto_impulsado.id_grado_flor = grado_flor.id_grado_flor
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and color.idc_color = @idc_color
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and variedad_flor.id_color = color.id_color
and grado_flor.idc_grado_flor = @idc_grado_flor
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 1
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.color_incluyente = 0

/*Excluyente en color sin finca y sin grado*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
29 as prioridad
from producto_impulsado,
variedad_flor,
color,
tipo_flor
where producto_impulsado.id_variedad_flor = variedad_flor.id_variedad_flor
and producto_impulsado.id_color <> color.id_color
and producto_impulsado.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and color.idc_color = @idc_color
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and variedad_flor.id_color = color.id_color
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and producto_impulsado.variedad_flor_incluyente = 1
and producto_impulsado.farm_incluyente = 0
and producto_impulsado.tipo_flor_incluyente = 1
and producto_impulsado.grado_flor_incluyente = 0
and producto_impulsado.color_incluyente = 0

/*Excluyente en tipo*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
30 as prioridad
from producto_impulsado,
tipo_flor
where producto_impulsado.id_tipo_flor <> tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and producto_impulsado.id_variedad_flor is null
and producto_impulsado.id_grado_flor is null
and producto_impulsado.id_farm is null
and producto_impulsado.id_color is null
and producto_impulsado.tipo_flor_incluyente = 0

/*Excluyente en finca*/
insert into #temp (peso, prioridad)
select producto_impulsado.peso,
31 as prioridad
from producto_impulsado,
farm
where producto_impulsado.id_farm <> farm.id_farm
and farm.idc_farm = @idc_farm
and @fecha_inicial > = producto_impulsado.fecha_inicial
and @fecha_inicial < = producto_impulsado.fecha_final
and producto_impulsado.id_variedad_flor is null
and producto_impulsado.id_grado_flor is null
and producto_impulsado.id_tipo_flor is null
and producto_impulsado.id_color is null
and producto_impulsado.farm_incluyente = 0

	select top 1 @peso_aux = peso
	from #temp
	where peso is not null
	order by prioridad 

	if(@peso_aux is null)
		set @peso_aux = 0

	select @peso_aux as peso
--select * from #temp
	drop table #temp
end
else
if(@accion = 'consultar_detalle')
begin
	select producto_impulsado.* into #detalle
	from producto_impulsado

	alter table #detalle
	add idc_color nvarchar(2),
	idc_tipo_flor nvarchar(2),
	idc_grado_flor nvarchar(2),
	idc_farm nvarchar(2),
	idc_variedad_flor nvarchar(2)

	update #detalle
	set idc_color = color.idc_color
	from color
	where color.id_color = #detalle.id_color

	update #detalle
	set idc_tipo_flor = tipo_flor.idc_tipo_flor
	from tipo_flor
	where tipo_flor.id_tipo_flor = #detalle.id_tipo_flor

	update #detalle
	set idc_variedad_flor = variedad_flor.idc_variedad_flor
	from variedad_flor
	where variedad_flor.id_variedad_flor = #detalle.id_variedad_flor

	update #detalle
	set idc_grado_flor = grado_flor.idc_grado_flor
	from grado_flor
	where grado_flor.id_grado_flor = #detalle.id_grado_flor

	update #detalle
	set idc_farm = farm.idc_farm
	from farm
	where farm.id_farm = #detalle.id_farm

	select id_producto_impulsado,
	isnull(idc_tipo_flor, '') as idc_tipo_flor,
	tipo_flor_incluyente,
	isnull(idc_variedad_flor, '') as idc_variedad_flor,
	variedad_flor_incluyente,
	isnull(idc_grado_flor, '') as idc_grado_flor,
	grado_flor_incluyente,
	isnull(idc_color, '') as idc_color,
	color_incluyente,
	isnull(idc_farm, '') as idc_farm,
	farm_incluyente,
	fecha_inicial,
	fecha_final,
	peso 
	from #detalle

	drop table #detalle
end
else
if(@accion = 'actualizar')
begin
	select @id_color = color.id_color
	from color
	where color.idc_color = @idc_color

	select @id_tipo_flor = tipo_flor.id_tipo_flor
	from tipo_flor
	where tipo_flor.idc_tipo_flor = @idc_tipo_flor

	select @id_variedad_flor = variedad_flor.id_variedad_flor
	from tipo_flor,
	variedad_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor

	select @id_grado_flor = grado_flor.id_grado_flor
	from tipo_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor

	select @id_farm = farm.id_farm
	from farm
	where farm.idc_farm = @idc_farm

	update producto_impulsado
	set id_color = @id_color,
	id_tipo_flor = @id_tipo_flor,
	id_variedad_flor = @id_variedad_flor,
	id_grado_flor = @id_grado_flor,
	id_farm = @id_farm,
	fecha_inicial = @fecha_inicial,
	fecha_final = @fecha_final,
	peso = @peso,
	variedad_flor_incluyente = @variedad_flor_incluyente,
	grado_flor_incluyente = @grado_flor_incluyente, 
	farm_incluyente = @farm_incluyente, 
	color_incluyente = @color_incluyente, 
	tipo_flor_incluyente = @tipo_flor_incluyente
	where id_producto_impulsado = @id_producto_impulsado
end