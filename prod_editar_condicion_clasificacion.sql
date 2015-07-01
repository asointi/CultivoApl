set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_condicion_clasificacion]

@accion nvarchar(255),
@id_grado_flor int,
@id_grupo_clasificacion nvarchar(255),
@longitud_minima decimal(20,4),
@ancho_tallo_minimo decimal(20,4),
@alto_cabeza_minimo decimal(20,4),
@id_tipo_flor nvarchar(255),
@tolerancia_largo decimal(20,4),
@tolerancia_ancho_tallo decimal(20,4),
@tolerancia_alto decimal(20,4),
@@control int output

as

if(@id_tipo_flor is null)
	set @id_tipo_flor = '%%'

if(@id_grupo_clasificacion is null)
	set @id_grupo_clasificacion = '%%'

if(@accion = 'insertar')
begin
	declare @conteo int
	select @conteo = count(*) 
	from condicion_clasificacion where id_grado_flor = @id_grado_flor
	and id_grupo_clasificacion = convert(int,@id_grupo_clasificacion)
	
	if (@conteo = 0)
	begin
		insert into condicion_clasificacion (id_grado_flor, id_grupo_clasificacion, longitud_minima, ancho_tallo_minimo, alto_cabeza_minimo)
		values (@id_grado_flor, convert(int,@id_grupo_clasificacion), @longitud_minima, @ancho_tallo_minimo, @alto_cabeza_minimo)
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'consultar')
begin
	select condicion_clasificacion.id_condicion_clasificacion,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '(' + grado_flor.idc_grado_flor + ')' as nombre_grado_flor,
	grupo_clasificacion.id_grupo_clasificacion,
	grupo_clasificacion.nombre_grupo_clasificacion + space(1) + '(' + punto_corte.nombre_punto_corte + ')' as nombre_grupo_clasificacion,
	condicion_clasificacion.id_grado_flor,
	condicion_clasificacion.longitud_minima,
	condicion_clasificacion.ancho_tallo_minimo,
	condicion_clasificacion.alto_cabeza_minimo
	from condicion_clasificacion,
	grado_flor,
	tipo_flor,
	grupo_clasificacion,
	variedad_flor,
	grupo_variedad_clasificacion,
	punto_corte
	where condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
	and grupo_clasificacion.id_punto_corte = punto_corte.id_punto_corte
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and condicion_clasificacion.id_grupo_clasificacion = grupo_clasificacion.id_grupo_clasificacion
	and grupo_clasificacion.id_grupo_clasificacion like @id_grupo_clasificacion
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = grupo_variedad_clasificacion.id_variedad_flor
	and grupo_clasificacion.id_grupo_clasificacion = grupo_variedad_clasificacion.id_grupo_clasificacion
	group by condicion_clasificacion.id_condicion_clasificacion,
	grado_flor.nombre_grado_flor,
	grado_flor.idc_grado_flor,
	grupo_clasificacion.id_grupo_clasificacion,
	grupo_clasificacion.nombre_grupo_clasificacion,
	punto_corte.nombre_punto_corte,
	condicion_clasificacion.id_grado_flor,
	condicion_clasificacion.longitud_minima,
	condicion_clasificacion.ancho_tallo_minimo,
	condicion_clasificacion.alto_cabeza_minimo
	order by grupo_clasificacion.nombre_grupo_clasificacion,
	condicion_clasificacion.id_grado_flor,
	condicion_clasificacion.longitud_minima,
	condicion_clasificacion.ancho_tallo_minimo,
	condicion_clasificacion.alto_cabeza_minimo
end
else
if(@accion = 'modificar')
begin
	update condicion_clasificacion
	set longitud_minima = @longitud_minima,
	ancho_tallo_minimo = @ancho_tallo_minimo,
	alto_cabeza_minimo = @alto_cabeza_minimo,
	fecha_transaccion = getdate()
	where id_grado_flor = @id_grado_flor
	and id_grupo_clasificacion = @id_grupo_clasificacion
end
else
if(@accion = 'consultar_tolerancia')
begin
	select tolerancia_largo,
	tolerancia_ancho_tallo,
	tolerancia_alto
	from globales_sql
end
else
if(@accion = 'actualizar_tolerancia')
begin
	update globales_sql
	set tolerancia_largo = @tolerancia_largo,
	tolerancia_ancho_tallo = @tolerancia_ancho_tallo,
	tolerancia_alto = @tolerancia_alto
end