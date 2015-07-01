set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_TV_tablero9]

@accion nvarchar(255)

as

declare @entradas_totales int,
@entradas_natuflora int,
@entradas_family int,
@entradas_mystery int,
@entradas_guasca int,
@ramos_especiales int,
@inventario_inicial int,
@salidas_postcosecha int,
@salidas_bouquetera int,
@salidas_otros int,
@tallos_guasca_por_llegar int,
@fecha datetime,
@dias_sin_dato nvarchar(255),
@por_sacar int,
@ramo_despatado int,
@salidas_guarde int,
@clasificacion_sin_bonchar int

set @fecha = convert(datetime, convert(nvarchar, getdate(), 101)) 

if(@accion = 'Inventario_Final')
begin
	/*Entradas de las fincas ER, FA, GU, VY*/
	select finca_propia.idc_finca_propia,
	(
		select sum(pieza_postcosecha.unidades_por_pieza)
		from pieza_postcosecha,      
		bloque,      
		finca_bloque
		where pieza_postcosecha.id_bloque = bloque.id_bloque      
		and bloque.id_bloque = finca_bloque.id_bloque      
		and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
		and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha
	) as valor into #entradas
	from finca_propia

	select @entradas_totales = sum(valor)
	from #entradas

	select @entradas_natuflora = valor
	from #entradas
	where idc_finca_propia = 'ER'

	select @entradas_family = valor
	from #entradas
	where idc_finca_propia = 'FA'

	select @entradas_mystery = valor
	from #entradas
	where (
		idc_finca_propia = 'VY'
		or idc_finca_propia = 'VA'
		or idc_finca_propia = 'TG'
	)

	select @entradas_guasca = valor
	from #entradas
	where idc_finca_propia = 'GU'

	select @salidas_guarde = salida_guarde
	from configuracion_bd
	
	select @ramos_especiales = isnull(sum(cantidad_tallos), 0)
	from compra_sin_clasificar
	where fecha = @fecha

	set @ramos_especiales = isnull(@ramos_especiales, 0) + isnull(@salidas_guarde, 0)

	select @inventario_inicial = 
	case	 	 		
		when fecha_inventario = @fecha then inventario_cobol 	 	 		
		else 0   	
	end 	
	from tablero  

	select cliente_despacho.idc_cliente_despacho,
	isnull(sum(unidades_por_pieza), 0) as unidades into #unidades_por_cliente
	from pieza_postcosecha, 	 	
	salida_pieza, 	 	
	cliente_despacho 	 	 	 	 	
	where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    	 	
	and convert(datetime, convert(nvarchar, salida_pieza.fecha_salida, 101)) = @fecha
	and cliente_despacho.id_cliente_despacho = salida_pieza.id_cliente_despacho 	 	
	group by cliente_despacho.idc_cliente_despacho

	select @salidas_postcosecha = unidades
	from #unidades_por_cliente	
	where idc_cliente_despacho = 'SACOAAA'

	select @salidas_bouquetera = unidades
	from #unidades_por_cliente	
	where idc_cliente_despacho = 'SACOBQ'

	select @salidas_otros = sum(unidades)
	from #unidades_por_cliente	
	where idc_cliente_despacho <> 'SACOBQ'
	and idc_cliente_despacho <> 'SACOAAA'

	select @clasificacion_sin_bonchar = isnull(sum(detalle_clasificacion_sin_bonchar.unidades), 0)
	from clasificacion_sin_bonchar,
	detalle_clasificacion_sin_bonchar,
	estado_clasificacion_sin_bonchar,
	tipo_flor,
	variedad_flor
	where clasificacion_sin_bonchar.id_clasificacion_sin_bonchar = detalle_clasificacion_sin_bonchar.id_clasificacion_sin_bonchar
	and estado_clasificacion_sin_bonchar.id_estado_clasificacion_sin_bonchar = clasificacion_sin_bonchar.id_estado_clasificacion_sin_bonchar
	and estado_clasificacion_sin_bonchar.nombre_estado = 'Activa'
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_clasificacion_sin_bonchar.id_variedad_flor
	and tipo_flor.idc_tipo_flor = 'RO'
	and convert(datetime,convert(nvarchar,clasificacion_sin_bonchar.fecha_transaccion, 101)) = @fecha
	and clasificacion_sin_bonchar.numero_packing_list is not null

	/*Se le suman a las salidas de la postcosecha los ramos comprados que no sean de Mystery, Family ni Guasca*/
	select @salidas_postcosecha = @salidas_postcosecha + isnull(sum(tallos_por_ramo), 0)
	from ramo_comprado,
	etiqueta_impresa_finca_asignada,
	finca_asignada,
	finca
	where finca.id_finca = finca_asignada.id_finca
	and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
	and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada
	and convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura, 101)) = @fecha
	and finca.idc_finca <> 'MF'
	and finca.idc_finca <> 'FY'
	and finca.idc_finca <> 'IC'

	select finca_propia.idc_finca_propia,
	isnull(pieza_postcosecha.unidades_por_pieza, 0) as unidades,
	verifica_entrada.id_verifica_entrada into #pieza_verificada
	from pieza_postcosecha,
	entrada left join verifica_entrada on entrada.id_etiqueta_impresa = verifica_entrada.id_etiqueta_impresa,
	bloque,
	finca_bloque,
	finca_propia
	where convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha
	and pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
	and bloque.id_bloque = pieza_postcosecha.id_bloque
	and bloque.id_bloque = finca_bloque.id_bloque
	and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
	and finca_propia.idc_finca_propia = 'GU'

	select @tallos_guasca_por_llegar = sum(unidades)
	from #pieza_verificada
	where idc_finca_propia = 'GU'
	
	select @tallos_guasca_por_llegar = isnull(@tallos_guasca_por_llegar, 0) - isnull(sum(unidades), 0)
	from #pieza_verificada
	where idc_finca_propia = 'GU'
	and id_verifica_entrada is not null

	select @por_sacar = sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha    
	where not exists    
	( 	 	 	 
		select *  	 	 	 
		from salida_pieza 	 	 	 
		where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    
	)   and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) between  
	@fecha - 7  and @fecha

	select @ramo_despatado = sum(ramo_despatado.tallos_por_ramo)
	from ramo_despatado
	where not exists
	(
		select *
		from ramo,
		ramo_devuelto
		where ramo.idc_ramo = ramo_despatado.idc_ramo_despatado
		and convert(datetime, convert(nvarchar, ramo.fecha_entrada, 101)) = @fecha - 5
		and ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado
	)
	and not exists
	(
		select *
		from ramo_comprado,
		ramo_devuelto
		where ramo_comprado.idc_ramo_comprado = ramo_despatado.idc_ramo_despatado
		and convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura, 101)) = @fecha - 5
		and ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado
	)
	and convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha

	delete from pantalla_TV_tablero9
	where tipo_dato = 'Entradas'
	
	insert into pantalla_TV_tablero9 (tipo_dato, dato, valor, orden)
	select  'Entradas', 'ER' as concepto, [dbo].[formato_numero] (@entradas_natuflora) as unidades, 1
	union all
	select  'Entradas', 'FA', [dbo].[formato_numero] (@entradas_family), 2
	union all
	select  'Entradas', 'GU', [dbo].[formato_numero] (@entradas_guasca), 3
	union all
	select  'Entradas', 'OTROS', [dbo].[formato_numero] (@entradas_mystery), 4
	union all
	select  'Entradas', 'Total', [dbo].[formato_numero] ( isnull(@entradas_totales, 0)), 5 
	union all 
	select  'Entradas', 'xSACAR', [dbo].[formato_numero] (@por_sacar), 6
	union all 
	select  'Entradas', 'Falta', [dbo].[formato_numero] (isnull(@entradas_totales, 0) + isnull(@inventario_inicial, 0) + isnull(@ramos_especiales, 0) - isnull(@salidas_bouquetera, 0) - isnull(@ramo_despatado, 0) - isnull(@clasificacion_sin_bonchar, 0) - isnull(@salidas_otros, 0)), 7

	delete from pantalla_TV_tablero9
	where tipo_dato = 'Inventario_Final'

	insert into pantalla_TV_tablero9 (tipo_dato, dato, valor, orden)
	select  'Inventario_Final', 'ER' as concepto, [dbo].[formato_numero] (@entradas_natuflora) as unidades, 1
	union all
	select  'Inventario_Final', 'FA', [dbo].[formato_numero] (@entradas_family), 2
	union all
	select  'Inventario_Final', 'GU', [dbo].[formato_numero] (@entradas_guasca), 3
	union all
	select  'Inventario_Final', 'OTROS', [dbo].[formato_numero] (@entradas_mystery), 4
	union all
	select  'Inventario_Final', 'Producción Día', [dbo].[formato_numero] ( isnull(@entradas_totales, 0)), 5 
	union all
	select 'Inventario_Final', 'Especiales', [dbo].[formato_numero] (@ramos_especiales), 6
	union all
	select 'Inventario_Final', 'I.I.S.S.', [dbo].[formato_numero] (@inventario_inicial), 7
	union all
	select 'Inventario_Final', 'Total', [dbo].[formato_numero] ( isnull(@entradas_totales, 0) + isnull(@ramos_especiales, 0) + @inventario_inicial), 8
	union all
	select 'Inventario_Final', 'Sacado P.C.', [dbo].[formato_numero] (@salidas_postcosecha), 9
	union all
	select 'Inventario_Final', 'Sacado B.Q.', [dbo].[formato_numero] (@salidas_bouquetera), 10
	union all
	select 'Inventario_Final', 'Sacado Otros', [dbo].[formato_numero] (@salidas_otros), 11
	union all
	select  'Inventario_Final', 'I.F.S.S.', [dbo].[formato_numero] ((isnull(@entradas_totales, 0) + isnull(@ramos_especiales, 0) + isnull(@inventario_inicial, 0)) - isnull(@salidas_postcosecha, 0) - isnull(@salidas_bouquetera, 0) - isnull(@salidas_otros, 0)), 12
	union all
	select 'Inventario_Final', 'Guasca x Llegar', [dbo].[formato_numero] (@tallos_guasca_por_llegar), 13
	union all
	select  'Inventario_Final', 'I.F.C.F.', [dbo].[formato_numero] ((isnull(@entradas_totales, 0) + isnull(@ramos_especiales, 0) + isnull(@inventario_inicial, 0)) - isnull(@salidas_postcosecha, 0) - isnull(@salidas_bouquetera, 0) - isnull(@salidas_otros, 0) - isnull(@tallos_guasca_por_llegar, 0)), 15

	update configuracion_bd
	set fecha_actualizacion_televisores = getdate()

	drop table #entradas
	drop table #unidades_por_cliente
	drop table #pieza_verificada
