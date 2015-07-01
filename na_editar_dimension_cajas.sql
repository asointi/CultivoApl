set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_dimension_cajas]

@accion nvarchar(255),
@id_farm int, 
@id_tipo_caja int,
@id_caja int, 
@id_cuenta_interna int, 
@largo decimal(20,4), 
@ancho decimal(20,4), 
@alto decimal(20,4), 
@fecha_inicial datetime

AS

declare @conteo int,
@conteo_aux int,
@id int,
@fecha datetime

if(@accion = 'consultar_guias')
begin
	select guia.id_guia,
	guia.idc_guia,
	estado_guia.nombre_estado_guia,
	guia.fecha_guia
	from guia,
	estado_guia
	where guia.fecha_guia > = @fecha_inicial
	and estado_guia.id_estado_guia = guia.id_estado_guia
	order by guia.fecha_guia,
	guia.idc_guia
end
else
if(@accion = 'insertar_dimension_tipo_caja')
begin
	insert into dimension_tipo_caja (id_tipo_caja, id_cuenta_interna, largo, ancho, alto, fecha_inicial)
	values (@id_tipo_caja, @id_cuenta_interna, @largo, @ancho, @alto, @fecha_inicial)
end
else
if(@accion = 'consultar_dimension_tipo_caja')
begin
	declare @id_tipo_caja_aux int 

	select IDENTITY(int, 1, 1) AS id,
	max(id_dimension_tipo_caja) as id_dimension_tipo_caja,
	id_tipo_caja,
	fecha_inicial into #dimension_tipo_caja
	from dimension_tipo_caja
	group by id_tipo_caja,
	fecha_inicial
	order by id_tipo_caja,
	fecha_inicial

	alter table #dimension_tipo_caja
	add fecha_final datetime

	select @conteo = count(*)
	from #dimension_tipo_caja

	set @id = 1

	while (@id < = @conteo)
	begin
		set @fecha = null
		set @id_tipo_caja = null
		set @id_tipo_caja_aux = null

		select @id_tipo_caja = id_tipo_caja
		from #dimension_tipo_caja
		where id = @id

		select @fecha = fecha_inicial,
		@id_tipo_caja_aux = id_tipo_caja
		from #dimension_tipo_caja
		where id = @id + 1
		
		if(@id_tipo_caja = @id_tipo_caja_aux)
		begin
			update #dimension_tipo_caja
			set fecha_final = dateadd(dd, -1, @fecha)
			where id = @id
		end
		else
		begin
			update #dimension_tipo_caja
			set fecha_final = dateadd(dd,(365 - datepart(dy, fecha_inicial)), fecha_inicial)
			where id = @id
		end

		set @id = @id + 1
	end

	select dimension_tipo_caja.id_dimension_tipo_caja,
	tipo_caja.id_tipo_caja,
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	ltrim(rtrim(cuenta_interna.nombre)) as nombre_cuenta,
	dimension_tipo_caja.largo,
	dimension_tipo_caja.ancho,
	dimension_tipo_caja.alto,
	dimension_tipo_caja.fecha_inicial,
	dimension_tipo_caja.fecha_transaccion into #tipo_caja
	from dimension_tipo_caja,
	tipo_caja,
	cuenta_interna,
	#dimension_tipo_caja
	where tipo_caja.id_tipo_caja = dimension_tipo_caja.id_tipo_caja
	and cuenta_interna.id_cuenta_interna = dimension_tipo_caja.id_cuenta_interna
	and dimension_tipo_caja.id_dimension_tipo_caja = #dimension_tipo_caja.id_dimension_tipo_caja
	and @fecha_inicial between
	#dimension_tipo_caja.fecha_inicial and #dimension_tipo_caja.fecha_final
	order by nombre_tipo_caja

	select *
	from #tipo_caja

	select id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja
	from #tipo_caja
	group by id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja
	order by nombre_tipo_caja

	drop table #dimension_tipo_caja
	drop table #tipo_caja
end
else
if(@accion = 'insertar_dimension_caja')
begin
	insert into dimension_caja (id_caja, id_cuenta_interna, largo, ancho, alto, fecha_inicial)
	values (@id_caja, @id_cuenta_interna, @largo, @ancho, @alto, @fecha_inicial)
