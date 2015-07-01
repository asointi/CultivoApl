set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_trasladar_produccion_solicitada]

@fecha_inicial datetime,
@fecha_final datetime,
@id_bloque nvarchar(255), 
@id_tipo_flor nvarchar(255), 
@id_variedad_flor nvarchar(255), 
@id_grado_flor nvarchar(255), 
@id_tipo_pedido nvarchar(255),
@accion nvarchar(255)

as

if(@id_bloque is null)
	set @id_bloque = '%%'

if(@id_tipo_flor is null)
	set @id_tipo_flor = '%%' 

if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'

if(@id_grado_flor is null)
	set @id_grado_flor = '%%'

if(@id_tipo_pedido is null)
	set @id_tipo_pedido = '%%'

if(@accion = 'consultar')
begin
	select produccion_solicitada_rusia.id_produccion_solicitada_rusia,
	bloque.id_bloque,
	bloque.idc_bloque,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	tipo_pedido.id_tipo_pedido,
	'[' + tipo_pedido.idc_tipo_pedido + ']' + space(1) + tipo_pedido.nombre_tipo_pedido as nombre_tipo_pedido,
	tipo_flor.idc_tipo_flor as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha,101)) as fecha,
	cantidad_tallos,
	descripcion_produccion_solicitada.comentario	
	from produccion_solicitada_rusia left join comentario_produccion_solicitada on produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia
	left join descripcion_produccion_solicitada on comentario_produccion_solicitada.id_descripcion_produccion_solicitada = descripcion_produccion_solicitada.id_descripcion_produccion_solicitada,
	bloque,
	variedad_flor,
	tipo_flor,
	grado_flor,
	tipo_pedido	
	where convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha,101)) > = convert(datetime,convert(nvarchar,@fecha_inicial,101))
	and convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha,101)) < = convert(datetime,convert(nvarchar,@fecha_final,101))
	and produccion_solicitada_rusia.id_bloque = bloque.id_bloque
	and produccion_solicitada_rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	and produccion_solicitada_rusia.disponible = 1
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and grado_flor.id_grado_flor like @id_grado_flor
	and bloque.id_bloque like @id_bloque
	and tipo_pedido.id_tipo_pedido like @id_tipo_pedido
	order by fecha,
	bloque.idc_bloque,	
	nombre_tipo_flor,
	nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tipo_pedido.idc_tipo_pedido
end