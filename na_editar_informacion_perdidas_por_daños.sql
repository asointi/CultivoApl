create PROCEDURE [dbo].[na_editar_informacion_perdidas_por_da�os]

@fecha datetime,
@porcentaje decimal(20,4)

as

update congiguracion_bd
set perdidas_por_da�os_fecha = @fecha,
perdidas_por_da�os_porcentaje = @porcentaje