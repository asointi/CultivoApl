set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_tallo_clasificado]

@largo decimal(20,4), 
@ancho decimal(20,4), 
@alto_cabeza decimal(20,4), 
@apertura decimal(20,4), 
@eyector int, 
@numero_ordenamiento int, 
@id_regla int

as

insert into tallo_clasificado (largo, ancho, alto_cabeza, apertura, eyector, fecha_transaccion, id_tiempo_ejecucion_detalle_condicion)
select @largo, @ancho, @alto_cabeza, @apertura, @eyector, getdate(), max(tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion)
from tiempo_ejecucion_detalle_condicion,
detalle_condicion,
tiempo_ejecucion_regla,
regla
where tiempo_ejecucion_detalle_condicion.id_detalle_condicion = detalle_condicion.id_detalle_condicion
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla = tiempo_ejecucion_regla.id_tiempo_ejecucion_regla
and detalle_condicion.numero_ordenamiento = @numero_ordenamiento
and tiempo_ejecucion_regla.id_regla = regla.id_regla
and regla.id_regla = @id_regla