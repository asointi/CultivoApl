set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-15
-- Description:	manipular información relacionada con ingresos y retiros de personal
-- =============================================

alter PROCEDURE [dbo].[na_editar_historia_laboral]

@idc_persona nvarchar(255),
@fecha nvarchar(255),
@accion nvarchar(255)

AS

declare @conteo int,
@id int

if(@accion = 'insertar_ingreso')
begin
	select @conteo = count(*) 
	from historia_ingreso, 
	persona
	where historia_ingreso.id_persona = persona.id_persona
	and persona.idc_persona = @idc_persona
	and historia_ingreso.fecha_ingreso = convert(datetime,@fecha)

	if(@conteo = 0)
	begin
		insert into historia_ingreso (id_persona, fecha_ingreso)
		select persona.id_persona,
		convert(datetime,@fecha)
		from persona
		where idc_persona = @idc_persona
	end
end
if(@accion = 'insertar_retiro')
begin
	select @id = max(historia_ingreso.id_historia_ingreso)
	from historia_ingreso,
	persona
	where historia_ingreso.id_persona = persona.id_persona
	and persona.idc_persona = @idc_persona
	group by persona.id_persona
	
	select @conteo = count(*)
	from historia_retiro 
	where historia_retiro.id_historia_ingreso = @id

	if(@conteo = 0)
	begin
		insert into historia_retiro (id_historia_ingreso, fecha_retiro)
		select max(historia_ingreso.id_historia_ingreso),
		convert(datetime, @fecha)
		from historia_ingreso,
		persona
		where historia_ingreso.id_persona = persona.id_persona
		and persona.idc_persona = @idc_persona
		group by persona.id_persona
	end
end