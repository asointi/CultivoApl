set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_salida_pieza_version4]

@accion nvarchar(50),
@idc_pieza_postcosecha nvarchar(25),
@fecha nvarchar(8),
@hora nvarchar(8),
@idc_cliente_despacho nvarchar(15),
@usuario_cobol nvarchar(20),
@computador nvarchar(20),
@sesion nvarchar(20)

AS

if(@accion = 'insertar')
begin
	declare @conteo_pieza int,
	@conteo_entrada int

	select @hora =
	case 
	when len(@hora) = 8 then @hora
		when len(@hora) = 7 then '0'+ @hora
		when len(@hora) = 6 then '00'+ @hora
		when len(@hora) = 5 then '000'+ @hora
		when len(@hora) = 4 then '0000'+ @hora
		when len(@hora) = 3 then '00000'+ @hora
		when len(@hora) = 2 then '000000'+ @hora
		when len(@hora) = 1 then '0000000'+ @hora
		when len(@hora) = 0 then '00000000'+ @hora
	end

	select @conteo_pieza = count(*)
	from pieza_postcosecha
	where pieza_postcosecha.idc_pieza_postcosecha = @idc_pieza_postcosecha

	select @conteo_entrada = count(*)
	from pieza_postcosecha,
	entrada
	where pieza_postcosecha.idc_pieza_postcosecha = @idc_pieza_postcosecha
	and pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha

	if(@conteo_pieza = 0)
	begin
		select -2 as insercion
	end
	else 
	if(@conteo_entrada = 0)
	begin
		select -3 as insercion
	end
	else
	begin
		begin try
			insert into salida_pieza (id_pieza_postcosecha, fecha_salida, id_cliente_despacho, usuario_cobol, computador, sesion)
			select pieza_postcosecha.id_pieza_postcosecha, 
			[dbo].[concatenar_fecha_hora_COBOL] (@fecha, @hora),
			cliente_despacho.id_cliente_despacho,
			@usuario_cobol,
			@computador,
			@sesion
			from pieza_postcosecha,
			cliente_despacho
			where pieza_postcosecha.idc_pieza_postcosecha = @idc_pieza_postcosecha
			and ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) = ltrim(rtrim(@idc_cliente_despacho))

			select 1 as insercion
		end try
		begin catch
			select -1 as insercion
		end catch
	end
end
else
if(@accion = 'consultar_inventario')
begin
	select ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	punto_corte.nombre_punto_corte,
	sum(unidades_por_pieza) as cantidad_tallos,
	datediff(dd, min(pieza_postcosecha.fecha_entrada), getdate()) as dias
	from pieza_postcosecha,
	punto_corte,
	variedad_flor
	where not exists
	(
		select * from salida_pieza
		where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha
	)
	and variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
	and pieza_postcosecha.id_punto_corte = punto_corte.id_punto_corte
	group by ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	punto_corte.nombre_punto_corte
	order by ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	punto_corte.nombre_punto_corte
end