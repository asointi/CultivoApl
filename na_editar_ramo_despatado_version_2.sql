set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ramo_despatado_version_2]

@idc_persona nvarchar(255),
@accion nvarchar(255),
@idc_mesa nvarchar(255),
@idc_ramo nvarchar(255), 
@tallos_por_ramo int

AS

declare @conteo int

if(@accion = 'consultar_mesa')
begin
	select mesa.id_mesa,
	mesa.idc_mesa 
	from mesa
	where idc_mesa <> 'Sin Asignar'
	order by idc_mesa
end
else
if(@accion = 'consultar_mesa_asignada')
begin
	select mesa.idc_mesa 
	from persona,
	mesa_trabajo_persona,
	mesa
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa_trabajo_persona.id_mesa = mesa.id_mesa
	and persona.idc_persona = @idc_persona
	and mesa.idc_mesa <> 'Sin Asignar'
end
else
if(@accion = 'asignar_mesa')
begin
	select @conteo = count(*)
	from mesa_trabajo_persona,
	persona
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and persona.idc_persona = @idc_persona

	if(@conteo = 0)
	begin
		update mesa_trabajo_persona
		set id_mesa = (select id_mesa from mesa where idc_mesa = 'Sin Asignar'),
		fecha_asignacion = getdate()
		from mesa
		where mesa.idc_mesa = @idc_mesa
		and mesa.id_mesa = mesa_trabajo_persona.id_mesa

		insert into mesa_trabajo_persona (id_persona, id_mesa)
		select persona.id_persona, mesa.id_mesa
		from persona,
		mesa
		where persona.idc_persona = @idc_persona
		and mesa.idc_mesa = @idc_mesa
	end
	else
	begin
		update mesa_trabajo_persona
		set id_mesa = (select id_mesa from mesa where idc_mesa = 'Sin Asignar'),
		fecha_asignacion = getdate()
		from mesa
		where mesa.idc_mesa = @idc_mesa
		and mesa.id_mesa = mesa_trabajo_persona.id_mesa
		
		update mesa_trabajo_persona
		set id_mesa = mesa.id_mesa,
		fecha_asignacion = getdate()
		from mesa,
		persona
		where mesa.idc_mesa = @idc_mesa
		and persona.id_persona = mesa_trabajo_persona.id_persona
		and persona.idc_persona = @idc_persona
	end
end
else
if(@accion = 'consultar_ramo')
begin
	select @conteo = count(*)
	from ramo_despatado
	where idc_ramo_despatado = @idc_ramo

	if(@conteo = 0)
	begin
		select 0 as result
	end
	else
	begin
		select 1 as result
	end
end
else
if(@accion = 'insertar_ramo')
begin
	select @conteo = count(*)
	from persona,
	mesa_trabajo_persona,
	mesa
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and mesa.idc_mesa <> 'Sin Asignar'
	

	if(@conteo > 0)
	begin
		select @conteo = count(*)
		from ramo_despatado
		where idc_ramo_despatado = @idc_ramo

		if(@conteo = 0)
		begin
			insert into ramo_despatado (id_persona, idc_ramo_despatado, tallos_por_ramo)
			select persona.id_persona, @idc_ramo, @tallos_por_ramo
			from persona
			where persona.idc_persona = @idc_persona
		end
		else
		begin
			select -1 as error
		end
	end
	else
	begin
		select -2 as error
	end	
end
else
if(@accion = 'insertar_mesa')
begin
	select @conteo = count(*)
	from mesa
	where ltrim(rtrim(mesa.idc_mesa)) = ltrim(rtrim(@idc_mesa))
	
	if(@conteo = 0)
	begin
		insert into mesa (idc_mesa)
		values (@idc_mesa)

		select 1 as error
	end
	else
	begin
		select -1 as error
	end
end