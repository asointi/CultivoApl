/*El Tablero cuanta con 5 Querys los cuales son:
1. Entradas
2. Pérdidas por Daños
3. Postcosecha
4. Ramo
5. Total Ramo
*/

/*1. Entradas*/
select  'ER',
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	sum(pieza_postcosecha.unidades_por_pieza)AS money),1)), 4, 20)
), 0) as unidades
from pieza_postcosecha,      
bloque,      
finca_bloque,      
finca_propia      
where pieza_postcosecha.id_bloque = bloque.id_bloque      
and bloque.id_bloque = finca_bloque.id_bloque      
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))      
and finca_propia.idc_finca_propia = 'ER'  
union 
select  'GU', 
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	sum(pieza_postcosecha.unidades_por_pieza)AS money),1)), 4, 20)
), 0) as unidades
from pieza_postcosecha,      
bloque,      
finca_bloque,      
finca_propia      
where pieza_postcosecha.id_bloque = bloque.id_bloque      
and bloque.id_bloque = finca_bloque.id_bloque      
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))      
and finca_propia.idc_finca_propia = 'GU'  
union 
select  'FA', 
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	sum(pieza_postcosecha.unidades_por_pieza)AS money),1)), 4, 20)
), 0) as unidades
from pieza_postcosecha,      
bloque,      
finca_bloque,      
finca_propia      
where pieza_postcosecha.id_bloque = bloque.id_bloque      
and bloque.id_bloque = finca_bloque.id_bloque      
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))      
and finca_propia.idc_finca_propia = 'FA'  
union 
select  'MY', 
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	sum(pieza_postcosecha.unidades_por_pieza)AS money),1)), 4, 20)
), 0) as unidades
from pieza_postcosecha,      
bloque,      
finca_bloque,      
finca_propia      
where pieza_postcosecha.id_bloque = bloque.id_bloque      
and bloque.id_bloque = finca_bloque.id_bloque      
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia      
and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))      
and finca_propia.idc_finca_propia = 'MY'  
union 
select 'Total',    
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	sum(pieza_postcosecha.unidades_por_pieza)AS money),1)), 4, 20)
), 0) as unidades
from pieza_postcosecha,    
bloque,    
finca_bloque,    
finca_propia    
where pieza_postcosecha.id_bloque = bloque.id_bloque    
and bloque.id_bloque = finca_bloque.id_bloque    
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia    
and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))      
union 
select 'xSACAR',    
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	sum(pieza_postcosecha.unidades_por_pieza)AS money),1)), 4, 20)
), 0) as unidades
from pieza_postcosecha    
where not exists    
( 	 	 	 
	select *  	 	 	 
	from salida_pieza 	 	 	 
	where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    
)   and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) between  
convert(datetime,convert(nvarchar, getdate() - 7, 101))  and convert(datetime,convert(nvarchar, getdate(), 101))     
union 
select 'Falta',     
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
/*Entradas + Inventario Inicial - Ramos Despatados - Salidas para Bouquetera + Ramo Comprado diferente a Mystery o Family*/
isnull(sum(pieza_postcosecha.unidades_por_pieza), 0) + 
(	  	
	select isnull(   	
	case	 	 		
		when fecha_inventario = convert(datetime,convert(nvarchar, getdate(), 101)) then inventario_cobol 	 	 		
		else 0   	
	end, 0) as inventario_inicial   	
	from tablero  
) +
(
	select isnull(sum(cantidad_tallos), 0)
	from compra_sin_clasificar
	where convert(datetime, convert(nvarchar, fecha, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))   	 	
)-
(  	
	select isnull(cantidad_tallos, 0)
	from ramo_pantalla   	
	where tipo_ramo = 'Total Tallos'  
) -
( 	 	
	select isnull(sum(unidades_por_pieza), 0) 	 	
	from pieza_postcosecha, 	 	
	salida_pieza, 	 	
	cliente_despacho 	 	 	 	 	
	where pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha    	 	
	and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))   	 	
	and cliente_despacho.id_cliente_despacho = salida_pieza.id_cliente_despacho 	 	
	and cliente_despacho.idc_cliente_despacho <> 'SACOAAA'  
) 
AS money),1)), 4, 20)), 0) as unidades
from pieza_postcosecha,     
bloque,     
finca_bloque,     
finca_propia     
where pieza_postcosecha.id_bloque = bloque.id_bloque     
and bloque.id_bloque = finca_bloque.id_bloque     
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia     
and convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) = convert(datetime, convert(nvarchar, getdate(), 101))

/*2. Pérdidas por Daños*/
select 'Pérdidas x Daños ' + 
convert(nvarchar,datepart(mm,perdidas_por_daños_fecha)) + 
'/' + 
convert(nvarchar,datepart(dd,perdidas_por_daños_fecha)) as perdidas_por_daños_fecha, 
convert(decimal(20,2),perdidas_por_daños_porcentaje) as perdidas_por_daños_porcentaje 
from configuracion_bd

/*3. Postcosecha*/
select labor,  
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	tallos_bonchados AS money),1)), 4, 20)
), 0) as tallos_bonchados,
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	cantidad_personas AS money),1)), 4, 20)
), 0) as cantidad_personas,
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	horas_acumuladas AS money),1)), 4, 20)
), 0) as horas_acumuladas,
convert(int,round(convert(decimal(20,1),rendimiento), 0)) as rendimiento, 
case
	when horas_acumuladas = 0 then 0
	else convert(int,round(convert(decimal(20,1),(convert(decimal(20,4),tallos_bonchados) / 25) / horas_acumuladas),0))
end as rendimiento_25 
from postcosecha_pantalla

/*4. Ramo*/
select tipo_ramo,    
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	cantidad_tallos AS money),1)), 4, 20)
), 0) as cantidad_tallos,
factor,   
isnull(REVERSE(SUBSTRING(REVERSE(CONVERT(varchar(20), CAST
(
	cantidad_tallos_proyectados AS money),1)), 4, 20)
), 0) as cantidad_tallos_proyectados
from ramo_pantalla

/*5. Total Ramo*/
select  
case   	 	
	when tipo_ramo = 'Total Tallos' then convert(int,round(convert(decimal(20,1),(convert(decimal(20,4),cantidad_tallos_proyectados) / 
	(
		select horas_acumuladas 
		from postcosecha_pantalla 
		where labor = 'Postcosecha'
	))),0))  	
	else null  
end as rendimiento,  
case   	 	
	when tipo_ramo = 'Total Tallos' then convert(int, round(convert(decimal(20,1),(convert(decimal(20,4),cantidad_tallos_proyectados) / 25) / 
	(
		select horas_acumuladas 
		from postcosecha_pantalla 
		where labor = 'Postcosecha'
	)), 0))  	
	else null   
end as rendimiento_25   
from ramo_pantalla 
where tipo_ramo = 'Total Tallos'