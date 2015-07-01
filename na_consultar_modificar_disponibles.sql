set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_consultar_modificar_disponibles]

@nombre_tabla nvarchar(255),
@disponible bit,
@id_cuenta_interna int,
@id_item nvarchar(255),
@nombre_item nvarchar(255),
@accion nvarchar(255)

AS

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
		order by tapa.idc_tapa
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
		order by tipo_caja.idc_tipo_caja
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
		order by tipo_caja.idc_tipo_caja,caja.idc_caja
	end 
	else
	if(@nombre_tabla = 'cliente_despacho')
	begin
		select cliente_despacho.id_cliente_despacho,
		cliente_despacho.idc_cliente_despacho, 
		cliente_despacho.nombre_cliente,
		ltrim(rtrim(cliente_despacho.nombre_cliente))+space(1)+'['+cliente_despacho.idc_cliente_despacho+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		cliente_despacho.disponible
		from cliente_despacho left join cuenta_interna on  cliente_despacho.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where cliente_despacho.disponible = @disponible
		and cliente_despacho.nombre_cliente like @nombre_item
		order by cliente_despacho.idc_cliente_despacho
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
		order by tipo_flor.idc_tipo_flor
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
		order by tipo_flor.idc_tipo_flor,variedad_flor.idc_variedad_flor
	end 
	else
	if(@nombre_tabla = 'grado_flor')
	begin
		select grado_flor.id_grado_flor,
		tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor as idc_grado_flor, 
		grado_flor.nombre_grado_flor,
		ltrim(rtrim(grado_flor.nombre_grado_flor))+space(1)+'['+tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		grado_flor.disponible
		from tipo_flor,grado_flor left join cuenta_interna on  grado_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where grado_flor.disponible = @disponible
		and grado_flor.nombre_grado_flor like @nombre_item
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor like @id_item
		order by tipo_flor.idc_tipo_flor,grado_flor.idc_grado_flor
	end
	else
	if(@nombre_tabla = 'bloque')
	begin
		select bloque.id_bloque,
		bloque.idc_bloque + space(1) + '(' + isnull(cuenta_interna.nombre,'') + ')' as nombre, 
		bloque.disponible
		from bloque left join cuenta_interna on  bloque.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where bloque.disponible = @disponible
		and bloque.idc_bloque like @nombre_item
		order by bloque.idc_bloque
	end 
	else
	if(@nombre_tabla = 'supervisor')
	begin
		select supervisor.id_supervisor,
		supervisor.nombre_supervisor,
		ltrim(rtrim(supervisor.nombre_supervisor)) + space(1) + '[' + supervisor.idc_supervisor + ']' + space(1) + '(' + isnull(cuenta_interna.nombre,'') + ')' as nombre,
		supervisor.disponible
		from supervisor left join cuenta_interna on  supervisor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where supervisor.disponible = @disponible
		and supervisor.nombre_supervisor like @nombre_item
		order by supervisor.idc_supervisor,
		supervisor.nombre_supervisor
	end 
	else
	if(@nombre_tabla = 'punto_corte')
	begin
		select punto_corte.id_punto_corte,
		punto_corte.idc_punto_corte, 
		punto_corte.nombre_punto_corte,
		ltrim(rtrim(punto_corte.nombre_punto_corte))+space(1)+'['+punto_corte.idc_punto_corte+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		punto_corte.disponible
		from punto_corte left join cuenta_interna on  punto_corte.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where punto_corte.disponible = @disponible
		and punto_corte.nombre_punto_corte like @nombre_item
		order by punto_corte.nombre_punto_corte
	end 
	else
	if(@nombre_tabla = 'regla')
	begin
		select regla.id_regla,
		regla.nombre_regla,
		ltrim(rtrim(regla.nombre_regla)) + space(1) + '(' + isnull(cuenta_interna.nombre,'')+')' as nombre,
		regla.disponible
		from regla left join cuenta_interna on  regla.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where regla.disponible = @disponible
		and regla.nombre_regla like @nombre_item
		order by regla.nombre_regla
	end 
	else
	if(@nombre_tabla = 'persona')
	begin
		select persona.id_persona,
		persona.idc_persona, 
		ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona,
		ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '['+persona.idc_persona+']'+space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		persona.disponible
		from persona left join cuenta_interna on  persona.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where persona.disponible = @disponible
		and ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) like @nombre_item
		order by nombre_persona
	end 
	else
	if(@nombre_tabla = 'detalle_labor')
	begin
		select detalle_labor.id_detalle_labor,
		detalle_labor.idc_detalle_labor, 
		ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_detalle_labor,
		ltrim(rtrim(labor.nombre_labor)) + space(1) + '['+ labor.idc_labor + ']' + ' - ' + ltrim(rtrim(detalle_labor.nombre_detalle_labor)) + space(1) + '[' + detalle_labor.idc_detalle_labor + ']' + space(1) + '(' + isnull(cuenta_interna.nombre,'') + ')' as nombre,
		detalle_labor.disponible
		from detalle_labor left join cuenta_interna on  detalle_labor.id_cuenta_interna = cuenta_interna.id_cuenta_interna,
		labor
		where detalle_labor.disponible = @disponible
		and ltrim(rtrim(detalle_labor.nombre_detalle_labor)) like @nombre_item
		and labor.id_labor = detalle_labor.id_labor
		order by labor.nombre_labor,
		detalle_labor.nombre_detalle_labor
	end 
	else
	if(@nombre_tabla = 'capuchon')
	begin
		select capuchon.id_capuchon,
		capuchon.idc_capuchon, 
		ltrim(rtrim(capuchon.descripcion)) as nombre_capuchon,
		ltrim(rtrim(capuchon.descripcion)) + space(1) + '[' + capuchon.idc_capuchon + ']' + space(1)+'('+isnull(cuenta_interna.nombre,'')+')' as nombre,
		capuchon.disponible
		from capuchon left join cuenta_interna on  capuchon.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		where capuchon.disponible = @disponible
		and ltrim(rtrim(capuchon.descripcion)) like @nombre_item
		order by nombre_capuchon
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
	if(@nombre_tabla = 'cliente_despacho')
	begin
		update cliente_despacho
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible 
		where id_cliente_despacho like @id_item
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
	if(@nombre_tabla = 'bloque')
	begin
		update bloque
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_bloque like @id_item
	end
	else
	if(@nombre_tabla = 'supervisor')
	begin
		update supervisor
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_supervisor like @id_item
	end
	else
	if(@nombre_tabla = 'punto_corte')
	begin
		update punto_corte
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_punto_corte like @id_item 
	end	
	else
	if(@nombre_tabla = 'regla')
	begin
		update regla
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_regla like @id_item 
	end	
	else
	if(@nombre_tabla = 'persona')
	begin
		update persona
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_persona like @id_item 
	end	
	else
	if(@nombre_tabla = 'detalle_labor')
	begin
		update detalle_labor
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_detalle_labor like @id_item 
	end	
	else
	if(@nombre_tabla = 'capuchon')
	begin
		update capuchon
		set id_cuenta_interna = @id_cuenta_interna,
		disponible = @disponible
		where id_capuchon like @id_item 
	end	
end

