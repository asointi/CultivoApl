set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/10/20
-- Description:	Maneja informacion de los creditos de las fincas
-- =============================================

create PROCEDURE [dbo].[na_editar_credito_farm_flor_version2] 

@idc_guia nvarchar(30), 
@idc_farm nvarchar(2), 
@idc_tipo_flor nvarchar(2), 
@idc_variedad_flor nvarchar(2), 
@idc_grado_flor nvarchar(2), 
@fecha_credito_farm_flor datetime, 
@valor_credito_farm_flor decimal(20,4),
@accion nvarchar(50),
@fecha_inicial datetime,
@fecha_final datetime,
@id_causa_credito_farm int

as

if(@accion = 'insertar')
begin
	insert into credito_farm_flor (id_guia, id_farm, id_variedad_flor, id_grado_flor, fecha_credito_farm_flor, valor_credito_farm_flor, id_causa_credito_farm)
	select guia.id_guia,
	farm.id_farm,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	@fecha_credito_farm_flor, 
	@valor_credito_farm_flor,
	@id_causa_credito_farm
	from guia,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor
	where guia.idc_guia = @idc_guia
	and farm.idc_farm = @idc_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
end
else
if(@accion = 'consultar')
begin
	select credito_farm_flor.id_credito_farm_flor,
	guia.idc_guia,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	credito_farm_flor.fecha_credito_farm_flor,
	credito_farm_flor.valor_credito_farm_flor,
	causa_credito_farm.id_causa_credito_farm,
	causa_credito_farm.nombre_causa_credito_farm
	from credito_farm_flor,
	causa_credito_farm,
	guia,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor
	where guia.id_guia = credito_farm_flor.id_guia
	and farm.id_farm = credito_farm_flor.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = credito_farm_flor.id_variedad_flor
	and grado_flor.id_grado_flor = credito_farm_flor.id_grado_flor
	and causa_credito_farm.id_causa_credito_farm = credito_farm_flor.id_causa_credito_farm
	and credito_farm_flor.fecha_credito_farm_flor between
	@fecha_inicial and @fecha_final
	and causa_credito_farm.id_causa_credito_farm > =
	case
		when @id_causa_credito_farm = 0 then 0
		else @id_causa_credito_farm
	end
	and causa_credito_farm.id_causa_credito_farm < =
	case
		when @id_causa_credito_farm = 0 then 999999
		else @id_causa_credito_farm
	end
	order by fecha_credito_farm_flor,
	farm.idc_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	causa_credito_farm.nombre_causa_credito_farm
end