set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/30
-- Description:	Maneja informacion de las flores del cultivo en la comercializadora
-- =============================================

alter PROCEDURE [dbo].[bouquet_consultar_flor] 

@accion nvarchar(255),
@id_tipo_flor_cultivo int

as

if(@accion = 'consultar_tipo_flor')
begin
	select tipo_flor_cultivo.id_tipo_flor_cultivo,
	tipo_flor_cultivo.idc_tipo_flor,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) as nombre_tipo_flor,
	tipo_flor_cultivo.disponible_comercializadora
	from tipo_flor_cultivo
	where disponible = 1
	and bouquet = 0
	order by nombre_tipo_flor
end
else
if(@accion = 'consultar_variedad_flor')
begin
	select variedad_flor_cultivo.id_variedad_flor_cultivo,
	variedad_flor_cultivo.idc_variedad_flor,
	ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) as nombre_variedad_flor,
	variedad_flor_cultivo.disponible_comercializadora
	from variedad_flor_cultivo,
	tipo_flor_cultivo
	where variedad_flor_cultivo.disponible = 1
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = @id_tipo_flor_cultivo
	order by nombre_variedad_flor
end
else
if(@accion = 'consultar_grado_flor')
begin
	select grado_flor_cultivo.id_grado_flor_cultivo,
	grado_flor_cultivo.idc_grado_flor,
	ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_grado_flor,
	grado_flor_cultivo.disponible_comercializadora
	from grado_flor_cultivo,
	tipo_flor_cultivo
	where grado_flor_cultivo.disponible = 1
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = @id_tipo_flor_cultivo
	order by nombre_grado_flor
end
else
if(@accion = 'consultar_todos')
begin
	select identity(int, 1,1) as id,
	tipo_flor_cultivo.id_tipo_flor_cultivo,
	tipo_flor_cultivo.idc_tipo_flor,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor_cultivo.id_variedad_flor_cultivo,
	variedad_flor_cultivo.idc_variedad_flor,
	ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor_cultivo.id_grado_flor_cultivo,
	grado_flor_cultivo.idc_grado_flor,
	ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_grado_flor into #todas_flores
	from tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo
	where tipo_flor_cultivo.disponible = 1
	and tipo_flor_cultivo.bouquet = 0
	and tipo_flor_cultivo.disponible_comercializadora = 1
	and variedad_flor_cultivo.disponible = 1
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.disponible_comercializadora = 1
	and grado_flor_cultivo.disponible = 1
	and grado_flor_cultivo.disponible_comercializadora = 1
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	order by nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor

	select *
	from #todas_flores
	order by id

	drop table #todas_flores
end