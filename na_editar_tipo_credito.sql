alter PROCEDURE [dbo].[na_editar_tipo_credito]

@id_tipo_credito int,
@accion nvarchar(255),
@descripcion nvarchar(1024),
@descripcion_español nvarchar(1024) = null

AS

if(@accion = 'consultar')
begin
	select id_tipo_credito,
	idc_tipo_credito,
	ltrim(rtrim(nombre_tipo_credito)) as nombre_tipo_credito,
	'[' + idc_tipo_credito + ']' + space(4) + ltrim(rtrim(nombre_tipo_credito)) as nombre_completo_tipo_credito,
	ltrim(rtrim(descripcion)) as descripcion,
	ltrim(rtrim(descripcion_español)) as descripcion_espanol
	from tipo_credito
	order by nombre_tipo_credito
end
else
if(@accion = 'actualizar')
begin
	update tipo_credito
	set descripcion = @descripcion,
	descripcion_español = @descripcion_español
	where id_tipo_credito = @id_tipo_credito
end