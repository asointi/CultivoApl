set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2007/08/14
-- Description:	limpiar tablero al insertar dato de inventario desde Cobol
-- =============================================
ALTER PROCEDURE [dbo].[inv_limpiar_tablero] 

as

declare @tallos_postcosecha int, 
@tallos_por_ramo int, 
@tallos_por_ramo_ultima_hora int,
@tallos_por_hora decimal(20,4), 
@porcion_hora nvarchar(255), 
@minutos_porcion_hora decimal(20,0),
@horas_en_minutos nvarchar(255), 
@horas_estimada nvarchar(255), 
@fecha_inventario datetime, 
@inventario int, 
@tallos_freedom int, 
@tallos_charlotte int,
@tallos_bonchados_freedom_total int, 
@tallos_bonchados_freedom_40 int, 
@porcentaje_freedom_40 decimal(4,2),
@tallos_forever int,
@idc_tipo_flor_rosa nvarchar(255),
@idc_tipo_flor_rosa_spray nvarchar(255),
@idc_variedad_flor_freedom nvarchar(255),
@idc_variedad_flor_freedom_rusia nvarchar(255),
@idc_variedad_flor_charlotte nvarchar(255),
@idc_variedad_flor_forever_young nvarchar(255),
@idc_grado_flor_40 nvarchar(255),
@tallos_bonchados_light_pink_total int,
@tallos_bonchados_light_pink_40 int,
@porcentaje_light_pink_40 decimal(4,1),
@tallos_bonchados_hot_pink_total int,
@tallos_bonchados_hot_pink_40 int,
@porcentaje_hot_pink_40 decimal(4,1),
@tallos_bonchados_yellow_total int,
@tallos_bonchados_yellow_40 int,
@porcentaje_yellow_40 decimal(4,1)

set @idc_tipo_flor_rosa = 'RO'
set @idc_tipo_flor_rosa_spray = 'rs'
set @idc_variedad_flor_freedom = 'FR'
set @idc_variedad_flor_freedom_rusia = 'UJ'
set @idc_variedad_flor_charlotte = '5N'
set @idc_variedad_flor_forever_young = 'FY'
set @idc_grado_flor_40 = '40'

/**Total tallos postcosecha durante el dia**/
select @tallos_postcosecha = isnull(sum(pieza_postcosecha.unidades_por_pieza), 0) 
from pieza_postcosecha
where convert(nvarchar, fecha_entrada, 101) = convert(nvarchar, getdate(), 101)

