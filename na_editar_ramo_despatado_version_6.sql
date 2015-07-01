--alter table Ramo_Despatado
--add	[flor_propia] Bit NULL
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ramo_despatado_version_6]

@idc_persona nvarchar(255),
@accion nvarchar(255),
@idc_mesa nvarchar(255),
@idc_ramo nvarchar(255), 
@tallos_por_ramo int,
@es_bouquet bit,
@flor_propia bit

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
if(@accion = 'insertar_ramo')
begin
	declare @id_ramo_despatado int,
	@id_ramo_devuelto int
	
	select @conteo = count(*)
	from persona,
	mesa_trabajo_persona,
	mesa
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and mesa.idc_mesa <> 'Sin Asignar'
	and persona.idc_persona = @idc_persona
	
	if(@conteo > 0)
	begin
		select @id_ramo_despatado = ramo_despatado.id_ramo_despatado
		from ramo_despatado
		where idc_ramo_despatado = @idc_ramo

		if(@id_ramo_despatado is null)
		begin
			insert into ramo_despatado (id_persona, idc_ramo_despatado, tallos_por_ramo, es_bouquet, flor_propia)
			select persona.id_persona, @idc_ramo, @tallos_por_ramo, @es_bouquet, @flor_propia
			from persona
			where persona.idc_persona = @idc_persona

			select 0 as error
		end
		else
		begin
			select @id_ramo_devuelto = ramo_devuelto.id_ramo_devuelto
			from ramo_devuelto
			where ramo_devuelto.id_ramo_despatado = @id_ramo_despatado

			if(@id_ramo_devuelto is not null)	
			begin
				select -3 as error
			end
			else
			begin
				select -1 as error
			end
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
else
if(@accion = 'consultar_ramo')
begin
	select ramo_despatado.idc_ramo_despatado,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	ramo_despatado.tallos_por_ramo,
	convert(nvarchar,ramo_despatado.fecha_lectura, 103) as fecha_lectura,
	convert(nvarchar,ramo_despatado.fecha_lectura, 108) as hora_lectura,
	mesa.idc_mesa
	from ramo_despatado,
	mesa_trabajo_persona,
	persona,
	mesa
	where idc_ramo_despatado = @idc_ramo
	and persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
end
