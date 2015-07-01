set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/01
-- Description:	Maneja informacion de la clasificacion de flor sin bonchar
-- =============================================

alter PROCEDURE [dbo].[na_editar_clasificacion_sin_bonchar] 

@accion nvarchar(50),
@usuario_cobol nvarchar(50),
@id_clasificacion_sin_bonchar int, 
@unidades int,
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@idc_grado_flor nvarchar(2),
@numero_packing_list nvarchar(7),
@fecha_inicial datetime = null,
@fecha_final datetime = null,
@idc_tipo_flor_final nvarchar(2) = null,
@idc_finca nvarchar(2) = null

as

if(@accion = 'consultar')
begin
	select clasificacion_sin_bonchar.id_clasificacion_sin_bonchar,
	clasificacion_sin_bonchar.fecha_transaccion,
	clasificacion_sin_bonchar.usuario_cobol,
	isnull(clasificacion_sin_bonchar.numero_packing_list, '') as numero_packing_list,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca,
	sum(detalle_clasificacion_sin_bonchar.unidades) as unidades
	from clasificacion_sin_bonchar,
	detalle_clasificacion_sin_bonchar,
	estado_clasificacion_sin_bonchar,
	tipo_flor,
	variedad_flor,
	grado_flor,
	finca
	where clasificacion_sin_bonchar.id_clasificacion_sin_bonchar = detalle_clasificacion_sin_bonchar.id_clasificacion_sin_bonchar
	and estado_clasificacion_sin_bonchar.id_estado_clasificacion_sin_bonchar = clasificacion_sin_bonchar.id_estado_clasificacion_sin_bonchar
	and estado_clasificacion_sin_bonchar.nombre_estado = 'Activa'
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_clasificacion_sin_bonchar.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_clasificacion_sin_bonchar.id_grado_flor
	and finca.id_finca = clasificacion_sin_bonchar.id_finca
	and tipo_flor.idc_tipo_flor > =
	case
		when @idc_tipo_flor = '' then '  '
		else @idc_tipo_flor
	end
	and tipo_flor.idc_tipo_flor < =
	case
		when @idc_tipo_flor_final = '' then 'ZZ'
		else @idc_tipo_flor_final
	end
	and convert(datetime,convert(nvarchar, clasificacion_sin_bonchar.fecha_transaccion, 101)) between
	@fecha_inicial and @fecha_final
	group by clasificacion_sin_bonchar.id_clasificacion_sin_bonchar,
	clasificacion_sin_bonchar.fecha_transaccion,
	clasificacion_sin_bonchar.usuario_cobol,
	isnull(clasificacion_sin_bonchar.numero_packing_list, ''),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca))
	order by tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca))
end
else
if(@accion = 'insertar_encabezado')
begin
	insert into clasificacion_sin_bonchar (usuario_cobol, id_estado_clasificacion_sin_bonchar, id_finca)
	select @usuario_cobol,
	estado_clasificacion_sin_bonchar.id_estado_clasificacion_sin_bonchar,
	finca.id_finca
	from estado_clasificacion_sin_bonchar,
	finca
	where estado_clasificacion_sin_bonchar.nombre_estado = 'Activa'	
	and finca.idc_finca = @idc_finca

	select scope_identity() as id_clasificacion_sin_bonchar
end
else
if(@accion = 'insertar_detalle')
begin
	insert into detalle_clasificacion_sin_bonchar (id_grado_flor, id_variedad_flor,	id_clasificacion_sin_bonchar, unidades)
	select grado_flor.id_grado_flor,
	variedad_flor.id_variedad_flor,
	@id_clasificacion_sin_bonchar, 
	@unidades
	from tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
end
else
if(@accion = 'actualizar_packing_list')
begin
	update clasificacion_sin_bonchar
	set numero_packing_list = @numero_packing_list
	where id_clasificacion_sin_bonchar = @id_clasificacion_sin_bonchar
end
else
if(@accion = 'anular_packing_list')
begin
	update clasificacion_sin_bonchar
	set id_estado_clasificacion_sin_bonchar = estado_clasificacion_sin_bonchar.id_estado_clasificacion_sin_bonchar
	from estado_clasificacion_sin_bonchar	
	where clasificacion_sin_bonchar.numero_packing_list = @numero_packing_list
	and estado_clasificacion_sin_bonchar.nombre_estado = 'Cancelada'
end