end
else
if(@accion = 'Inventario_Ramos')
begin
if(@fecha - 1 not in 
(
	select fecha_lectura
	from verifica_ramo
	group by fecha_lectura
	union all
	select fecha_lectura
	from verifica_ramo_comprado
	group by fecha_lectura
)
)
begin
	set @fecha = null

	declare @fecha_maxima_verifica_ramo datetime, 
	@fecha_maxima_verifica_ramo_comprado datetime

	select @fecha_maxima_verifica_ramo = max(fecha_lectura)
	from verifica_ramo
	
	select @fecha_maxima_verifica_ramo_comprado = max(fecha_lectura)
	from verifica_ramo_comprado
	
	select @fecha = 
	case 
		when @fecha_maxima_verifica_ramo > @fecha_maxima_verifica_ramo_comprado then @fecha_maxima_verifica_ramo
		when @fecha_maxima_verifica_ramo < @fecha_maxima_verifica_ramo_comprado then @fecha_maxima_verifica_ramo_comprado
		else @fecha_maxima_verifica_ramo 
	end

	set @dias_sin_dato = datediff(d, @fecha,  convert(datetime, convert(nvarchar, getdate(), 101)) ) - 1

	update configuracion_bd
	set fecha_actualizacion_televisores = getdate()
end
else
begin
	set @fecha = @fecha - 1
