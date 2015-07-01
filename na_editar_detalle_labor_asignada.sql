USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[na_editar_detalle_labor_asignada]    Script Date: 05/01/2015 2:06:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_editar_detalle_labor_asignada]

@usuario nvarchar(25),
@idc_detalle_labor nvarchar(25),
@id_detalle_labor_asignada int,
@accion nvarchar(50),
@observacion nvarchar(512) = null,
@idc_persona nvarchar(10) = null,
@fecha_historia datetime = null

as

if(@accion = 'insertar')
begin
	declare @id_usuario_windows int

	select @id_usuario_windows = id_usuario_windows
	from usuario_windows (NOLOCK)
	where usuario = @usuario

	if(@id_usuario_windows is null)
	begin
		insert into usuario_windows (usuario)
		values (@usuario)

		set @id_usuario_windows = @@identity
	end

	begin try
		insert into detalle_labor_asignada (id_usuario_windows, id_detalle_labor)
		select @id_usuario_windows, id_detalle_labor
		from detalle_labor (NOLOCK)
		where detalle_labor.idc_detalle_labor = @idc_detalle_labor

		select @@identity as id_detalle_labor_asignada
	end try
	begin catch
		select -1 as id_detalle_labor_asignada
	end catch
end
else
if(@accion = 'consultar_asignacion')
begin
	declare @conteo int,
	@id int,
	@fecha_final_aux datetime,
	@id_persona int,
	@id_persona_aux int,
	@dia_ano int,
	@dia_ano_aux int,
	@fecha datetime

	set @fecha = cast(getdate() as date)

	declare @lectura_dia_actual table
	(
		id int identity(1,1),
		id_detalle_labor_asignada int,
		codigo_sublabor_asignada nvarchar(10),
		nombre_sublabor_asignada nvarchar(50),
		id_detalle_labor_pistoleada int,
		codigo_sublabor_pistoleada nvarchar(10),
		nombre_sublabor_pistoleada nvarchar(50),
		id_persona int,
		idc_persona nvarchar(10),
		nombre_persona nvarchar(50),
		hora_inicial datetime,
		hora_final datetime
	)

	declare @resultado table
	(
		idc_labor nvarchar(10),
		nombre_labor nvarchar(50),
		id_detalle_labor int,
		idc_detalle_labor nvarchar(10),
		nombre_detalle_labor nvarchar(50),
		id_detalle_labor_asignada int,
		correo nvarchar(50),
		cantidad_personas_propias int,
		cantidad_personas_entregadas int,
		cantidad_personas_recibidas int
	)
 
	declare @personas_actuales table
	(
		id_detalle_labor_asignada int,
		codigo_sublabor_asignada nvarchar(10),
		nombre_sublabor_asignada nvarchar(50),
		id_detalle_labor_pistoleada int,
		codigo_sublabor_pistoleada nvarchar(10),
		nombre_sublabor_pistoleada nvarchar(50),
		idc_persona nvarchar(10),
		nombre_persona nvarchar(50),
		hora_inicial datetime,
		hora_final datetime,
		sublabor_entrega nvarchar(10),
		sublabor_recibe nvarchar(10)
	) 

	declare @entregadas table
	(
		idc_detalle_labor nvarchar(10),	
		sublabor_recibe nvarchar(50), 
		hora_inicial datetime, 
		codigo_persona nvarchar(10), 
		nombre_persona nvarchar(50),
		observacion nvarchar(512),	
		usuario nvarchar(20), 
		fecha_transaccion datetime
	)

	declare @recibidas table
	(
		idc_detalle_labor nvarchar(10),	
		sublabor_entrega nvarchar(50), 
		hora_inicial datetime, 
		codigo_persona nvarchar(10), 
		nombre_persona nvarchar(50),
		observacion nvarchar(512),	
		usuario nvarchar(20), 
		fecha_transaccion datetime
	)

	declare @base table
	(
		idc_detalle_labor nvarchar(10),
		sublabor_propia nvarchar(50),
		hora_inicial datetime,
		codigo_persona nvarchar(10),
		nombre_persona nvarchar(50),
		observacion nvarchar(512),
		usuario nvarchar(25),
		fecha_transaccion datetime
	)

	insert into @lectura_dia_actual
	(
		id_detalle_labor_asignada,
		codigo_sublabor_asignada,
		nombre_sublabor_asignada,
		id_detalle_labor_pistoleada,
		codigo_sublabor_pistoleada,
		nombre_sublabor_pistoleada,
		id_persona,
		idc_persona,
		nombre_persona,
		hora_inicial
	)
	select dl.id_detalle_labor,
	dl.idc_detalle_labor,
	ltrim(rtrim(dl.nombre_detalle_labor)),
	detalle_labor.id_detalle_labor,
	detalle_labor.idc_detalle_labor,
	ltrim(rtrim(Detalle_Labor.nombre_detalle_labor)),
	persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.apellido)) + ' ' + ltrim(rtrim(persona.nombre)),
	detalle_labor_persona.fecha 
	from Detalle_Labor_Persona (NOLOCK),
	detalle_labor (NOLOCK),
	detalle_labor as dl (NOLOCK),
	persona (NOLOCK)
	where persona.id_persona = detalle_labor_persona.id_persona
	and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
	and cast(Detalle_Labor_Persona.fecha as date) = @fecha
	and dl.id_detalle_labor = persona.id_detalle_labor
	order by persona.id_persona,
	Detalle_Labor_Persona.fecha
  
	select @id = count(*) from @lectura_dia_actual
	set @conteo = 1

	while(@conteo < = @id)
	begin
		set @fecha_final_aux = null
		select @id_persona = id_persona,
		@dia_ano = datepart(dy, hora_inicial)
		from @lectura_dia_actual where id = @conteo
		
		select @id_persona_aux = id_persona,
		@dia_ano_aux = datepart(dy, hora_inicial) 
		from @lectura_dia_actual where id = @conteo + 1

		select @fecha_final_aux = hora_inicial 
		from @lectura_dia_actual 
		where id = @conteo + 1 
		and @id_persona = @id_persona_aux
		and @dia_ano = @dia_ano_aux

		update @lectura_dia_actual
		set hora_final = @fecha_final_aux
		where id = @conteo

		set @conteo = @conteo + 1
	end

	delete from @lectura_dia_actual
	where codigo_sublabor_pistoleada = 'ZZZZZZ'

	update @lectura_dia_actual
	set hora_final = dateadd(mi, 1439, convert(datetime, cast(hora_inicial as date)))
	where hora_final is null
 
	insert into @personas_actuales (id_detalle_labor_asignada,	codigo_sublabor_asignada,	nombre_sublabor_asignada,	id_detalle_labor_pistoleada, codigo_sublabor_pistoleada, nombre_sublabor_pistoleada, idc_persona,	nombre_persona,	hora_inicial,	hora_final,	sublabor_entrega, sublabor_recibe)
	select id_detalle_labor_asignada,
	codigo_sublabor_asignada,
	nombre_sublabor_asignada,
	id_detalle_labor_pistoleada,
	codigo_sublabor_pistoleada,
	nombre_sublabor_pistoleada,
	idc_persona,
	nombre_persona,
	hora_inicial,
	hora_final,
	case
		when id_detalle_labor_asignada = id_detalle_labor_pistoleada then ''
		else  codigo_sublabor_asignada
	end,
	case
		when id_detalle_labor_asignada = id_detalle_labor_pistoleada then ''
		else  codigo_sublabor_pistoleada
	end 
	from @lectura_dia_actual
	where getdate() between
	hora_inicial and hora_final

	insert into @resultado (idc_labor, nombre_labor, id_detalle_labor, idc_detalle_labor, nombre_detalle_labor, id_detalle_labor_asignada, correo, cantidad_personas_propias, cantidad_personas_entregadas, cantidad_personas_recibidas)
	select labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)),
	p.id_detalle_labor_asignada,
	p.codigo_sublabor_asignada,
	p.nombre_sublabor_asignada,
	detalle_labor_asignada.id_detalle_labor_asignada,
	detalle_labor.correo,
	count(*),
	(
		select count(*)
		from @personas_actuales as pa
		where pa.sublabor_entrega <> ''
		and pa.sublabor_entrega = p.codigo_sublabor_asignada
	),
	(
		select count(*)
		from @personas_actuales as pa
		where pa.sublabor_recibe <> ''
		and pa.sublabor_recibe = p.codigo_sublabor_asignada
	) 
	from @personas_actuales as p,
	labor (NOLOCK),
	detalle_labor (NOLOCK),
	detalle_labor_asignada (NOLOCK),
	usuario_windows (NOLOCK)
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = p.id_detalle_labor_asignada
	and detalle_labor.id_detalle_labor = detalle_labor_asignada.id_detalle_labor
	and usuario_windows.id_usuario_windows = detalle_labor_asignada.id_usuario_windows
	and usuario_windows.usuario = @usuario
	group by labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)),
	p.id_detalle_labor_asignada,
	p.codigo_sublabor_asignada,
	p.nombre_sublabor_asignada,
	detalle_labor_asignada.id_detalle_labor_asignada,
	detalle_labor.correo

	select idc_labor,
	nombre_labor,
	id_detalle_labor,
	idc_detalle_labor,
	nombre_detalle_labor,
	id_detalle_labor_asignada,
	correo,
	cantidad_personas_propias,
	cantidad_personas_entregadas,
	cantidad_personas_recibidas
	from @resultado
	union all
	select idc_labor,
	ltrim(rtrim(labor.nombre_labor)),
	p.id_detalle_labor_pistoleada,
	p.sublabor_recibe,
	p.nombre_sublabor_pistoleada,
	detalle_labor_asignada.id_detalle_labor_asignada,
	detalle_labor.correo,
	0,
	0,
	count(*)
	from @personas_actuales as p,
	labor (NOLOCK),
	detalle_labor (NOLOCK),
	detalle_labor_asignada (NOLOCK),
	usuario_windows (NOLOCK)
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = p.id_detalle_labor_pistoleada
	and detalle_labor.id_detalle_labor = detalle_labor_asignada.id_detalle_labor
	and usuario_windows.id_usuario_windows = detalle_labor_asignada.id_usuario_windows
	and usuario_windows.usuario = @usuario
	and p.sublabor_recibe <> ''
	and not exists
	(
		select * 
		from @resultado as r
		where r.idc_detalle_labor = p.sublabor_recibe
	)
	group by idc_labor,
	ltrim(rtrim(labor.nombre_labor)),
	p.id_detalle_labor_pistoleada,
	p.sublabor_recibe,
	p.nombre_sublabor_pistoleada,
	detalle_labor_asignada.id_detalle_labor_asignada,
	detalle_labor.correo
	order by idc_labor,
	idc_detalle_labor

	insert into @entregadas (idc_detalle_labor,	sublabor_recibe, hora_inicial, codigo_persona, nombre_persona, observacion,	usuario, fecha_transaccion) 
	select p.codigo_sublabor_asignada,
	sublabor_recibe + ' - ' + ltrim(rtrim(dl.nombre_detalle_labor)),
	hora_inicial,
	p.idc_persona,
	nombre_persona,
	funcion_asignada.observacion,
	uw.usuario,
	funcion_asignada.fecha_transaccion
	from @personas_actuales as p,
	detalle_labor,
	detalle_labor as dl,
	detalle_labor_asignada,
	Usuario_Windows,
	persona left join funcion_asignada on persona.id_persona = dbo.Funcion_Asignada.id_persona
	left join usuario_windows as uw on uw.id_usuario_windows = dbo.Funcion_Asignada.id_usuario_windows
	where p.codigo_sublabor_asignada = Detalle_Labor.idc_detalle_labor
	and persona.idc_persona = p.idc_persona
	and detalle_labor.id_detalle_labor = detalle_labor_asignada.id_detalle_labor
	and usuario_windows.id_usuario_windows = detalle_labor_asignada.id_usuario_windows
	and usuario_windows.usuario = @usuario
	and sublabor_entrega <> ''
	and sublabor_recibe = dl.idc_detalle_labor

	insert into @recibidas (idc_detalle_labor,	sublabor_entrega, hora_inicial, codigo_persona, nombre_persona, observacion, usuario, fecha_transaccion) 
	select p.sublabor_recibe,
	sublabor_entrega + ' - ' + ltrim(rtrim(dl.nombre_detalle_labor)),
	hora_inicial,
	p.idc_persona,
	nombre_persona,
	funcion_asignada.observacion,
	uw.usuario,
	funcion_asignada.fecha_transaccion
	from @personas_actuales as p,
	detalle_labor (NOLOCK),
	detalle_labor as dl,
	detalle_labor_asignada (NOLOCK),
	Usuario_Windows (NOLOCK),
	persona left join funcion_asignada on persona.id_persona = dbo.Funcion_Asignada.id_persona
	left join usuario_windows as uw on uw.id_usuario_windows = dbo.Funcion_Asignada.id_usuario_windows
	where persona.idc_persona = p.idc_persona
	and p.sublabor_recibe = Detalle_Labor.idc_detalle_labor
	and detalle_labor.id_detalle_labor = detalle_labor_asignada.id_detalle_labor
	and usuario_windows.id_usuario_windows = detalle_labor_asignada.id_usuario_windows
	and usuario_windows.usuario = @usuario
	and sublabor_recibe <> ''
	and sublabor_entrega = dl.idc_detalle_labor

	insert into @base (idc_detalle_labor, sublabor_propia, hora_inicial, codigo_persona, nombre_persona, observacion, usuario, fecha_transaccion)
	select p.codigo_sublabor_asignada,
	p.codigo_sublabor_asignada + ' - ' + p.nombre_sublabor_asignada,
	hora_inicial,
	p.idc_persona,
	p.nombre_persona,
	funcion_asignada.observacion,
	uw.usuario,
	funcion_asignada.fecha_transaccion
	from @personas_actuales as p,
	labor (NOLOCK),
	detalle_labor (NOLOCK),
	detalle_labor_asignada (NOLOCK),
	usuario_windows,
	persona left join funcion_asignada on persona.id_persona = dbo.Funcion_Asignada.id_persona
	left join usuario_windows as uw on uw.id_usuario_windows = dbo.Funcion_Asignada.id_usuario_windows
	where labor.id_labor = detalle_labor.id_labor
	and persona.idc_persona = p.idc_persona
	and detalle_labor.id_detalle_labor = p.id_detalle_labor_asignada
	and detalle_labor.id_detalle_labor = detalle_labor_asignada.id_detalle_labor
	and usuario_windows.id_usuario_windows = detalle_labor_asignada.id_usuario_windows
	and usuario_windows.usuario = @usuario

	select idc_detalle_labor,	
	sublabor_recibe, 
	hora_inicial, 
	codigo_persona, 
	nombre_persona,
	observacion,
	usuario,
	fecha_transaccion
	from @entregadas

	select idc_detalle_labor,	
	sublabor_entrega, 
	hora_inicial, 
	codigo_persona, 
	nombre_persona,
	observacion,
	usuario,
	fecha_transaccion
	from @recibidas
	
	select idc_detalle_labor, 
	sublabor_propia, 
	hora_inicial, 
	codigo_persona, 
	nombre_persona, 
	observacion, 
	usuario, 
	fecha_transaccion
	from @base

	select idc_detalle_labor, 
	sublabor_propia as sublabor_origen, 
	hora_inicial, 
	codigo_persona, 
	nombre_persona,
	observacion,
	usuario,
	fecha_transaccion
	from @base as b
	where not exists
	(
		select * 
		from @entregadas as e
		where b.idc_detalle_labor = e.idc_detalle_labor
		and b.codigo_persona = e.codigo_persona
	)
	union all
	select idc_detalle_labor, 
	sublabor_entrega, 
	hora_inicial, 
	codigo_persona, 
	nombre_persona,
	observacion,
	usuario,
	fecha_transaccion
	from @recibidas
