set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_actualizar_tabla_pantalla_entrada_tv5]

as

declare @fecha datetime

set @fecha = convert(nvarchar, getdate(), 101)

/*Ramos Despatados - No han sido leidos como ramos reales*/
update pantalla_entrada_tv5
set valor = 
(
	select sum(ramo_despatado.tallos_por_ramo)
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
) 
where pantalla_entrada_tv5.tipo_dato = 'Ramos'
and pantalla_entrada_tv5.dato = 'Ramo_Despatado'

/*Entradas de las fincas ER, FA, GU, MY*/
update pantalla_entrada_tv5
set valor = 
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,      
	bloque,      
	finca_bloque
	where pieza_postcosecha.id_bloque = bloque.id_bloque      
	and bloque.id_bloque = finca_bloque.id_bloque      
	and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
	and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha
)
from finca_propia
where finca_propia.idc_finca_propia in ('ER', 'FA', 'MY', 'GU')  
and pantalla_entrada_tv5.tipo_dato = 'Entrada'
and pantalla_entrada_tv5.dato = finca_propia.idc_finca_propia

/*Flor por sacar - entradas que a'un no presenten salida*/
update pantalla_entrada_tv5
set valor = 
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha    
	where not exists    
	( 	 	 	 
		select *  	 	 	 
		from salida_pieza 	 	 	 
		where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    
	)   and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) between  
	@fecha - 7  and @fecha
)
where pantalla_entrada_tv5.tipo_dato = 'Resultado'
and pantalla_entrada_tv5.dato = 'xSACAR'

/*Salidas de Flor que se realizan para la Bouquetera*/
update pantalla_entrada_tv5
set valor =
(
	select sum(unidades_por_pieza)
	from pieza_postcosecha, 	 	
	salida_pieza, 	 	
	cliente_despacho 	 	 	 	 	
	where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    	 	
	and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = @fecha
	and cliente_despacho.id_cliente_despacho = salida_pieza.id_cliente_despacho 	 	
	and cliente_despacho.idc_cliente_despacho <> 'SACOAAA'  
)
where pantalla_entrada_tv5.tipo_dato = 'Resultado'
and pantalla_entrada_tv5.dato = 'Salida_Bouquetera'