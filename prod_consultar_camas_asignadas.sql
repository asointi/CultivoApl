set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_camas_asignadas]

@idc_persona nvarchar(255),
@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255)

as

--declare @id_persona int,
----@cantidad_camas int,
--@tallos int,
--@fecha_inicial_datetime datetime,
--@fecha_final_datetime datetime
--
--set @fecha_inicial_datetime = convert(datetime, @fecha_inicial)
--set @fecha_final_datetime = convert(datetime, @fecha_final)
--select @id_persona = persona.id_persona 
--from persona
--where persona.idc_persona = @idc_persona
--
--select @tallos = isnull(sum(unidades_por_pieza), 0)
--from pieza_postcosecha,
--persona
--where persona.id_persona = pieza_postcosecha.id_persona
--and persona.id_persona = @id_persona
--and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between @fecha_inicial_datetime and @fecha_final_datetime

--select top 1 @cantidad_camas = 
--(
--	select count(sembrar_cama_bloque.id_sembrar_cama_bloque)
--	from sembrar_cama_bloque,
--	detalle_area
--	where not exists
--	(
--		select *
--		from erradicar_cama_bloque
--		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
--	)
--	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
--	and area.id_area = detalle_area.id_area
--)
--from persona,
--area_asignada,
--area,
--estado_area
--where persona.id_persona = area_asignada.id_persona
--and area.id_area = area_asignada.id_area
--and estado_area.id_estado_area = area.id_estado_area
--and estado_area.nombre_estado_area = 'Asignada'
--and persona.id_persona = @id_persona
--group by area.id_area

--select @tallos as tallos,
--@cantidad_camas as cantidad_camas

select 0 as tallos,
0 as cantidad_camas