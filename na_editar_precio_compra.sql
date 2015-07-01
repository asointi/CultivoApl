SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_precio_compra]

@accion nvarchar(255),
@id_precio_compra int,
@id_farm int, 
@id_variedad_flor int, 
@id_grado_flor int, 
@valor decimal(20,4), 
@unidades_por_pieza int

as

/*codigo de plantas y flores en Natural*/
--select @id_farm = id_farm
--from farm 
--where farm.idc_farm = 'JI'
--
/*codigo de plantas y flores en Fresca*/
select @id_farm = id_farm
from farm 
where farm.idc_farm = 'PF'

if(@accion = 'insertar')
begin
	declare @conteo int,
	@id_precio_compra_aux int

	select @conteo = count(*)
	from precio_compra
	where id_farm = @id_farm
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor

	if(@conteo = 0)
	begin
		insert into precio_compra (id_farm, id_variedad_flor, id_grado_flor, valor, unidades_por_pieza)
		values (@id_farm, @id_variedad_flor, @id_grado_flor, @valor, @unidades_por_pieza)

		set @id_precio_compra_aux = scope_identity()

		select @id_precio_compra_aux as id_precio_compra
	end
	else
	begin
		select -1 as id_precio_compra
	end
end
else
if(@accion = 'modificar')
begin
	update precio_compra
	set valor = @valor,
	unidades_por_pieza = @unidades_por_pieza 
	where id_precio_compra = @id_precio_compra
end
else
if(@accion = 'eliminar')
begin
	delete from precio_compra
	where id_precio_compra = @id_precio_compra
end
else
if(@accion = 'consultar')
begin
	select precio_compra.id_precio_compra,
	'[' + farm.idc_farm + ']' + space(1) + ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	'[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	'[' + variedad_flor.idc_variedad_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	'[' + grado_flor.idc_grado_flor + ']' + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	precio_compra.valor,
	precio_compra.unidades_por_pieza
	from precio_compra,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = precio_compra.id_variedad_flor
	and grado_flor.id_grado_flor = precio_compra.id_grado_flor
	and farm.id_farm = precio_compra.id_farm
	order by farm.idc_farm,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor
end