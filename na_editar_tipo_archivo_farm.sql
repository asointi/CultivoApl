set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_tipo_archivo_farm]

@accion nvarchar(255),
@id_tipo_archivo int,
@id_farm int

as

if(@accion = 'consultar_farm')
begin
	select farm.id_farm,
	ltrim(rtrim(nombre_farm)) + space(1) + '[' + idc_farm + ']' as nombre_farm,
	tipo_archivo.id_tipo_archivo,
	tipo_archivo.nombre_tipo_archivo,
	tipo_archivo.formato
	from farm left join tipo_archivo on tipo_archivo.id_tipo_archivo = farm.id_tipo_archivo
	where farm.disponible = 1
	order by nombre_farm
end
else
if(@accion = 'consultar_tipo_archivo')
begin
	select tipo_archivo.id_tipo_archivo,
	tipo_archivo.nombre_tipo_archivo,
	tipo_archivo.formato
	from tipo_archivo
	order by tipo_archivo.nombre_tipo_archivo
end
else
if(@accion = 'actualizar_tipo_archivo_farm')
begin
	update farm
	set id_tipo_archivo = @id_tipo_archivo
	where id_farm = @id_farm
end