/**Total tallos postcosecha freedom durante el dia**/
select @tallos_freedom = isnull(sum(pieza_postcosecha.unidades_por_pieza), 0) 
from pieza_postcosecha, variedad_flor, tipo_flor
where convert(nvarchar, fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.idc_variedad_flor = @idc_variedad_flor_freedom

/**Total tallos postcosecha Charlotte durante el dia**/
select @tallos_charlotte = isnull(sum(pieza_postcosecha.unidades_por_pieza), 0) 
from pieza_postcosecha, variedad_flor, tipo_flor
where convert(nvarchar, fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.idc_variedad_flor = @idc_variedad_flor_charlotte

/**Total tallos postcosecha forever young durante el dia**/
select @tallos_forever = isnull(sum(pieza_postcosecha.unidades_por_pieza), 0) 
from pieza_postcosecha, variedad_flor, tipo_flor
where convert(nvarchar, fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.idc_variedad_flor = @idc_variedad_flor_forever_young

/**PORCENTAJE DE CLASIFICACION DE FREEDOM 40 CMS**/
select @tallos_bonchados_freedom_total = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, tipo_flor
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and (idc_variedad_flor = @idc_variedad_flor_freedom or idc_variedad_flor = @idc_variedad_flor_freedom_rusia)

select @tallos_bonchados_freedom_40 = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, grado_flor,tipo_flor
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and Ramo.id_grado_flor=grado_flor.id_grado_flor
and (idc_variedad_flor = @idc_variedad_flor_freedom or idc_variedad_flor = @idc_variedad_flor_freedom_rusia)
and grado_flor.idc_grado_flor = @idc_grado_flor_40
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and Grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor

if @tallos_bonchados_freedom_total = 0
	begin
		set @porcentaje_freedom_40 = 0
	end
else
	set @porcentaje_freedom_40 = (convert(decimal,@tallos_bonchados_freedom_40)/convert(decimal,@tallos_bonchados_freedom_total))*100

/**PORCENTAJE DE CLASIFICACION LIGHT PINK 40 CMS**/
select @tallos_bonchados_light_pink_total = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, tipo_flor, color
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_color = color.id_color
and color.id_color = 1

select @tallos_bonchados_light_pink_40 = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, grado_flor, tipo_flor, color
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and Ramo.id_grado_flor=grado_flor.id_grado_flor
and variedad_flor.id_color = color.id_color
and color.id_color = 1
and grado_flor.idc_grado_flor = @idc_grado_flor_40
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and Grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor

if @tallos_bonchados_light_pink_total = 0
	begin
		set @porcentaje_light_pink_40 = 0
	end
else
	set @porcentaje_light_pink_40 = (convert(decimal,@tallos_bonchados_light_pink_40)/convert(decimal,@tallos_bonchados_light_pink_total))*100

/**PORCENTAJE DE CLASIFICACION HOT PINK 40 CMS**/
select @tallos_bonchados_hot_pink_total = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, tipo_flor, color
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_color = color.id_color
and color.id_color = 2

select @tallos_bonchados_hot_pink_40 = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, grado_flor, tipo_flor, color
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and Ramo.id_grado_flor=grado_flor.id_grado_flor
and variedad_flor.id_color = color.id_color
and color.id_color = 2
and grado_flor.idc_grado_flor = @idc_grado_flor_40
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and Grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor

if @tallos_bonchados_hot_pink_total = 0
	begin
		set @porcentaje_hot_pink_40 = 0
	end
else
	set @porcentaje_hot_pink_40 = (convert(decimal,@tallos_bonchados_hot_pink_40)/convert(decimal,@tallos_bonchados_hot_pink_total))*100


/**PORCENTAJE DE CLASIFICACION YELLOW 40 CMS**/
select @tallos_bonchados_yellow_total = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, tipo_flor, color
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_color = color.id_color
and color.id_color = 3

select @tallos_bonchados_yellow_40 = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor, grado_flor, tipo_flor, color
where convert(nvarchar, Ramo.fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and Ramo.id_grado_flor=grado_flor.id_grado_flor
and variedad_flor.id_color = color.id_color
and color.id_color = 3
and grado_flor.idc_grado_flor = @idc_grado_flor_40
and tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and Grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor

if @tallos_bonchados_yellow_total = 0
	begin
		set @porcentaje_yellow_40 = 0
	end
else
	set @porcentaje_yellow_40 = (convert(decimal,@tallos_bonchados_yellow_40)/convert(decimal,@tallos_bonchados_yellow_total))*100

---------------------------
select @fecha_inventario = fecha_inventario from Tablero
IF (convert(nvarchar, @fecha_inventario, 101) = convert(nvarchar, getdate(), 101))
BEGIN
	select @inventario = isnull(inventario_cobol, 0) from Tablero
END
ELSE
BEGIN
	set @inventario = 0
END	
/**Total tallos por ramo durante el dia**/
select @tallos_por_ramo = isnull(sum(Ramo.tallos_por_ramo), 0) 
from Ramo, variedad_flor,tipo_flor
where convert(nvarchar, fecha_entrada, 101) = convert(nvarchar, getdate(), 101)
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and (tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
or tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa_spray) 

/**Total tallos por ramo ultima hora durante el dia**/
select @tallos_por_ramo_ultima_hora = isnull(sum(Ramo.tallos_por_ramo), 0)
from 
Ramo, variedad_flor,tipo_flor
where 
Ramo.fecha_entrada > =
dateadd(hh, -1, getdate())
and Ramo.id_variedad_flor=variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and (tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa
or tipo_flor.idc_tipo_flor = @idc_tipo_flor_rosa_spray) 

/**hora estimada clasificacion**/
if @tallos_por_ramo = 0
	begin
	set @horas_estimada = '24:00'
	end
else
	begin
		if @tallos_por_ramo_ultima_hora = 0
			begin
			set @horas_estimada = '24:00'
			end	
		else
		begin
			set @tallos_por_hora = ((convert(decimal, @tallos_postcosecha) + convert(decimal, @inventario))-convert(decimal, @tallos_por_ramo))/convert(decimal, @tallos_por_ramo_ultima_hora)
			if left(convert(nvarchar, @tallos_por_hora), 1) = '-'
				Begin
				set @tallos_por_hora = 0
				set @porcion_hora = 0
				set @minutos_porcion_hora=0
				set @horas_en_minutos = 0
				End
			Else
				Begin
				set @porcion_hora = substring(convert(nvarchar, @tallos_por_hora),CHARINDEX('.', convert(nvarchar, @tallos_por_hora))+1 ,2)
				set @minutos_porcion_hora=@porcion_hora*(convert(decimal, 60)/convert(decimal, 100))
				set @horas_en_minutos = ((left(convert(nvarchar, @tallos_por_hora),CHARINDEX('.', convert(nvarchar, @tallos_por_hora))-1))*60)+@minutos_porcion_hora
				end
		if convert(nvarchar, dateadd(mi, convert(int, @horas_en_minutos), getdate()), 101) <> convert(nvarchar, getdate(), 101)
			begin
			set @horas_estimada = '24:00'
			end
		else 
			begin
			select @horas_estimada = ltrim(rtrim(substring(convert(nvarchar, dateadd(mi, convert(int, @horas_en_minutos), getdate()), 109), 12, 6) 
			+
			right(convert(nvarchar, dateadd(mi, convert(int, @horas_en_minutos), getdate()), 109), 2)))
			end
		end
	end

/**Actualizacion tabla Tableros**/
IF (convert(nvarchar, @fecha_inventario, 101) <> convert(nvarchar, getdate(), 101))
begin
	update Tablero
	set tallos_postcosecha = left(convert(nvarchar, (convert(money, @tallos_postcosecha)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_postcosecha)), 1))-1),
	tallos_freedom = left(convert(nvarchar, (convert(money, @tallos_freedom)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_freedom)), 1))-1),
	tallos_charlotte = left(convert(nvarchar, (convert(money, @tallos_charlotte)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_charlotte)), 1))-1),
	tallos_por_ramo = left(convert(nvarchar, (convert(money, @tallos_por_ramo)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo)), 1))-1),
	tallos_por_ramo_ultima_hora = left(convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1))-1),
	hora_salida_estimada = 'Sin actualizar',
	fecha_actualizacion = getdate(),
	tallos_inventario = 'Sin actualizar',
	freedom_40= convert(nvarchar, @porcentaje_freedom_40)+'%',
	light_pink_40='Light Pink 40:' + space(1) + convert(nvarchar, @porcentaje_light_pink_40)+'%',
	hot_pink_40='Hot Pink 40:' + space(1) + convert(nvarchar, @porcentaje_hot_pink_40)+'%',
	yellow_40='Yellow 40:' + space(1) + convert(nvarchar, @porcentaje_yellow_40)+'%',
	tallos_forever = 'Forever:'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_forever)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_forever)), 1))-1)

	insert into [dbo].[Log_info] (mensaje, tipo_mensaje)
	values ('Entrada'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_postcosecha)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_postcosecha)), 1))-1)+ space(1)
	+'Freedom'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_freedom)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_freedom)), 1))-1)+ space(1)
	+'Forever'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_forever)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_forever)), 1))-1)+ space(1)
	+'Charlotte'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_charlotte)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_charlotte)), 1))-1)+ space(1)
	+'Bonchad'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_por_ramo)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo)), 1))-1)+ space(1)
	+'Ul hora'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1))-1)+ space(1)
	+'Salida'+ space(1)+'Sin actualizar'+ space(1)
	+'Invent'+ space(1)+ 'Sin actualizar'+ space(1)
	+'Freedom 40' +space(1)+ convert(nvarchar,@porcentaje_freedom_40)+'%'+ space(1)
	+'Light Pink 40'+ space(1) + convert(nvarchar,@porcentaje_light_pink_40)+'%'+ space(1)
	+'Hot Pink 40'+ space(1) + convert(nvarchar,@porcentaje_hot_pink_40)+'%'+ space(1)
	+'Yellow 40'+ space(1) + convert(nvarchar,@porcentaje_yellow_40)+'%'+ space(1)
	,'actualizacion tablero'
	)
