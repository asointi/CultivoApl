SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_tipo_conteo]

@accion NVARCHAR(255),
@id_tipo_conteo int

AS

if(@accion = 'consultar')
begin
	select id_tipo_conteo_propietario_cama as id_tipo_conteo,
	nombre 
	from tipo_conteo_propietario_cama
	order by nombre
end
else
if(@accion = 'modificar')
begin
	update configuracion_bd
	set id_tipo_conteo = @id_tipo_conteo
end
else
if(@accion = 'consultar_tipo_conteo_actual')
begin
	select id_tipo_conteo_propietario_cama as id_tipo_conteo,
	nombre 
	from tipo_conteo_propietario_cama,
	configuracion_bd
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = configuracion_bd.id_tipo_conteo
end	