set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[huella_editar_registro_huella_version2]

@idc_persona nvarchar(255),
@usuario_cobol nvarchar(255),
@template varbinary (3000),
@consecutivo_cobol int,
@accion nvarchar(255),
@validacion_exitosa bit,
@fecha datetime

as

if(@accion = 'registrar_huella')
begin
	declare @id_registro_huella int

	insert into registro_huella (id_persona, usuario_cobol, template)
	select persona.id_persona, @usuario_cobol, @template
	from persona
	where persona.idc_persona = @idc_persona

	set @id_registro_huella = scope_identity()

	select @id_registro_huella as id_registro_huella
end
else
if(@accion = 'consultar_existencia_huella')
begin
	select 
	case
		when count(*) > 0 then 1
		when count(*) = 0 then 0
	end as existente
	from persona, 
	registro_huella
	where persona.id_persona = registro_huella.id_persona
	and persona.idc_persona = @idc_persona
end
else
if(@accion = 'consultar_huella')
begin
	select registro_huella.template as huella
	from registro_huella,
	persona,
	registro_huella as rh
	where persona.id_persona = registro_huella.id_persona
	and persona.idc_persona = @idc_persona
	and rh.id_persona = persona.id_persona
	and registro_huella.id_registro_huella < = rh.id_registro_huella
	group by registro_huella.id_registro_huella,
	registro_huella.template	
	having registro_huella.id_registro_huella = max(rh.id_registro_huella)
end
else
if(@accion = 'marcacion_persona')
begin
	declare @id_marcacion_persona_huella int

	insert into marcacion_persona_huella (id_registro_huella, consecutivo_COBOL, id_persona, validacion_exitosa)
	select registro_huella.id_registro_huella, @consecutivo_cobol, (select id_persona from persona where idc_persona = @idc_persona), @validacion_exitosa
	from registro_huella,
	persona,
	registro_huella as rh
	where persona.id_persona = registro_huella.id_persona
	and persona.idc_persona = @idc_persona
	and rh.id_persona = persona.id_persona
	and registro_huella.id_registro_huella < = rh.id_registro_huella
	group by registro_huella.id_registro_huella
	having registro_huella.id_registro_huella = max(rh.id_registro_huella)

	set @id_marcacion_persona_huella = scope_identity()

	select @id_marcacion_persona_huella as id_marcacion_persona_huella
end
else
if(@accion = 'consultar_marcacion_persona')
begin
	select marcacion_persona_huella.validacion_exitosa
	from marcacion_persona_huella,
	persona
	where persona.id_persona = marcacion_persona_huella.id_persona
	and persona.idc_persona = @idc_persona
	and marcacion_persona_huella.consecutivo_COBOL = @consecutivo_cobol
end
else
if(@accion = 'consultar_creacion_huella')
begin
	select top 1 registro_huella.usuario_cobol,
	registro_huella.fecha_grabacion,
	convert(nvarchar,registro_huella.fecha_grabacion,108) as hora_grabacion
	from registro_huella,
	persona,
	registro_huella as rh
	where persona.id_persona = registro_huella.id_persona
	and persona.idc_persona = @idc_persona
	and rh.id_persona = persona.id_persona
	and registro_huella.id_registro_huella < = rh.id_registro_huella
	and convert(datetime, convert(nvarchar,registro_huella.fecha_grabacion,101)) < = @fecha
	group by registro_huella.id_registro_huella,
	registro_huella.usuario_cobol,
	registro_huella.fecha_grabacion,
	convert(nvarchar,registro_huella.fecha_grabacion,108)
	having registro_huella.id_registro_huella = max(rh.id_registro_huella)
	order by registro_huella.fecha_grabacion desc
end