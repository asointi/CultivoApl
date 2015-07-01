set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_consultar_modificar_disponibles_distribuidora]

@nombre_tabla nvarchar(255),
@disponible bit,
@id_cuenta_interna int,
@id_item nvarchar(255),
@nombre_item nvarchar(255),
@accion nvarchar(255)

as

set @nombre_item = '%' + @nombre_item + '%'

if(@accion = 'consultar')
begin

	if(@nombre_item is null)
		set @nombre_item = '%%'

	if(@id_item is null)
		set @id_item = '%%'

	if(@nombre_tabla = 'tapa')
	begin
		select tapa.id_tapa,
		tapa.idc_tapa, 
		tapa.nombre_tapa,
		ltrim(rtrim(tapa.nombre_tapa))+space(1)+'['+tapa.idc_tapa+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		tapa.disponible
		from tapa left join cuenta_interna on  tapa.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where tapa.disponible = @disponible
		and tapa.nombre_tapa like @nombre_item
		order by tapa.nombre_tapa
	end 
	else
	if(@nombre_tabla = 'tipo_caja')
	begin
		select tipo_caja.id_tipo_caja,
		tipo_caja.idc_tipo_caja, 
		tipo_caja.nombre_tipo_caja,
		ltrim(rtrim(tipo_caja.nombre_tipo_caja))+space(1)+'['+tipo_caja.idc_tipo_caja+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		tipo_caja.disponible
		from tipo_caja left join cuenta_interna on  tipo_caja.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where tipo_caja.disponible = @disponible
		and tipo_caja.nombre_tipo_caja like @nombre_item
		order by tipo_caja.nombre_tipo_caja
	end 
	else
	if(@nombre_tabla = 'caja')
	begin
		select caja.id_caja,
		tipo_caja.idc_tipo_caja+caja.idc_caja as idc_caja, 
		caja.nombre_caja,
		ltrim(rtrim(caja.nombre_caja))+space(1)+'['+tipo_caja.idc_tipo_caja+caja.idc_caja+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		caja.disponible
		from tipo_caja,caja left join cuenta_interna on  caja.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where caja.disponible = @disponible
		and caja.nombre_caja like @nombre_item
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and tipo_caja.id_tipo_caja like @id_item
		order by caja.nombre_caja
	end 
	else
	if(@nombre_tabla = 'cliente_factura')
	begin
		select cliente_despacho.id_despacho as id_cliente_factura,
		cliente_despacho.*,
		cliente_despacho.idc_cliente_despacho, 
		cliente_despacho.nombre_cliente,
		ltrim(rtrim(cliente_despacho.nombre_cliente))+space(1)+'['+cliente_despacho.idc_cliente_despacho+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		cliente_despacho.disponible
		from cliente_despacho left join cuenta_interna on  cliente_despacho.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where cliente_despacho.disponible = @disponible
		and cliente_despacho.nombre_cliente like @nombre_item
		order by cliente_despacho.nombre_cliente,
		cliente_despacho.idc_cliente_despacho
	end 
	else
	if(@nombre_tabla = 'tipo_flor')
	begin
		select tipo_flor.id_tipo_flor,
		tipo_flor.idc_tipo_flor, 
		tipo_flor.nombre_tipo_flor,
		ltrim(rtrim(tipo_flor.nombre_tipo_flor))+space(1)+'['+tipo_flor.idc_tipo_flor+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		tipo_flor.disponible
		from tipo_flor left join cuenta_interna on  tipo_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where tipo_flor.disponible = @disponible
		and tipo_flor.nombre_tipo_flor like @nombre_item
		order by tipo_flor.nombre_tipo_flor
	end 
	else
	if(@nombre_tabla = 'variedad_flor')
	begin
		select variedad_flor.id_variedad_flor,
		tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor as idc_variedad_flor, 
		variedad_flor.nombre_variedad_flor,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor))+space(1)+'['+tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		variedad_flor.disponible
		from tipo_flor,variedad_flor left join cuenta_interna on  variedad_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where variedad_flor.disponible = @disponible
		and variedad_flor.nombre_variedad_flor like @nombre_item
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor like @id_item
		order by variedad_flor.nombre_variedad_flor
	end 
	else
	if(@nombre_tabla = 'grado_flor')
	begin
		select grado_flor.id_grado_flor,
		tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor as idc_grado_flor, 
		grado_flor.nombre_grado_flor,
		ltrim(rtrim(grado_flor.nombre_grado_flor))+space(1)+'['+tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		grado_flor.disponible
		from tipo_flor,
		grado_flor left join cuenta_interna on  grado_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where grado_flor.disponible = @disponible
		and grado_flor.nombre_grado_flor like @nombre_item
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor like @id_item
		order by grado_flor.nombre_grado_flor
	end
	else
	if(@nombre_tabla = 'tipo_flor_cultivo')
	begin
		select tipo_flor_cultivo.id_tipo_flor_cultivo,
		tipo_flor_cultivo.idc_tipo_flor, 
		tipo_flor_cultivo.nombre_tipo_flor,
		ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor))+space(1)+'['+tipo_flor_cultivo.idc_tipo_flor+']'+space(1)+ '('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		tipo_flor_cultivo.disponible_comercializadora
		from tipo_flor_cultivo left join cuenta_interna on  tipo_flor_cultivo.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where tipo_flor_cultivo.disponible_comercializadora = @disponible
		and tipo_flor_cultivo.nombre_tipo_flor like @nombre_item
		and tipo_flor_cultivo.disponible = 1
		and tipo_flor_cultivo.bouquet = 0
		order by tipo_flor_cultivo.nombre_tipo_flor
	end 
	else
	if(@nombre_tabla = 'variedad_flor_cultivo')
	begin
		select variedad_flor_cultivo.id_variedad_flor_cultivo,
		tipo_flor_cultivo.idc_tipo_flor + variedad_flor_cultivo.idc_variedad_flor as idc_variedad_flor, 
		variedad_flor_cultivo.nombre_variedad_flor,
		ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor))+space(1)+'['+tipo_flor_cultivo.idc_tipo_flor+variedad_flor_cultivo.idc_variedad_flor+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		variedad_flor_cultivo.disponible_comercializadora
		from tipo_flor_cultivo,
		variedad_flor_cultivo left join cuenta_interna on  variedad_flor_cultivo.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where variedad_flor_cultivo.disponible_comercializadora = @disponible
		and variedad_flor_cultivo.nombre_variedad_flor like @nombre_item
		and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
		and tipo_flor_cultivo.id_tipo_flor_cultivo like @id_item
		and variedad_flor_cultivo.disponible = 1
		order by variedad_flor_cultivo.nombre_variedad_flor
	end 
	else
	if(@nombre_tabla = 'grado_flor_cultivo')
	begin
		select grado_flor_cultivo.id_grado_flor_cultivo,
		tipo_flor_cultivo.idc_tipo_flor+grado_flor_cultivo.idc_grado_flor as idc_grado_flor, 
		grado_flor_cultivo.nombre_grado_flor,
		ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor))+space(1)+'['+tipo_flor_cultivo.idc_tipo_flor+grado_flor_cultivo.idc_grado_flor+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		grado_flor_cultivo.disponible_comercializadora
		from tipo_flor_cultivo,
		grado_flor_cultivo left join cuenta_interna on  grado_flor_cultivo.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where grado_flor_cultivo.disponible_comercializadora = @disponible
		and grado_flor_cultivo.nombre_grado_flor like @nombre_item
		and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
		and tipo_flor_cultivo.id_tipo_flor_cultivo like @id_item
		and grado_flor_cultivo.disponible = 1
		order by grado_flor_cultivo.nombre_grado_flor
	end
	else
	if(@nombre_tabla = 'farm')
	begin
		select farm.id_farm,
		farm.idc_farm,
		farm.id_tipo_farm,
		farm.id_ciudad,
		farm.nombre_farm,
		farm.observacion,
		farm.disponible,
		farm.tiene_variedad_flor_exclusiva,
		farm.comision_farm,
		farm.dias_restados_despacho_distribuidora,
		ltrim(rtrim(farm.nombre_farm))+space(1)+'['+farm.idc_farm+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre
		from farm left join cuenta_interna on farm.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where farm.disponible = @disponible
		and farm.nombre_farm like @nombre_item
		order by farm.nombre_farm
	end 
	else
	if(@nombre_tabla = 'ciudad')
	begin
		select ciudad.id_ciudad,
		ciudad.idc_ciudad,
		ciudad.codigo_aeropuerto,
		ciudad.nombre_ciudad,
		ciudad.disponible,
		ciudad.impuesto_por_caja,
		ltrim(rtrim(ciudad.nombre_ciudad))+space(1)+'['+ciudad.idc_ciudad+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre
		from ciudad left join cuenta_interna on ciudad.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where ciudad.disponible = @disponible
		and ciudad.nombre_ciudad like @nombre_item
		order by ciudad.nombre_ciudad
	end
	else
	if(@nombre_tabla = 'temporada_ano')
	begin
		select temporada_año.id_temporada_año as id_temporada_ano,
		año.nombre_año + space(1) + '-' + space(1) + temporada.nombre_temporada + space(1) + '-' + space(1) + convert(nvarchar,temporada_año.fecha_inicial,101) + space(1) + '('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		temporada_año.disponible
		from temporada,año,temporada_año left join cuenta_interna on  temporada_año.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where temporada_año.disponible = @disponible
		and temporada.id_temporada = temporada_año.id_temporada
		and año.id_año = temporada_año.id_año
		and temporada_año.id_temporada_año like @id_item
		order by temporada_año.fecha_inicial
	end 
	else
	if(@nombre_tabla = 'tipo_credito')
	begin
		select tipo_credito.id_tipo_credito,
		tipo_credito.idc_tipo_credito, 
		tipo_credito.nombre_tipo_credito,
		ltrim(rtrim(tipo_credito.nombre_tipo_credito))+space(1)+'['+tipo_credito.idc_tipo_credito+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		tipo_credito.disponible
		from tipo_credito left join cuenta_interna on  tipo_credito.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where tipo_credito.disponible = @disponible
		and tipo_credito.nombre_tipo_credito like @nombre_item
		order by tipo_credito.nombre_tipo_credito
	end 
