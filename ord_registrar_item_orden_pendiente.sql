set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_registrar_item_orden_pendiente]

@id_orden_pedido_pendiente int,
@id_tapa int,
@id_flor int,
@id_caja int,
@numero_surtido nvarchar(255),
@code nvarchar(255),
@cantidad_piezas int,
@unidades_por_pieza int,
@upc nvarchar(255),
@precio_upc nvarchar(255),
@fecha_vencimiento_flor nvarchar(255),
@capuchon_decorado bit,
@fecha_despacho datetime,
@comida bit,
@id_tipo_pedido int,
@precio_distribuidora decimal (20,4),
@fecha_miami datetime

as

declare @formato_especial_fecha_vencimiento bit,
@caracter nvarchar(255),
@count int,
@i int

set @caracter = '/'
set @i = 1
set @count = 0

/**corroborar si el campo @fecha_vencimiento_flor viene en formato normal o formato especial**/
while (@i <= len(@fecha_vencimiento_flor))
begin
	if(substring(@fecha_vencimiento_flor,@i,1) = @caracter)
	begin
		set @count = @count + 1
	end
	set @i = @i + 1
end

/**si @fecha_vencimiento_flor viene en formato especial asignar una fecha valida**/
if(@count = 1)
begin
	declare @dias int
	set @dias = substring(@fecha_vencimiento_flor, 1, CHARINDEX(@caracter ,@fecha_vencimiento_flor)-1) 
	set @dias = @dias - datepart(dy,getdate())

	set @fecha_vencimiento_flor = convert(nvarchar,getdate() + @dias,101)
	set @formato_especial_fecha_vencimiento = 1
end
else 
	set @formato_especial_fecha_vencimiento = 0

if(@fecha_vencimiento_flor = '')
	set @fecha_vencimiento_flor = null

insert item_orden_pedido_pendiente (id_orden_pedido_pendiente,id_tapa,id_flor,id_caja,numero_surtido,code,cantidad_piezas,unidades_por_pieza,upc,precio_upc,fecha_vencimiento_flor,capuchon_decorado,fecha_despacho,comida,formato_especial_fecha_vencimiento,id_tipo_pedido,precio_distribuidora, fecha_miami)
values (@id_orden_pedido_pendiente,@id_tapa,@id_flor,@id_caja,@numero_surtido,@code,@cantidad_piezas,@unidades_por_pieza,@upc,@precio_upc,convert(datetime,@fecha_vencimiento_flor),@capuchon_decorado,@fecha_despacho,@comida,@formato_especial_fecha_vencimiento,@id_tipo_pedido,@precio_distribuidora,@fecha_miami)

return scope_identity()