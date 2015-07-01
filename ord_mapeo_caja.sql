set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_mapeo_caja]

@id_mapeo_flor int,
@id_mapeo_caja int,
@id_caja int,
@nombre_mapeo_pack nvarchar(255),
@nombre_mapeo_box_type nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select caja.id_caja, 
	caja.nombre_caja + space(1) + '[' + tipo_caja.idc_tipo_caja + caja.idc_caja + ']' as nombre_caja, 
	mapeo_caja.id_mapeo_caja
	from mapeo_caja, 
	caja, 
	tipo_caja
	where isnull(nombre_mapeo_pack,'') = isnull(@nombre_mapeo_pack,'')
	and isnull(nombre_mapeo_box_type,'') = isnull(@nombre_mapeo_box_type,'')
	and id_mapeo_flor = @id_mapeo_flor
	and caja.id_caja = mapeo_caja.id_caja
	and caja.disponible = 1
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	order by caja.nombre_caja, 
	tipo_caja.idc_tipo_caja,
	caja.idc_caja
end
else
if(@accion = 'insertar')
begin
	declare @conteo int

	select @conteo = count(*)
	from mapeo_caja
	where mapeo_caja.id_caja = @id_caja
	and mapeo_caja.id_mapeo_flor = @id_mapeo_flor
	and isnull(mapeo_caja.nombre_mapeo_pack,'') = isnull(@nombre_mapeo_pack,'')

	if(@conteo = 0)
	begin
		insert into mapeo_caja (id_caja, id_mapeo_flor, nombre_mapeo_pack, nombre_mapeo_box_type)
		values (@id_caja, @id_mapeo_flor, @nombre_mapeo_pack, @nombre_mapeo_box_type)

		return scope_identity()
	end
	else
		return -1
end
else
if(@accion = 'modificar')
begin
	update mapeo_caja
	set id_caja = @id_caja
	where id_mapeo_caja = @id_mapeo_caja
end
else
if(@accion = 'eliminar')
begin
	delete mapeo_caja
	where id_mapeo_caja = @id_mapeo_caja
end