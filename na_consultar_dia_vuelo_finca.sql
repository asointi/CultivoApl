set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_dia_vuelo_finca]

@dia_semana int,
@idc_farm nvarchar(255),
@idc_ciudad nvarchar(255),
@fecha nvarchar(255),
@accion nvarchar(255)

AS

declare @dias_atras_finca int,
@dias_restados_despacho_distribuidora int,
@id_tipo_despacho int,
@conteo int

select @dias_atras_finca = cantidad_dias_despacho_finca from configuracion_bd
select @dias_restados_despacho_distribuidora = dias_restados_despacho_distribuidora from farm where idc_farm = @idc_farm

set @fecha = convert(datetime,@fecha) - @dias_atras_finca - @dias_restados_despacho_distribuidora

select @dia_semana = datepart(dw, convert(datetime,@fecha))

if(@accion = 'farm')
begin
	create table #temp 
	(
		id_dia_despacho int,
		nombre_dia_despacho nvarchar(255),
		id_tipo_despacho int,
		nombre_tipo_despacho nvarchar(255)
	)

	select @conteo = count(*) from forma_despacho_farm, farm
	where farm.id_farm = forma_despacho_farm.id_farm
	and farm.idc_farm = @idc_farm

	if(@conteo > = 1)
	begin
		insert into #temp (id_dia_despacho,	nombre_dia_despacho, id_tipo_despacho, nombre_tipo_despacho)
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
		and tipo_factura.id_tipo_factura = 5
		and farm.id_farm = forma_despacho_farm.id_farm
		and farm.idc_farm = @idc_farm
	end
	else
	begin
		insert into #temp (id_dia_despacho,	nombre_dia_despacho, id_tipo_despacho, nombre_tipo_despacho)
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
		and tipo_factura.id_tipo_factura = 5
		and ciudad.id_ciudad = forma_despacho_ciudad.id_ciudad
		and farm.id_ciudad = ciudad.id_ciudad
		and farm.idc_farm = @idc_farm
	end

	select @id_tipo_despacho = id_tipo_despacho 
	from #temp
	where id_dia_despacho = @dia_semana

	if(@id_tipo_despacho = 3 or @id_tipo_despacho = 2)
	begin
		select id_dia_despacho,
		nombre_dia_despacho
		from #temp 
		where id_dia_despacho = @dia_semana
	end
	else
	begin
		set @dia_semana = replace(@dia_semana + 1, 8, 1)

		select @id_tipo_despacho = id_tipo_despacho
		from #temp
		where id_dia_despacho = @dia_semana
		
		if(@id_tipo_despacho = 3)
		begin
			select id_dia_despacho,
			nombre_dia_despacho
			from #temp 
			where id_dia_despacho = @dia_semana
		end
		else
		begin
			select @dia_semana = id_dia_despacho,
			@id_tipo_despacho = id_tipo_despacho
			from #temp
			where id_dia_despacho = replace(@dia_semana - 1, 0, 7)

			while(@id_tipo_despacho = 1)
			begin
				select @dia_semana = id_dia_despacho,
				@id_tipo_despacho = id_tipo_despacho
				from #temp
				where id_dia_despacho = replace(@dia_semana - 1, 0, 7)
			end
			select id_dia_despacho,
			nombre_dia_despacho
			from #temp 
			where id_dia_despacho = @dia_semana
		end
	end
drop table #temp
end
