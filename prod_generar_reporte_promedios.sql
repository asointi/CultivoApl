set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_promedios]

@accion nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime,
@id_variedad_flor nvarchar(255),
@id_punto_corte nvarchar(255)

as

set @fecha_inicial = @fecha_final - 25

if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'

if(@id_punto_corte is null)
	set @id_punto_corte = '%%'

if(@accion = 'consultar')
begin
	select tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte + space(1) + '(' + idc_punto_corte + ')' as nombre_punto_corte,
	convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion,101)) as fecha,
	count(tallo_clasificado.id_tallo_clasificado) as cantidad_tallos,
	avg(tallo_clasificado.largo) as largo,
	avg(tallo_clasificado.ancho) as ancho,
	avg(tallo_clasificado.alto_cabeza) as alto_cabeza,
	avg(tallo_clasificado.apertura) as apertura
	from tallo_clasificado, 
	tiempo_ejecucion_detalle_condicion,
	tiempo_ejecucion_regla,
	regla,
	tipo_flor,
	variedad_flor,
	punto_corte
	where tallo_clasificado.id_tiempo_ejecucion_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and regla.id_regla = tiempo_ejecucion_regla.id_regla
	and regla.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and punto_corte.id_punto_corte = regla.id_punto_corte
	and convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion,101)) between
	@fecha_inicial and @fecha_final
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and punto_corte.id_punto_corte like @id_punto_corte
	group by tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte,
	idc_punto_corte,
	regla.nombre_regla,
	convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion,101))
end