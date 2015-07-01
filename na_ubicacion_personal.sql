set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_ubicacion_personal]

@fecha datetime,
@descripcion nvarchar(255),
@idc_persona nvarchar(255),
@accion nvarchar(255)

as

declare @conteo int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from ubicacion_persona,
	persona
	where persona.id_persona = ubicacion_persona.id_persona
	and ubicacion_persona.fecha_aplicacion = convert(datetime,convert(nvarchar, @fecha, 101))
	and persona.idc_persona = @idc_persona
	and ubicacion_persona.descripcion = @descripcion

	if(@conteo = 0)
	begin
		insert into ubicacion_persona (id_persona, descripcion, fecha_aplicacion)
		select persona.id_persona, @descripcion, @fecha
		from persona
		where persona.idc_persona = @idc_persona
	end
end
else
if(@accion = 'consultar')
begin
	select top 1 descripcion
	from ubicacion_persona,
	persona
	where persona.id_persona = ubicacion_persona.id_persona
	and fecha_aplicacion = convert(datetime,convert(nvarchar, getdate(), 101))
	and persona.idc_persona = @idc_persona
	order by id_ubicacion_persona desc
end