set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_tv_tablero5_entradas]

as

declare @fecha datetime,
@entradas int,
@inventario_inicial int,
@compras_de_flor int,
@salidas_bouquetera int, 
@ramo_despatado int

set @fecha = convert(nvarchar, getdate(), 101)

/*Entradas Totales - Tolas las fincas*/
select @entradas = isnull(sum(valor), 0)
from pantalla_entrada_tv5
where tipo_dato = 'Entrada'

/*Inventario Inicial*/
select @inventario_inicial = 
case	 	 		
	when fecha_inventario = @fecha then inventario_cobol 	 	 		
	else 0   	
end 	
from tablero  

/*Compras de Flor que aun no se han clasificado - Patricia graba esta informacion*/
select @compras_de_flor = sum(cantidad_tallos)
from compra_sin_clasificar
where compra_sin_clasificar.fecha = @fecha

/*Salidas para Bouquetera*/
select @salidas_bouquetera = sum(valor)
from pantalla_entrada_tv5
where tipo_dato = 'Resultado'
and dato = 'Salida_Bouquetera'

/*Ramo_despatado*/
select @ramo_despatado = sum(valor)
from pantalla_entrada_tv5
where tipo_dato = 'Ramos'
and dato = 'Ramo_Despatado'

select dato, [dbo].[formato_numero] (valor)
from pantalla_entrada_tv5
where tipo_dato = 'Entrada'
group by dato, [dbo].[formato_numero] (valor)
union all
select 'Total', [dbo].[formato_numero] (sum(valor))
from pantalla_entrada_tv5
where tipo_dato = 'Entrada'
union all
select dato, [dbo].[formato_numero] (sum(valor))
from pantalla_entrada_tv5
where tipo_dato = 'Resultado'
and dato = 'xSACAR'
group by dato
union all
select 'Falta',
[dbo].[formato_numero] 
(
	isnull(@entradas, 0) + isnull(@inventario_inicial, 0) + isnull(@compras_de_flor, 0) - isnull(@salidas_bouquetera, 0) - isnull(@ramo_despatado, 0)
)