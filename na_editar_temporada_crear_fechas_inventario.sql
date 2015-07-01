--Create table [Fecha_Inventario]
--(
--	[id_fecha_inventario] Integer Identity(1,1) NOT NULL,
--	[id_temporada_año] Integer NOT NULL,
--	[fecha] Datetime NOT NULL,
--	[fecha_transaccion] Datetime Default getdate() NOT NULL,
--	[id_cuenta_interna] Integer NOT NULL,
--Constraint [pk_Fecha_Inventario] Primary Key ([id_fecha_inventario])
--) 
--go
--Alter table [Fecha_Inventario] add Constraint [fk_cuenta_interna_fecha_inventario] foreign key([id_cuenta_interna]) references [Cuenta_Interna] ([id_cuenta_interna])  on update no action on delete no action 
--go
--Alter table [Fecha_Inventario] add Constraint [fk_temporada_año_fecha_inventario] foreign key([id_temporada_año]) references [Temporada_Año] ([id_temporada_año])  on update no action on delete no action 

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_temporada_crear_fechas_inventario]

@accion nvarchar(50),
@id_temporada_año int,
@fecha datetime,
@id_fecha_inventario int,
@id_cuenta_interna int

AS

set @fecha = convert(datetime, convert(nvarchar, @fecha, 103))

declare @conteo_existe int

if(@accion = 'insertar_fecha_inventario')
begin
	declare @conteo_dentro_rango_fechas int,
	@id_fecha_inventario_aux int

	select @conteo_existe = count(*) 
	from fecha_inventario
	where id_temporada_año = @id_temporada_año
	and fecha = @fecha

	select @conteo_dentro_rango_fechas = count(*)
	from temporada_cubo,
	temporada,
	año,
	temporada_año 
	where temporada.id_temporada = temporada_año.id_temporada
	and año.id_año = temporada_año.id_año
	and temporada.id_temporada = temporada_cubo.id_temporada
	and año.id_año = temporada_cubo.id_año
	and temporada_año.id_temporada_año = @id_temporada_año
	and @fecha between
	temporada_cubo.fecha_inicial and temporada_cubo.fecha_final

	if(@conteo_existe = 1)
	begin
		--La fecha para la temporada escogida ya existe
		select -1 as id_fecha_inventario
	end
	else
	if(@conteo_dentro_rango_fechas = 0)
	begin
		--La fecha para la temporada escogida no está dentro del rango de ésta
		select -2 as id_fecha_inventario
	end
	else
	if(@conteo_existe = 0 and @conteo_dentro_rango_fechas = 1)
	begin
		insert into fecha_inventario (id_temporada_año, fecha, id_cuenta_interna)
		values (@id_temporada_año, @fecha, @id_cuenta_interna)

		set @id_fecha_inventario_aux = scope_identity()

		select @id_fecha_inventario_aux as id_fecha_inventario
	end
end
else
if(@accion = 'eliminar_fecha_inventario')
begin
	select @conteo_existe = count(*)
	from detalle_item_inventario_preventa
	where fecha_disponible_distribuidora = @fecha

	if(@conteo_existe = 0)
	begin
		delete from fecha_inventario
		where id_fecha_inventario = @id_fecha_inventario
		
		select 1 as id_fecha_inventario
	end
	else
	begin
		--NO se puede eliminar la fecha debido a que hay inventario
		select -1 as id_fecha_inventario
	end
end
else
if(@accion = 'consultar_fecha_inventario')
begin
	select fecha_inventario.id_fecha_inventario,
	temporada_año.id_temporada_año,
	fecha_inventario.fecha,
	fecha_inventario.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta
	from fecha_inventario,
	temporada_año,
	cuenta_interna
	where temporada_año.id_temporada_año = fecha_inventario.id_temporada_año
	and temporada_año.id_temporada_año = @id_temporada_año
	and cuenta_interna.id_cuenta_interna = fecha_inventario.id_cuenta_interna
	order by fecha_inventario.fecha
end