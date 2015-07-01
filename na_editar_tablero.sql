set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_tablero]

@accion nvarchar(255)

AS
if(@accion = 'consultar')
begin

	/*Datos que son presentados en una pantalla de televisión y que despliega información
	sobre diferentes datos de la postcosecha. la consulta se realiza de esta forma, debido
	a que está en una tabla en un sólo registro y es necesario enviarla al reporte en forma
	de columnas*/

	select 'INVENTARIO INICIAL:' as label, 
	tallos_inventario as datos
	from tablero
	union all
	select 'ENTRADAS:', tallos_postcosecha from tablero  
	union all  
	select 'TALLOS BONCHADOS:', tallos_por_ramo from tablero  
	union all  
	select 'BONCHADOS ULT HORA:', tallos_por_ramo_ultima_hora from tablero
	union all  
	select 'SALIDA ESTIMADA:', hora_salida_estimada from tablero
	union all  
	select 'ENTRADAS FREEDOM:', tallos_freedom from tablero
	union all  
	select 'ENTRADAS CHARLOTTE:', tallos_charlotte from tablero
	union all  
	select 'FREEDOM 40:', freedom_40 from tablero
end