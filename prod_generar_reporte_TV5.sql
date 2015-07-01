set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_TV5]

@accion nvarchar(255)

as

declare @entradas_natuflora int,
@entradas_family int,
@entradas_mystery int,
@inventario_sin_sacar int,
@inventario_inicial int,
@salidas_bouquetera int,
@ramo_comprado_no_propio int,
@ramo_despatado int,
@fecha datetime

set @fecha = convert(datetime, convert(nvarchar, getdate(), 101))

if(@accion = 'Entradas')
begin
	select @entradas_natuflora = sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,      
	bloque,      
	finca_bloque,      
	finca_propia      
	where pieza_postcosecha.id_bloque = bloque.id_bloque      
	and bloque.id_bloque = finca_bloque.id_bloque      
	and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
	and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha      
	and finca_propia.idc_finca_propia = 'ER'  

	select @entradas_family = sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,      
	bloque,      
	finca_bloque,      
	finca_propia      
	where pieza_postcosecha.id_bloque = bloque.id_bloque      
	and bloque.id_bloque = finca_bloque.id_bloque      
	and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
	and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha
	and finca_propia.idc_finca_propia = 'FA'  

	select @entradas_mystery =	sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,      
	bloque,      
	finca_bloque,      
	finca_propia      
	where pieza_postcosecha.id_bloque = bloque.id_bloque      
	and bloque.id_bloque = finca_bloque.id_bloque      
	and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
	and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha
	and finca_propia.idc_finca_propia = 'MY'  

	select 	@inventario_sin_sacar = sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha    
	where not exists    
	( 	 	 	 
		select *  	 	 	 
		from salida_pieza 	 	 	 
		where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    
	)   and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) between  
	@fecha - 7 and @fecha

	select @inventario_inicial =  	
	case	 	 		
		when fecha_inventario = @fecha then inventario_cobol 	 	 		
		else 0   	
	end
	from tablero  

	select @salidas_bouquetera = isnull(sum(unidades_por_pieza), 0)
	from pieza_postcosecha, 	 	
	salida_pieza, 	 	
	cliente_despacho 	 	 	 	 	
	where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    	 	
	and convert(datetime, convert(nvarchar, salida_pieza.fecha_salida, 101)) = @fecha
	and cliente_despacho.id_cliente_despacho = salida_pieza.id_cliente_despacho 	 	
	and cliente_despacho.idc_cliente_despacho = 'SACOBQ'

	select @ramo_comprado_no_propio = sum(ramo_comprado.tallos_por_ramo) 	
	from ramo_comprado, 	
	etiqueta_impresa_finca_asignada, 	
	finca_asignada, 	
	finca 	
	where convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura, 101)) = @fecha
	and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada 	
	and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca 	
	and finca.id_finca = finca_asignada.id_finca 	
	and finca.idc_finca <> 'FY' 	
	and finca.idc_finca <> 'MF' 

	select @ramo_despatado = sum(ramo_despatado.tallos_por_ramo)
	from ramo_despatado
	where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha
	and not exists
	(
		select *
		from ramo_devuelto
		where ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado
	)
	and not exists
	(
		select *
		from ramo
		where ramo.idc_ramo = ramo_despatado.idc_ramo_despatado
	)
	and not exists
	(
		select *
		from ramo_comprado
		where ramo_comprado.idc_ramo_comprado = ramo_despatado.idc_ramo_despatado
	)

	select 'ER' as concepto, REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST(isnull(@entradas_natuflora, 0) AS money),1)), 4, 20)) as unidades
	union all 
	select 'FA', REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST(isnull(@entradas_family, 0) AS money),1)), 4, 20))
	union all 
	select 'MY', REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST(isnull(@entradas_mystery, 0) AS money),1)), 4, 20))
	union all
	select 'Total', REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST(isnull(@entradas_natuflora, 0) + isnull(@entradas_family, 0) + isnull(@entradas_mystery, 0) AS money),1)), 4, 20))
	union all 
	select 'xSACAR', REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST(isnull(@inventario_sin_sacar, 0) AS money),1)), 4, 20))
	union all
	select 'Falta',
	REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST((isnull(@entradas_natuflora, 0) + isnull(@entradas_family, 0) + isnull(@entradas_mystery, 0) + isnull(@inventario_inicial, 0) + isnull(@ramo_comprado_no_propio, 0)) - isnull(@salidas_bouquetera, 0) - isnull(@ramo_despatado, 0) AS money),1)), 4, 20))
end