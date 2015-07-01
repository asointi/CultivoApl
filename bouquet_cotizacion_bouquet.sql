set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/09
-- Description:	Administra la informacion de cotizaciones de bouquets en el cultivo
-- =============================================

alter PROCEDURE [dbo].[bouquet_cotizacion_bouquet] 

@id_tipo_flor int,
@id_variedad_flor int,
@id_grado_flor int,
@id_finca int,
@id_cuenta_interna int,
@costo_unitario decimal(20,4),
@fecha_inicial datetime,
@fecha_final datetime,
@accion nvarchar(255),
@id_cotizacion_bouquet int = null

as

if(@accion = 'consultar')
begin
	select cotizacion_bouquet.id_cotizacion_bouquet,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	finca.id_finca,
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca,
	convert(decimal(20,3), cotizacion_bouquet.costo_unitario) as costo_unitario,
	cotizacion_bouquet.fecha_inicial,
	cotizacion_bouquet.fecha_final,
	cuenta_interna.id_cuenta_interna,
	cuenta_interna.nombre as nombre_cuenta_interna,
	isnull((
		select deshabilita_cotizacion_bouquet.id_deshabilita_cotizacion_bouquet 
		from deshabilita_cotizacion_bouquet
		where cotizacion_bouquet.id_cotizacion_bouquet = deshabilita_cotizacion_bouquet.id_cotizacion_bouquet
	), 0) as estado
	from cotizacion_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor,
	finca,
	cuenta_interna
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = cotizacion_bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = cotizacion_bouquet.id_grado_flor
	and finca.id_finca = cotizacion_bouquet.id_finca
	and cuenta_interna.id_cuenta_interna = cotizacion_bouquet.id_cuenta_interna
	and tipo_flor.id_tipo_flor > =
	case
		when @id_tipo_flor = 0 then 1
		else @id_tipo_flor
	end
	and tipo_flor.id_tipo_flor < =
	case
		when @id_tipo_flor = 0 then 99999
		else @id_tipo_flor
	end
	and variedad_flor.id_variedad_flor > =
	case
		when @id_variedad_flor = 0 then 1
		else @id_variedad_flor
	end
	and variedad_flor.id_variedad_flor < =
	case
		when @id_variedad_flor = 0 then 99999
		else @id_variedad_flor
	end
	and grado_flor.id_grado_flor > =
	case
		when @id_grado_flor = 0 then 1
		else @id_grado_flor
	end
	and grado_flor.id_grado_flor < =
	case
		when @id_grado_flor = 0 then 99999
		else @id_grado_flor
	end
	and finca.id_finca > =
	case
		when @id_finca = 0 then 1
		else @id_finca
	end
	and finca.id_finca < =
	case
		when @id_finca = 0 then 99999
		else @id_finca
	end
	order by cotizacion_bouquet.id_cotizacion_bouquet desc
end
else
if(@accion = 'insertar')
begin
	insert into cotizacion_bouquet (id_grado_flor, id_variedad_flor, id_finca, id_cuenta_interna, costo_unitario, fecha_inicial, fecha_final)
	values (@id_grado_flor, @id_variedad_flor, @id_finca, @id_cuenta_interna, @costo_unitario, @fecha_inicial, @fecha_final)
end
else
if(@accion = 'deshabilitar')
begin
	insert into deshabilita_cotizacion_bouquet (id_cotizacion_bouquet, id_cuenta_interna)
	values (@id_cotizacion_bouquet, @id_cuenta_interna)
end