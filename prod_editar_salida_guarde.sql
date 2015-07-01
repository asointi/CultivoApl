set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[prod_editar_salida_guarde]

@cantidad_tallos int,
@accion nvarchar(50)

as

if(@accion = 'grabar_tallos')
begin
	update configuracion_bd
	set salida_guarde = salida_guarde + @cantidad_tallos
end
else
if(@accion = 'inicializar_salida')
begin
	update configuracion_bd
	set salida_guarde = 0
end