end
else
if(@accion = 'modificar')
begin
	if(@nombre_tabla = 'tapa')
	begin
		update tapa
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_tapa like @id_item
	end
	else
	if(@nombre_tabla = 'tipo_caja')
	begin
		update tipo_caja
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_tipo_caja like @id_item 
	end	
	else
	if(@nombre_tabla = 'caja')
	begin
		update caja
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible 
		where id_caja like @id_item
	end	
	else
	if(@nombre_tabla = 'cliente_factura')
	begin
		update cliente_despacho
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible 
		where id_despacho like @id_item
	end
	else
	if(@nombre_tabla = 'tipo_flor')
	begin
		update tipo_flor
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible 
		where id_tipo_flor like @id_item
	end 
	else
	if(@nombre_tabla = 'variedad_flor')
	begin
		update variedad_flor
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible 
		where id_variedad_flor like @id_item
	end 
	else
	if(@nombre_tabla = 'grado_flor')
	begin
		update grado_flor
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible 
		where id_grado_flor like @id_item
	end 
	else
	if(@nombre_tabla = 'tipo_flor_cultivo')
	begin
		update tipo_flor_cultivo
		set	id_cuenta_interna = @id_cuenta_interna,
		disponible_comercializadora = @disponible 
		where id_tipo_flor_cultivo like @id_item
	end 
	else
	if(@nombre_tabla = 'variedad_flor_cultivo')
	begin
		update variedad_flor_cultivo
		set id_cuenta_interna = @id_cuenta_interna,
		disponible_comercializadora = @disponible 
		where id_variedad_flor_cultivo like @id_item
	end 
	else
	if(@nombre_tabla = 'grado_flor_cultivo')
	begin
		update grado_flor_cultivo
		set id_cuenta_interna = @id_cuenta_interna,
		disponible_comercializadora = @disponible 
		where id_grado_flor_cultivo like @id_item
	end 
	else
	if(@nombre_tabla = 'farm')
	begin
		update farm
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_farm like @id_item
	end
	else
	if(@nombre_tabla = 'ciudad')
	begin
		update ciudad
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_ciudad like @id_item
	end
	else
	if(@nombre_tabla = 'temporada_ano')
	begin
		update temporada_año
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		from temporada_año, configuracion_bd
		where temporada_año.id_temporada_año like @id_item
		and temporada_año.id_temporada_año <> configuracion_bd.id_temporada_año
	end
	else
	if(@nombre_tabla = 'tipo_credito')
	begin
		update tipo_credito
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_tipo_credito like @id_item 
	end	
end