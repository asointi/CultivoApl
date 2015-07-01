set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_tiempo_ejecucion_regla]

@id_regla int

as

insert into tiempo_ejecucion_regla(id_tipo_transaccion, id_regla, fecha_transaccion)
select tipo_transaccion.id_tipo_transaccion, @id_regla, getdate()
from tipo_transaccion
where tipo_transaccion.nombre_tipo_transaccion = 'fin'




