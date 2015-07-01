SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[na_enviar_personas_por_supervisor] 

@accion nvarchar(50),
@id_detalle_labor int

as

if(@accion = 'enviar_mail')
begin
	declare @correo nvarchar(255),
	@idc_detalle_labor nvarchar(25),
	@nombre_detalle_labor nvarchar(50),
	@query1 varchar(255),
	@cantidad int,
	@subject1 nvarchar(512),
	@conteo nvarchar(5)

	select @correo = correo,
	@idc_detalle_labor = idc_detalle_labor,
	@nombre_detalle_labor = ltrim(rtrim(nombre_detalle_labor))
	from detalle_labor
	where id_detalle_labor = @id_detalle_labor

	select persona.id_persona,
	max(detalle_labor_persona.id_detalle_labor_persona) as id_detalle_labor_persona into ##marcacion
	from detalle_labor_persona,
	persona
	where persona.id_persona = Detalle_Labor_Persona.id_persona
	and convert(datetime, convert(nvarchar, detalle_labor_persona.fecha, 103)) = convert(datetime, convert(nvarchar, getdate(), 103))
	group by persona.id_persona

	select 	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) as persona into ##resultado
	from ##marcacion as m,
	detalle_labor,
	Detalle_Labor_Persona,
	persona
	where detalle_labor.id_detalle_labor = Detalle_Labor_Persona.id_detalle_labor
	and persona.id_persona = Detalle_Labor_Persona.id_persona
	and m.id_detalle_labor_persona = detalle_labor_persona.id_detalle_labor_persona
	and detalle_labor.id_detalle_labor = @id_detalle_labor
	order by nombre

	select @conteo = count(*) from ##resultado

	set @query1 = 'select persona from ##resultado'
	set @subject1 = @idc_detalle_labor + ' ' + @nombre_detalle_labor + ' #' + @conteo

	if(len(@correo) > 7)
	begin
		EXEC msdb.dbo.sp_send_dbmail 
			@recipients = @correo,
			@subject = @subject1,
			@query = @query1, 
			@body_format = 'text',
			@exclude_query_output = 1,
			@query_result_header = 0;
	end

	DROP TABLE ##marcacion
	DROP TABLE ##resultado
end