end
else
if(@accion = 'consultar_dimension_caja')
begin
	declare @id_caja_aux int 

	select IDENTITY(int, 1, 1) AS id,
	max(id_dimension_caja) as id_dimension_caja,
	id_caja,
	fecha_inicial into #dimension_caja
	from dimension_caja
	group by fecha_inicial,
	id_caja
	order by id_caja,
	fecha_inicial

	alter table #dimension_caja
	add fecha_final datetime

	select @conteo = count(*)
	from #dimension_caja

	set @id = 1

	while (@id < = @conteo)
	begin
		set @fecha = null
		set @id_caja = null
		set @id_caja_aux = null

		select @id_caja = id_caja
		from #dimension_caja
		where id = @id

		select @fecha = fecha_inicial,
		@id_caja_aux = id_caja
		from #dimension_caja
		where id = @id + 1
		
		if(@id_caja = @id_caja_aux)
		begin
			update #dimension_caja
			set fecha_final = dateadd(dd, -1, @fecha)
			where id = @id
		end
		else
		begin
			update #dimension_caja
			set fecha_final = dateadd(dd,(365 - datepart(dy, fecha_inicial)), fecha_inicial)
			where id = @id
		end

		set @id = @id + 1
	end

	select dimension_caja.id_dimension_caja,
	tipo_caja.id_tipo_caja,
	caja.id_caja,
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	ltrim(rtrim(cuenta_interna.nombre)) as nombre_cuenta,
	dimension_caja.largo,
	dimension_caja.ancho,
	dimension_caja.alto,
	dimension_caja.fecha_inicial,
	dimension_caja.fecha_transaccion into #caja
	from dimension_caja,
	#dimension_caja,
	tipo_caja,
	caja,
	cuenta_interna
	where tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = dimension_caja.id_caja
	and cuenta_interna.id_cuenta_interna = dimension_caja.id_cuenta_interna
	and dimension_caja.id_dimension_caja = #dimension_caja.id_dimension_caja
	and @fecha_inicial between
	#dimension_caja.fecha_inicial and #dimension_caja.fecha_final
	order by nombre_caja

	select *
	from #caja
	
	select id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja
	from #caja
	group by id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja
	order by nombre_tipo_caja

	drop table #dimension_caja
	drop table #caja
end
else
if(@accion = 'insertar_dimension_finca_caja')
begin
	insert into dimension_caja_por_farm (id_farm, id_caja, id_cuenta_interna, largo, ancho, alto, fecha_inicial)
	values (@id_farm, @id_caja, @id_cuenta_interna, @largo, @ancho, @alto, @fecha_inicial)
end
else
if(@accion = 'consultar_dimension_finca_caja')
begin
	declare @id_farm_aux int 

	select IDENTITY(int, 1, 1) AS id,
	max(id_dimension_caja_por_farm) as id_dimension_caja_por_farm,
	id_farm,
	id_caja,
	fecha_inicial into #dimension_caja_por_farm
	from dimension_caja_por_farm
	group by fecha_inicial,
	id_farm,
	id_caja
	order by id_farm,
	id_caja,
	fecha_inicial

	alter table #dimension_caja_por_farm
	add fecha_final datetime

	select @conteo = count(*)
	from #dimension_caja_por_farm

	set @id = 1

	while (@id < = @conteo)
	begin
		set @fecha = null
		set @id_farm = null
		set @id_caja = null
		set @id_farm_aux = null
		set @id_caja_aux = null

		select @id_farm = id_farm,
		@id_caja = id_caja
		from #dimension_caja_por_farm
		where id = @id

		select @fecha = fecha_inicial,
		@id_farm_aux = id_farm,
		@id_caja_aux = id_caja
		from #dimension_caja_por_farm
		where id = @id + 1
		
		if(@id_farm = @id_farm_aux and @id_caja = @id_caja_aux)
		begin
			update #dimension_caja_por_farm
			set fecha_final = dateadd(dd, -1, @fecha)
			where id = @id
		end
		else
		begin
			update #dimension_caja_por_farm
			set fecha_final = dateadd(dd,(365 - datepart(dy, fecha_inicial)), fecha_inicial)
			where id = @id
		end

		set @id = @id + 1
	end

	select dimension_caja_por_farm.id_dimension_caja_por_farm,
	tipo_caja.id_tipo_caja,
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	caja.id_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	ltrim(rtrim(cuenta_interna.nombre)) as nombre_cuenta,
	dimension_caja_por_farm.largo,
	dimension_caja_por_farm.ancho,
	dimension_caja_por_farm.alto,
	dimension_caja_por_farm.fecha_inicial,
	dimension_caja_por_farm.fecha_transaccion into #caja_finca
	from dimension_caja_por_farm,
	tipo_caja,
	caja,
	farm,
	cuenta_interna,
	#dimension_caja_por_farm
	where tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = dimension_caja_por_farm.id_caja
	and farm.id_farm = dimension_caja_por_farm.id_farm
	and cuenta_interna.id_cuenta_interna = dimension_caja_por_farm.id_cuenta_interna
	and dimension_caja_por_farm.id_dimension_caja_por_farm = #dimension_caja_por_farm.id_dimension_caja_por_farm
	and @fecha_inicial between
	#dimension_caja_por_farm.fecha_inicial and #dimension_caja_por_farm.fecha_final
	order by nombre_farm,
	nombre_caja

	select *
	from #caja_finca

	select id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja
	from #caja_finca
	group by id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja
	order by nombre_tipo_caja

	select id_farm,
	idc_farm,
	nombre_farm
	from #caja_finca
	group by id_farm,
	idc_farm,
	nombre_farm
	order by nombre_farm

	drop table #dimension_caja_por_farm
	drop table #caja_finca
end