end
else
if(@accion = 'eliminar_asignacion')
begin
	begin try
		delete from detalle_labor_asignada
		where detalle_labor_asignada.id_detalle_labor_asignada = @id_detalle_labor_asignada

		select 1 as id_detalle_labor_asignada
	end try
	begin catch
		select -1 as id_detalle_labor_asignada
	end catch
end
else
if(@accion = 'insertar_funcion')
begin
	declare @id_persona1 int,
	@conteo1 int,
	@id_usuario_windows1 int

	select @id_persona1 = id_persona from Persona where idc_persona = @idc_persona
	select @id_usuario_windows1 = id_usuario_windows from Usuario_Windows where usuario = @usuario

	select @conteo1 = count(*)
	from funcion_asignada
	where id_persona = @id_persona1

	if(@conteo1 = 0)
	begin
		INSERT into funcion_asignada (id_persona, id_usuario_windows, observacion)
		values (@id_persona1, @id_usuario_windows1, @observacion)
	end
	else
	begin
		update funcion_asignada
		set observacion = @observacion, 
		id_usuario_windows = @id_usuario_windows1, 
		fecha_transaccion = getdate()
		where id_persona = @id_persona1
	end
  
	select observacion,
	usuario_windows.usuario,
	funcion_asignada.fecha_transaccion
	from funcion_asignada,
	usuario_windows
	where funcion_asignada.id_persona = @id_persona1
	and dbo.Funcion_Asignada.id_usuario_windows = dbo.Usuario_Windows.id_usuario_windows
end
else
if(@accion = 'consultar_historial')
begin
	select ltrim(rtrim(persona.apellido)) + ' ' + ltrim(rtrim(persona.nombre)) as nombre_persona,
	labor.idc_labor + ' - ' + ltrim(rtrim(labor.nombre_labor)) as nombre_labor,
	detalle_labor.idc_detalle_labor + ' - ' + ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_sublabor,
	detalle_labor_persona.fecha
	from Detalle_Labor_Persona,
	detalle_labor,
	persona,
	labor
	where convert(datetime, cast(Detalle_Labor_Persona.fecha as date)) = @fecha_historia
	and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
	and persona.id_persona = detalle_labor_persona.id_persona
	and persona.idc_persona = @idc_persona
	and labor.id_labor = detalle_labor.id_labor
	order by detalle_labor_persona.fecha
end