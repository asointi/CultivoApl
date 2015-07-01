create PROCEDURE [dbo].[na_editar_informacion_perdidas_por_daños]

@fecha datetime,
@porcentaje decimal(20,4)

as

update congiguracion_bd
set perdidas_por_daños_fecha = @fecha,
perdidas_por_daños_porcentaje = @porcentaje