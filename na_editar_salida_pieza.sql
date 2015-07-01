set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_salida_pieza]

@accion nvarchar(255),
@idc_pieza_postcosecha nvarchar(255),
@fecha nvarchar(255),
@hora nvarchar(255)

AS

declare @conteo int 

if(@accion = 'insertar')
begin
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

	select @conteo = count(*)
	from pieza_postcosecha,
	salida_pieza
	where salida_pieza.id_pieza_postcosecha = pieza_postcosecha.id_pieza_postcosecha
	and pieza_postcosecha.idc_pieza_postcosecha = @idc_pieza_postcosecha

	if(@conteo = 0)
	begin
		insert into salida_pieza (id_pieza_postcosecha, fecha_salida)
		select pieza_postcosecha.id_pieza_postcosecha, (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME))
		from pieza_postcosecha
		where pieza_postcosecha.idc_pieza_postcosecha = @idc_pieza_postcosecha

		insert into log_info (mensaje, tipo_mensaje)
		values ('pieza postcosecha: ' + @idc_pieza_postcosecha + ', fecha: ' + @fecha + ', hora: ' + @hora, 'insercion salida pieza')
	end
	else
	begin
		insert into log_info (mensaje, tipo_mensaje)
		values ('pieza postcosecha: ' + @idc_pieza_postcosecha + ', fecha: ' + @fecha + ', hora: ' + @hora, 'NO insercion salida pieza')
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