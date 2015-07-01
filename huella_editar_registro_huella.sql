set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[huella_editar_registro_huella]

@accion nvarchar(50),
@idc_persona nvarchar(25),
@numero_dedo int,
@usuario_cobol nvarchar(25),
@template varbinary(max)

as

if(@accion = 'registrar_huella')
begin
	declare @id_registro_huella int

	select @id_registro_huella = registro_huella.id_registro_huella
	from persona,
	dedo,
	registro_huella
	where dedo.id_dedo = registro_huella.id_dedo
	and persona.id_persona = registro_huella.id_persona
	and persona.idc_persona = @idc_persona
	and dedo.numero_dedo = @numero_dedo

	if(@id_registro_huella is null)
	begin
		insert into registro_huella (id_persona, id_dedo, usuario_cobol, template)
		select persona.id_persona, 
		dedo.id_dedo,
		@usuario_cobol, 
		@template
		from persona,
		dedo
		where persona.idc_persona = @idc_persona
		and dedo.numero_dedo = @numero_dedo

		select scope_identity() as id_registro_huella
	end
	else
	begin
		update registro_huella
		set template = @template,
		fecha_grabacion = getdate(),
		usuario_cobol = @usuario_cobol
		where registro_huella.id_registro_huella = @id_registro_huella

		select @id_registro_huella as id_registro_huella
	end
end
else
if(@accion = 'consultar_huella')
begin
	select registro_huella.template as huella,
	registro_huella.usuario_cobol,
	convert(nvarchar,registro_huella.fecha_grabacion, 103) as fecha_grabacion,
	convert(nvarchar,registro_huella.fecha_grabacion, 108) as hora_grabacion
	from registro_huella,
	persona,
	dedo
	where persona.id_persona = registro_huella.id_persona
	and dedo.id_dedo = registro_huella.id_dedo
	and persona.idc_persona = @idc_persona
	and dedo.numero_dedo = @numero_dedo
end
else
if(@accion = 'consultar_huella_por_persona')
begin
	select dedo.numero_dedo,
	registro_huella.template as huella,
	registro_huella.usuario_cobol,
	convert(nvarchar,registro_huella.fecha_grabacion, 103) as fecha_grabacion,
	convert(nvarchar,registro_huella.fecha_grabacion, 108) as hora_grabacion
	from registro_huella,
	persona,
	dedo
	where persona.id_persona = registro_huella.id_persona
	and dedo.id_dedo = registro_huella.id_dedo
	and persona.idc_persona = @idc_persona
	order by dedo.numero_dedo
end
else
if(@accion = 'consultar_huella_todos')
begin
	select persona.id_persona into #persona
	from persona
	where disponible = 1
	and exists
	(
		select * from historia_ingreso
		where historia_ingreso.id_persona = persona.id_persona
		and not exists
		(
			select * from historia_retiro
			where historia_ingreso.id_historia_ingreso = historia_retiro.id_historia_ingreso
		)
	)

	select persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + persona.identificacion + ')' as nombre_persona,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion,
	dedo.numero_dedo,
	registro_huella.template as huella,
	registro_huella.usuario_cobol,
	convert(nvarchar,registro_huella.fecha_grabacion, 103) as fecha_grabacion,
	convert(nvarchar,registro_huella.fecha_grabacion, 108) as hora_grabacion
	from registro_huella,
	persona,
	dedo
	where persona.id_persona = registro_huella.id_persona
	and dedo.id_dedo = registro_huella.id_dedo
	and exists
	(
		select *
		from #persona
		where #persona.id_persona = persona.id_persona
	)
	order by nombre_persona,
	dedo.numero_dedo

	drop table #persona
end