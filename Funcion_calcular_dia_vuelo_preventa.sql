set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter FUNCTION [dbo].[calcular_dia_vuelo_preventa] (@fecha datetime, @idc_farm nvarchar(2))
RETURNS datetime

WITH EXECUTE AS CALLER
AS
BEGIN
	declare @dias_atras_finca int,
	@dias_restados_despacho_distribuidora int,
	@dias_atras_finca_preventa int,
	@id_tipo_despacho int,
	@conteo int,
	@dia_semana int,
	@corrimiento_preventa_activo bit,
	@idc_tipo_factura nvarchar(10),
	@fecha_inicial datetime,
	@fecha_resultante datetime

	set @fecha_inicial = @fecha
	select @corrimiento_preventa_activo = corrimiento_preventa_activo from configuracion_bd
	select @dias_atras_finca = cantidad_dias_despacho_finca from configuracion_bd
	select @dias_atras_finca_preventa = cantidad_dias_despacho_finca_preventa from configuracion_bd
	select @dias_restados_despacho_distribuidora = dias_restados_despacho_distribuidora from farm where idc_farm = @idc_farm

	set @fecha = @fecha - @dias_atras_finca - @dias_restados_despacho_distribuidora - @dias_atras_finca_preventa

	select @dia_semana = datepart(dw, @fecha)

	if(@corrimiento_preventa_activo = 1)
	begin
		set @idc_tipo_factura = '4'
	end
	else
	begin
		set @idc_tipo_factura = 'all'
	end

	declare @temp table
	(
		id_dia_despacho int,
		nombre_dia_despacho nvarchar(255),
		id_tipo_despacho int,
		nombre_tipo_despacho nvarchar(255)
	)

	select @conteo = count(*) 
	from forma_despacho_farm, 
	farm
	where farm.id_farm = forma_despacho_farm.id_farm
	and farm.idc_farm = @idc_farm

	if(@conteo > = 1)
	begin
		insert into @temp (id_dia_despacho,	nombre_dia_despacho, id_tipo_despacho, nombre_tipo_despacho)
		select dia_despacho.id_dia_despacho,
		dia_despacho.nombre_dia_despacho,
		tipo_despacho.id_tipo_despacho,
		tipo_despacho.nombre_tipo_despacho
		from tipo_factura,
		forma_despacho_farm,
		tipo_despacho,
		dia_despacho,
		farm
		where tipo_factura.id_tipo_factura = forma_despacho_farm.id_tipo_factura
		and tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
		and dia_despacho.id_dia_despacho = forma_despacho_farm.id_dia_despacho
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and farm.id_farm = forma_despacho_farm.id_farm
		and farm.idc_farm = @idc_farm
	end
	else
	begin
		insert into @temp (id_dia_despacho,	nombre_dia_despacho, id_tipo_despacho, nombre_tipo_despacho)
		select dia_despacho.id_dia_despacho,
		dia_despacho.nombre_dia_despacho,
		tipo_despacho.id_tipo_despacho,
		tipo_despacho.nombre_tipo_despacho
		from tipo_factura,
		forma_despacho_ciudad,
		tipo_despacho,
		dia_despacho,
		farm,
		ciudad
		where tipo_factura.id_tipo_factura = forma_despacho_ciudad.id_tipo_factura
		and tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
		and dia_despacho.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and ciudad.id_ciudad = forma_despacho_ciudad.id_ciudad
		and farm.id_ciudad = ciudad.id_ciudad
		and farm.idc_farm = @idc_farm
	end

	select @id_tipo_despacho = id_tipo_despacho 
	from @temp
	where id_dia_despacho = @dia_semana

	if(@id_tipo_despacho = 3 or @id_tipo_despacho = 2)
	begin
		select @fecha_resultante =
		case
			when datepart(dw,@fecha_inicial) = id_dia_despacho then @fecha_inicial - 7
			when datepart(dw,@fecha_inicial) > id_dia_despacho then @fecha_inicial-(datepart(dw, @fecha_inicial) - id_dia_despacho)
			when datepart(dw,@fecha_inicial) < id_dia_despacho then @fecha_inicial-(datepart(dw,@fecha_inicial) - id_dia_despacho + 7)
		end
		from @temp 
		where id_dia_despacho = @dia_semana
	end
	else
	begin
		set @dia_semana = replace(@dia_semana + 1, 8, 1)

		select @id_tipo_despacho = id_tipo_despacho
		from @temp
		where id_dia_despacho = @dia_semana
		
		if(@id_tipo_despacho = 3)
		begin
			select @fecha_resultante =
			case
				when datepart(dw,@fecha_inicial) = id_dia_despacho then @fecha_inicial - 7
				when datepart(dw,@fecha_inicial) > id_dia_despacho then @fecha_inicial-(datepart(dw, @fecha_inicial) - id_dia_despacho)
				when datepart(dw,@fecha_inicial) < id_dia_despacho then @fecha_inicial-(datepart(dw,@fecha_inicial) - id_dia_despacho + 7)
			end
			from @temp 
			where id_dia_despacho = @dia_semana
		end
		else
		begin
			select @dia_semana = id_dia_despacho,
			@id_tipo_despacho = id_tipo_despacho
			from @temp
			where id_dia_despacho = replace(@dia_semana - 1, 0, 7)

			while(@id_tipo_despacho = 1)
			begin
				select @dia_semana = id_dia_despacho,
				@id_tipo_despacho = id_tipo_despacho
				from @temp
				where id_dia_despacho = replace(@dia_semana - 1, 0, 7)
			end

			select @fecha_resultante =
			case
				when datepart(dw,@fecha_inicial) = id_dia_despacho then @fecha_inicial - 7
				when datepart(dw,@fecha_inicial) > id_dia_despacho then @fecha_inicial-(datepart(dw, @fecha_inicial) - id_dia_despacho)
				when datepart(dw,@fecha_inicial) < id_dia_despacho then @fecha_inicial-(datepart(dw,@fecha_inicial) - id_dia_despacho + 7)
			end
			from @temp 
			where id_dia_despacho = @dia_semana
		end
	end

	RETURN(@fecha_resultante);
END;