end
	select convert(datetime, convert(nvarchar, ramo.fecha_entrada, 101)) as fecha,
	isnull(sum(tallos_por_ramo), 0) as unidades into #ramo
	from ramo,
	verifica_ramo
	where ramo.id_ramo = verifica_ramo.id_ramo
	and convert(datetime, convert(nvarchar, verifica_ramo.fecha_lectura, 101)) = @fecha
	and convert(datetime, convert(nvarchar, ramo.fecha_entrada, 101)) between 
	@fecha - 60 and @fecha
	group by convert(datetime, convert(nvarchar, ramo.fecha_entrada, 101))
	order by convert(datetime, convert(nvarchar, ramo.fecha_entrada, 101))

	select convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura, 101)) as fecha,
	isnull(sum(tallos_por_ramo), 0) as unidades into #ramo_comprado
	from ramo_comprado,
	verifica_ramo_comprado
	where ramo_comprado.id_ramo_comprado = verifica_ramo_comprado.id_ramo_comprado
	and convert(datetime, convert(nvarchar, verifica_ramo_comprado.fecha_lectura, 101)) = @fecha
	and convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura, 101)) between
	@fecha - 60 and @fecha
	group by convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura, 101))

	update #ramo
	set unidades = #ramo.unidades + #ramo_comprado.unidades
	from #ramo_comprado
	where #ramo.fecha = #ramo_comprado.fecha

	delete from pantalla_TV_tablero9
	where tipo_dato = 'Inventario_Ramos'

	insert into pantalla_TV_tablero9 (tipo_dato, orden, dato, valor)
	SELECT 'Inventario_Ramos', 
	0 as orden,
	case
		when @dias_sin_dato is null then ''
		else 'Días sin dato:'
	end as fecha,
	@dias_sin_dato as unidades
	union all	 
	/*Menos 1 día del actual*/
	select 'Inventario_Ramos', 
	ROW_NUMBER() OVER(ORDER BY fecha DESC) as orden,
	left(convert(nvarchar, fecha, 7), 6) as fecha,
	[dbo].[formato_numero] (sum(unidades))
	from #ramo
	where fecha > = @fecha - 5
	group by fecha
	union all
	/*Menos 1 día del actual*/
	select 'Inventario_Ramos', 
	20 as orden,
	'Anteriores' as fecha,
	[dbo].[formato_numero] (sum(unidades))
	from #ramo
	where fecha < = @fecha - 6
	union all
	/*Menos 1 día del actual*/
	select 'Inventario_Ramos', 
	30 as orden,
	'Total' as fecha,
	[dbo].[formato_numero] (sum(unidades))
	from #ramo
	where fecha < = @fecha

	drop table #ramo
	drop table #ramo_comprado

	update configuracion_bd
	set fecha_actualizacion_televisores = getdate()
end