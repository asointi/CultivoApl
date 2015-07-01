set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_consultar_fecha_despacho]

@fecha_despacho datetime

as

declare @dias_atras_despacho_cultivo int,
@id_dia_despacho int,
@id_tipo_despacho int,
@id_tipo_despacho_aux int,
@sin_despacho int,
@con_despacho int,
@corrimiento int

set @sin_despacho = 1
set @con_despacho = 2
set @corrimiento = 3

select rango_pedido_bouquet.id_rango_pedido_bouquet,
rango_pedido_bouquet.fecha_inicial,
(
	select top 1 r.fecha_inicial - 1 
	from rango_pedido_bouquet as r
	where r.id_rango_pedido_bouquet > rango_pedido_bouquet.id_rango_pedido_bouquet
	order by r.fecha_inicial
) as fecha_final,
rango_pedido_bouquet.cantidad_dias_atras,
rango_pedido_bouquet.fecha_modificacion into #rango_pedido
from rango_pedido_bouquet
where rango_pedido_bouquet.id_rango_pedido_bouquet < 
(
	select max(id_rango_pedido_bouquet)
	from rango_pedido_bouquet
)
union all
select rango_pedido_bouquet.id_rango_pedido_bouquet,
rango_pedido_bouquet.fecha_inicial,
DATEADD(year,DATEDIFF(year, 0, rango_pedido_bouquet.fecha_inicial) + 1, 0) - 1 as fecha_final,
rango_pedido_bouquet.cantidad_dias_atras,
rango_pedido_bouquet.fecha_modificacion
from rango_pedido_bouquet
where rango_pedido_bouquet.id_rango_pedido_bouquet = 
(
	select max(id_rango_pedido_bouquet)
	from rango_pedido_bouquet
)
order by rango_pedido_bouquet.fecha_inicial

select @dias_atras_despacho_cultivo = #rango_pedido.cantidad_dias_atras 
from #rango_pedido
where @fecha_despacho between
#rango_pedido.fecha_inicial and #rango_pedido.fecha_final

set @id_dia_despacho = datepart(dw, convert(datetime,@fecha_despacho) - @dias_atras_despacho_cultivo)

select @id_tipo_despacho = id_tipo_despacho from forma_despacho where id_dia_despacho = @id_dia_despacho
set @id_tipo_despacho_aux = @id_tipo_despacho

/**sumar un dia al dia de despacho hallado cuando para ese dia no hay despacho**/
if(@id_tipo_despacho = @sin_despacho)
begin
	set @id_dia_despacho = replace(@id_dia_despacho + 1,8,1)
	select @id_tipo_despacho = id_tipo_despacho from forma_despacho where id_dia_despacho = @id_dia_despacho
end

/**restar un dia para cuando no se encuentre corrimiento con el paso anterior**/
if(@id_tipo_despacho = @con_despacho and @id_tipo_despacho_aux = @sin_despacho)
begin
	set @id_dia_despacho = replace(@id_dia_despacho - 1,0,7)
	select @id_tipo_despacho = id_tipo_despacho from forma_despacho where id_dia_despacho = @id_dia_despacho
end

/**restar dias hasta que se encuentre un dia con despacho**/
while (@id_tipo_despacho = @sin_despacho)
begin
	set @id_dia_despacho = replace(@id_dia_despacho - 1,0,7)
	select @id_tipo_despacho = id_tipo_despacho from forma_despacho where id_dia_despacho = @id_dia_despacho
end

/**asignar la fecha de despacho del cultivo segun el dia de despacho hallado,
este calculo depende si el dia hallado es mayor o menor que el dia de la semana de la fecha de Miami**/
if(datepart(dw,@fecha_despacho) > @id_dia_despacho)
begin	
	set @fecha_despacho = @fecha_despacho-(datepart(dw,@fecha_despacho) - @id_dia_despacho)
end
else
begin
	set @fecha_despacho = @fecha_despacho-(datepart(dw,@fecha_despacho) - @id_dia_despacho + 7)
end

drop table #rango_pedido

select @fecha_despacho