end
else
begin
	update Tablero
	set tallos_postcosecha = left(convert(nvarchar, (convert(money, @tallos_postcosecha)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_postcosecha)), 1))-1),
	tallos_freedom = left(convert(nvarchar, (convert(money, @tallos_freedom)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_freedom)), 1))-1),
	tallos_charlotte = left(convert(nvarchar, (convert(money, @tallos_charlotte)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_charlotte)), 1))-1),
	tallos_por_ramo = left(convert(nvarchar, (convert(money, @tallos_por_ramo)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo)), 1))-1),
	tallos_por_ramo_ultima_hora = left(convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1))-1),
	hora_salida_estimada = @horas_estimada,
	fecha_actualizacion = getdate(),
	tallos_inventario = left(convert(nvarchar, (convert(money, @inventario)), 1), charindex('.', convert(nvarchar, (convert(money, @inventario)), 1))-1),
	freedom_40= convert(nvarchar, @porcentaje_freedom_40)+'%',
	light_pink_40='Light Pink 40:' + space(1) + convert(nvarchar, @porcentaje_light_pink_40)+'%',
	hot_pink_40='Hot Pink 40:' + space(1) + convert(nvarchar, @porcentaje_hot_pink_40)+'%',
	yellow_40='Yellow 40:' + space(1) + convert(nvarchar, @porcentaje_yellow_40)+'%',
	tallos_forever = 'Forever:'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_forever)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_forever)), 1))-1)

	insert into [dbo].[Log_info] (mensaje, tipo_mensaje)
	values ('Entrada'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_postcosecha)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_postcosecha)), 1))-1)+ space(1)
	+'Freedom'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_freedom)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_freedom)), 1))-1)+ space(1)	
	+'Forever'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_forever)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_forever)), 1))-1)+ space(1)	
	+'Charlotte'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_charlotte)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_charlotte)), 1))-1)+ space(1)	
	+'Bonchad'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_por_ramo)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo)), 1))-1)+ space(1)
	+'Ul hora'+ space(1)+left(convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1), charindex('.', convert(nvarchar, (convert(money, @tallos_por_ramo_ultima_hora)), 1))-1)+ space(1)
	+'Salida'+ space(1)+@horas_estimada+ space(1)
	+'Invent'+ space(1)+left(convert(nvarchar, (convert(money, @inventario)), 1), charindex('.', convert(nvarchar, (convert(money, @inventario)), 1))-1) + space(1)
	+'Freedom 40'+ space(1) + convert(nvarchar,@porcentaje_freedom_40)+'%'+ space(1)
	+'Light Pink 40'+ space(1) + convert(nvarchar,@porcentaje_light_pink_40)+'%'+ space(1)
	+'Hot Pink 40'+ space(1) + convert(nvarchar,@porcentaje_hot_pink_40)+'%'+ space(1)
	+'Yellow 40'+ space(1) + convert(nvarchar,@porcentaje_yellow_40)+'%'+ space(1)
	,'actualizacion tablero'
	)
end
