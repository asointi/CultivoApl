set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_lectura_kuehne_nagel]

@idc_pieza nvarchar(max),
@accion nvarchar(255) 

AS

if(@accion = 'insertar')
begin
	delete from Archivo_Kuehne_Nagel
	
	insert into Archivo_Kuehne_Nagel (idc_pieza)
	select * 
	from dbo.separacion_cadena(@idc_pieza,+',')
end
else
if(@accion = 'consultar')
begin
	select guia.idc_guia,
	ltrim(rtrim(farm.nombre_farm)) + ' [' + farm.idc_farm + ']' as nombre_farm,
	count(pieza.id_pieza) as cantidad_piezas,
	sum(tipo_caja.factor_a_full) as fulles
	from Archivo_Kuehne_Nagel,
	pieza,
	guia,
	farm,
	caja,
	tipo_caja
	where Archivo_Kuehne_Nagel.idc_pieza = pieza.idc_pieza
	and guia.id_guia = pieza.id_guia
	and farm.id_farm = pieza.id_farm
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	group by guia.idc_guia,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm))
	union all
	select 'Without AWB',
	ltrim(rtrim(farm.nombre_farm)) + ' [' + farm.idc_farm + ']' as nombre_farm,
	count(etiqueta.codigo) as cantidad_piezas,
	sum(tipo_caja.factor_a_full) as fulles
	from Archivo_Kuehne_Nagel,
	etiqueta,
	farm,
	caja,
	tipo_caja
	where Archivo_Kuehne_Nagel.idc_pieza = etiqueta.codigo
	and farm.idc_farm = etiqueta.farm
	and tipo_caja.idc_tipo_caja + caja.idc_caja = etiqueta.tipo_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and not exists
	(
		select *
		from pieza
		where pieza.idc_pieza = etiqueta.codigo
	)
	group by farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm))
	order by guia.idc_guia,
	nombre_farm
end
else
if(@accion = 'consultar_errados')
begin
	select Archivo_Kuehne_Nagel.idc_pieza
	from Archivo_Kuehne_Nagel
	where not exists
	(
		select *
		from pieza
		where Archivo_Kuehne_Nagel.idc_pieza = pieza.idc_pieza
	)
	and not exists
	(
		select *
		from etiqueta
		where Archivo_Kuehne_Nagel.idc_pieza = etiqueta.codigo
	)
end