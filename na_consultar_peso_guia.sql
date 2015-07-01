set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_peso_guia]

@accion nvarchar(255),
@id_guia int

AS

declare @conteo int,
@conteo_aux int,
@id int,
@fecha datetime,
@id_tipo_caja int,
@id_tipo_caja_aux int

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

if(@accion = 'consultar_dimension_completa')
begin
	select tipo_caja.id_tipo_caja into #tipo_caja
	from guia,
	pieza,
	caja,
	tipo_caja
	where guia.id_guia = pieza.id_guia
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and guia.id_guia = @id_guia
	group by tipo_caja.id_tipo_caja

	select tipo_caja.id_tipo_caja into #tipo_caja_grabada
	from guia,
	#dimension_tipo_caja,
	pieza,
	caja,
	tipo_caja
	where guia.id_guia = pieza.id_guia
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.id_tipo_caja = #dimension_tipo_caja.id_tipo_caja
	and guia.id_guia = @id_guia
	and guia.fecha_guia between
	#dimension_tipo_caja.fecha_inicial and #dimension_tipo_caja.fecha_final

	alter table #tipo_caja
	add id_tipo_caja_verificado int

	update #tipo_caja
	set id_tipo_caja_verificado = #tipo_caja_grabada.id_tipo_caja
	from #tipo_caja_grabada
	where #tipo_caja.id_tipo_caja = #tipo_caja_grabada.id_tipo_caja

	select @conteo = count(*) from #tipo_caja
	select @conteo_aux = count(*) from #tipo_caja where id_tipo_caja_verificado is not null

	if(@conteo = @conteo_aux)
	begin
		select 1 as dimension_completa
	end
	else
	begin
		select 0 as dimension_completa
	end
end
else
if(@accion = 'consultar_peso')
begin
	declare @id_farm int,
	@id_caja int,
	@id_farm_aux int,
	@id_caja_aux int

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

	select IDENTITY(int, 1, 1) AS id,
	max(id_dimension_caja) as id_dimension_caja,
	id_caja,
	fecha_inicial into #dimension_caja
	from dimension_caja
	group by fecha_inicial,
	id_caja
	order by id_caja,
	fecha_inicial

	alter table #dimension_caja_por_farm
	add fecha_final datetime

	alter table #dimension_caja
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

	select pieza.id_pieza,
	dimension_caja_por_farm.largo, 
	dimension_caja_por_farm.ancho, 
	dimension_caja_por_farm.alto into #peso_por_pieza
	from guia,
	pieza,
	caja,
	farm,
	dimension_caja_por_farm,
	#dimension_caja_por_farm
	where guia.id_guia = @id_guia
	and guia.id_guia = pieza.id_guia
	and caja.id_caja = pieza.id_caja
	and farm.id_farm = pieza.id_farm
	and caja.id_caja = dimension_caja_por_farm.id_caja
	and farm.id_farm = dimension_caja_por_farm.id_farm
	and dimension_caja_por_farm.id_dimension_caja_por_farm = #dimension_caja_por_farm.id_dimension_caja_por_farm
	and guia.fecha_guia between
	#dimension_caja_por_farm.fecha_inicial and #dimension_caja_por_farm.fecha_final

	drop table #dimension_caja_por_farm

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

	insert into #peso_por_pieza 
	(
		id_pieza,
		largo, 
		ancho, 
		alto 
	)
	select pieza.id_pieza,
	dimension_caja.largo, 
	dimension_caja.ancho, 
	dimension_caja.alto
	from guia,
	pieza,
	caja,
	dimension_caja,
	#dimension_caja
	where guia.id_guia = @id_guia
	and guia.id_guia = pieza.id_guia
	and caja.id_caja = pieza.id_caja
	and caja.id_caja = dimension_caja.id_caja
	and dimension_caja.id_dimension_caja = #dimension_caja.id_dimension_caja
	and guia.fecha_guia between
	#dimension_caja.fecha_inicial and #dimension_caja.fecha_final
	and not exists
	(
		select *
		from #peso_por_pieza
		where pieza.id_pieza = #peso_por_pieza.id_pieza
	)

	drop table #dimension_caja

	insert into #peso_por_pieza 
	(
		id_pieza,
		largo, 
		ancho, 
		alto 
	)
	select pieza.id_pieza,
	dimension_tipo_caja.largo, 
	dimension_tipo_caja.ancho, 
	dimension_tipo_caja.alto
	from guia,
	pieza,
	caja,
	tipo_caja,
	dimension_tipo_caja,
	#dimension_tipo_caja
	where guia.id_guia = @id_guia
	and guia.id_guia = pieza.id_guia
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.id_tipo_caja = dimension_tipo_caja.id_tipo_caja
	and dimension_tipo_caja.id_dimension_tipo_caja = #dimension_tipo_caja.id_dimension_tipo_caja
	and guia.fecha_guia between
	#dimension_tipo_caja.fecha_inicial and #dimension_tipo_caja.fecha_final
	and not exists
	(
		select *
		from #peso_por_pieza
		where pieza.id_pieza = #peso_por_pieza.id_pieza
	)

	select cast(round(sum(largo * ancho * alto)/6000, 2) as numeric(20,2)) as peso
	from #peso_por_pieza

	drop table #peso_por_pieza
end

drop table #dimension_tipo_caja
