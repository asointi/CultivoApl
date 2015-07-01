--insert into labor (nombre_labor)
--values ('Bonchar')
--go
--insert into labor (nombre_labor)
--values ('Empacar')
--go
--insert into labor (nombre_labor)
--values ('Revisar')

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/05
-- Description:	Maneja la informacion de los ramos en sus diferentes fases que se encuentran en las piezas de Miami
-- =============================================

alter PROCEDURE [dbo].[na_editar_pieza_labor] 

@accion nvarchar(50),
@idc_persona nvarchar(15),
@nombre nvarchar(50),
@apellido nvarchar(50),
@idc_pieza nvarchar(15)

as

declare @id_persona int,
@id_pieza_labor int

select @id_persona = persona_cultivo.id_persona
from persona_cultivo
where persona_cultivo.idc_persona = @idc_persona

if(@id_persona is null)
begin
	insert into persona_cultivo (idc_persona, nombre, apellido)
	values (@idc_persona, ltrim(rtrim(@nombre)), ltrim(rtrim(@apellido)))

	set @id_persona = scope_identity()
end
else
begin
	update persona_cultivo
	set nombre = ltrim(rtrim(@nombre)),
	apellido = ltrim(rtrim(@apellido))
	where id_persona = @id_persona
end

if(@accion = 'insertar_bonchar')
begin
	select @id_pieza_labor = pieza_labor.id_pieza_labor
	from labor,
	pieza_labor,
	pieza
	where pieza.id_pieza = pieza_labor.id_pieza
	and labor.id_labor = pieza_labor.id_labor
	and pieza.idc_pieza = @idc_pieza
	and labor.nombre_labor = 'Bonchar'

	if(@id_pieza_labor is null)
	begin
		insert into pieza_labor (id_labor, id_pieza, id_persona)
		select labor.id_labor,
		pieza.id_pieza,
		@id_persona
		from labor,
		pieza
		where labor.nombre_labor = 'Bonchar'
		and pieza.idc_pieza = @idc_pieza

		select scope_identity() as id_pieza_labor
	end
	else
	begin
		update pieza_labor
		set id_persona = @id_persona
		where id_pieza_labor = @id_pieza_labor

		select @id_pieza_labor as id_pieza_labor
	end
end
else
if(@accion = 'insertar_empacar')
begin
	select @id_pieza_labor = pieza_labor.id_pieza_labor
	from labor,
	pieza_labor,
	pieza
	where pieza.id_pieza = pieza_labor.id_pieza
	and labor.id_labor = pieza_labor.id_labor
	and pieza.idc_pieza = @idc_pieza
	and labor.nombre_labor = 'Empacar'

	if(@id_pieza_labor is null)
	begin
		insert into pieza_labor (id_labor, id_pieza, id_persona)
		select labor.id_labor,
		pieza.id_pieza,
		@id_persona
		from labor,
		pieza
		where labor.nombre_labor = 'Empacar'
		and pieza.idc_pieza = @idc_pieza

		select scope_identity() as id_pieza_labor
	end
	else
	begin
		update pieza_labor
		set id_persona = @id_persona
		where id_pieza_labor = @id_pieza_labor

		select @id_pieza_labor as id_pieza_labor
	end
end
else
if(@accion = 'insertar_revisar')
begin
	select @id_pieza_labor = pieza_labor.id_pieza_labor
	from labor,
	pieza_labor,
	pieza
	where pieza.id_pieza = pieza_labor.id_pieza
	and labor.id_labor = pieza_labor.id_labor
	and pieza.idc_pieza = @idc_pieza
	and labor.nombre_labor = 'Revisar'

	if(@id_pieza_labor is null)
	begin
		insert into pieza_labor (id_labor, id_pieza, id_persona)
		select labor.id_labor,
		pieza.id_pieza,
		@id_persona
		from labor,
		pieza
		where labor.nombre_labor = 'Revisar'
		and pieza.idc_pieza = @idc_pieza

		select scope_identity() as id_pieza_labor
	end
	else
	begin
		update pieza_labor
		set id_persona = @id_persona
		where id_pieza_labor = @id_pieza_labor

		select @id_pieza_labor as id_pieza_labor
	end
end
else
if(@accion = 'consultar')
begin
	select persona_cultivo.idc_persona,
	persona_cultivo.nombre,
	persona_cultivo.apellido,
	labor.nombre_labor
	from pieza,
	pieza_labor,
	labor,
	persona_cultivo
	where persona_cultivo.id_persona = pieza_labor.id_persona
	and labor.id_labor = pieza_labor.id_labor
	and pieza.id_pieza = pieza_labor.id_pieza
	and pieza.idc_pieza = @idc_pieza
	order by labor.nombre_labor
end