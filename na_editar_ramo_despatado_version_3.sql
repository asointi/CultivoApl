set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_ramo_despatado_version_3]

@fecha datetime,
@idc_persona_inicial nvarchar(255),
@idc_persona_final nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	sum(ramo_despatado.tallos_por_ramo) as unidades,
	count(ramo_despatado.id_ramo_despatado) as cantidad_ramos
	from ramo_despatado,
	mesa_trabajo_persona,
	mesa,
	persona
	where mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona
	and convert(datetime, convert(nvarchar,ramo_despatado.fecha_lectura, 101)) = @fecha
	and persona.idc_persona > =
	case
		when @idc_persona_inicial = '' then '%%'
		else @idc_persona_inicial
	end
	and persona.idc_persona < =
	case
		when @idc_persona_final = '' then 'ZZZZZZZZZZZZZ'
		else @idc_persona_final
	end
	and not exists
	(
		select *
		from ramo_devuelto
		where ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado
	)
	group by persona.idc_persona,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido))
	order by ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido))
end