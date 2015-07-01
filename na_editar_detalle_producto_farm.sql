SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_editar_detalle_producto_farm]

@accion nvarchar(50),
@idc_farm nvarchar(5),
@idc_tapa nvarchar(5),
@idc_tipo_flor nvarchar(5),
@idc_caja nvarchar(5),
@idc_grado_flor nvarchar(5),
@unidades_por_pieza int

as

declare @id_farm int,
@id_tapa int,
@id_tipo_flor int,
@id_caja int,
@id_grado_flor int,
@conteo int 	

select @id_farm = farm.id_farm
from farm
where farm.idc_farm = @idc_farm

select @id_tapa = tapa.id_tapa
from tapa
where tapa.idc_tapa = @idc_tapa

select @id_tipo_flor = tipo_flor.id_tipo_flor
from tipo_flor
where tipo_flor.idc_tipo_flor = @idc_tipo_flor

select @id_grado_flor = grado_flor.id_grado_flor
from grado_flor,
tipo_flor
where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor

select @id_caja = caja.id_caja
from tipo_caja, caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja

if(@accion = 'consultar')
begin
	select farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	tapa.idc_tapa,
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
	tipo_caja.idc_tipo_caja+caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	detalle_producto_farm.unidades_por_pieza
	from detalle_producto_farm,
	farm,
	tipo_flor,
	grado_flor,
	tapa,
	caja,
	tipo_caja
	where farm.id_farm = detalle_producto_farm.id_farm
	and tipo_flor.id_tipo_flor = detalle_producto_farm.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.id_grado_flor = detalle_producto_farm.id_grado_flor
	and tapa.id_tapa = detalle_producto_farm.id_tapa
	and caja.id_caja = detalle_producto_farm.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and farm.idc_farm > =
	case
		when @idc_farm = '' then '  '
		else @idc_farm
	end
	and farm.idc_farm < =
	case
		when @idc_farm = '' then 'ZZ'
		else @idc_farm
	end
	and tapa.idc_tapa > = 
	case
		when @idc_tapa = '' then '  '
		else @idc_tapa
	end
	and tapa.idc_tapa < = 
	case
		when @idc_tapa = '' then 'ZZ'
		else @idc_tapa
	end
	and tipo_flor.idc_tipo_flor > = 
	case
		when @idc_tipo_flor = '' then '  '
		else @idc_tipo_flor
	end
	and tipo_flor.idc_tipo_flor < = 
	case
		when @idc_tipo_flor = '' then 'ZZ'
		else @idc_tipo_flor
	end
	and grado_flor.idc_grado_flor > = 
	case
		when @idc_grado_flor = '' then '  '
		else @idc_grado_flor
	end
	and grado_flor.idc_grado_flor < = 
	case
		when @idc_grado_flor = '' then 'ZZ'
		else @idc_grado_flor
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja > =
	case
		when @idc_caja = '' then '  '
		else @idc_caja
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja < =
	case
		when @idc_caja = '' then 'ZZ'
		else @idc_caja
	end
	order by farm.idc_farm,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor,
	caja.idc_caja,
	tapa.idc_tapa
end
else
if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from detalle_producto_farm
	where detalle_producto_farm.id_farm = @id_farm
	and detalle_producto_farm.id_tapa = @id_tapa
	and detalle_producto_farm.id_tipo_flor = @id_tipo_flor
	and detalle_producto_farm.id_caja = @id_caja
	and detalle_producto_farm.id_grado_flor = @id_grado_flor

	if(@conteo < 1)
	begin
		insert into detalle_producto_farm (id_farm, id_tapa, id_tipo_flor, id_caja, id_grado_flor, unidades_por_pieza)
		values (@id_farm, @id_tapa, @id_tipo_flor, @id_caja, @id_grado_flor, @unidades_por_pieza)
	
		select 1 as resultado
	end
	else
	begin
		select -1 as resultado
	end
end
else
if(@accion = 'eliminar')
begin
	delete from detalle_producto_farm
	where id_farm = @id_farm
	and id_tipo_flor = @id_tipo_flor
	and id_tapa = @id_tapa
	and id_caja = @id_caja
	and id_grado_flor = @id_grado_flor
end