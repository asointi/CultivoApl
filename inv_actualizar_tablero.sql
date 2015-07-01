set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[inv_actualizar_tablero]

@inventario_cobol int,
@fecha_inventario datetime,
@freedom_por_empacar int,
@accion nvarchar(255)

as

if(@accion = 'inventario')
begin
	update tablero
	set inventario_cobol = @inventario_cobol,
	fecha_inventario = @fecha_inventario
end
else
if(@accion = 'saldo_freedom')
begin
	update tablero
	set freedom_por_empacar = @freedom_por_empacar,
	freedom_por_empacar_tablero = 'Freedom por Empacar:'+ space(1)+left(convert(nvarchar, (convert(money, @freedom_por_empacar)), 1), charindex('.', convert(nvarchar, (convert(money, @freedom_por_empacar)), 1))-1)
end
else
if(@accion = 'consultar_informacion_tablero')
begin
	select tallos_postcosecha,
	tallos_por_ramo,
	tallos_por_ramo_ultima_hora,
	hora_salida_estimada,
	tallos_inventario,
	tallos_freedom,
	tallos_charlotte,
	freedom_40,
	tallos_forever,
	light_pink_40,
	hot_pink_40,
	yellow_40,
	freedom_por_empacar_tablero,
	rendimiento_clasificadora 
	from tablero
end