set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[fls_imprimir_label]

@numero_orden bigint, 
@idc_pieza nvarchar(255),
@accion nvarchar(255)

AS

declare @id_pieza int, @numero_tracking int

if(@accion = 'asignar_numero_tracking')
begin
	declare @id_item_orden_floralship int

	select top 1 @id_pieza = pieza.id_pieza, 
	@id_item_orden_floralship = item_orden_floralship.id_item_orden_floralship,
	@numero_tracking = item_orden_floralship.numero_tracking
	from orden_floralship, 
	item_orden_floralship, 
	pieza,
	tipo_caja,
	caja,
	variedad_flor,
	grado_flor
	where orden_floralship.id_orden_floralship = item_orden_floralship.id_orden_floralship
	and orden_floralship.numero_orden = @numero_orden
	and item_orden_floralship.id_tipo_caja = tipo_caja.id_tipo_caja
	and item_orden_floralship.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_orden_floralship.id_grado_flor = grado_flor.id_grado_flor
	and item_orden_floralship.unidades_por_pieza = pieza.unidades_por_pieza
	and pieza.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza.id_grado_flor = grado_flor.id_grado_flor
	and pieza.idc_pieza = @idc_pieza
	and not exists
	(
	select * 
	from Pieza_item_orden_Floralship
	where pieza.id_pieza = Pieza_item_orden_Floralship.id_pieza
	and item_orden_floralship.id_item_orden_floralship = Pieza_item_orden_Floralship.id_item_orden_floralship
	)
	group by pieza.id_pieza, item_orden_floralship.id_item_orden_floralship, item_orden_floralship.numero_tracking
	
	if(@numero_tracking is null)
	begin
		select isnull(@numero_tracking, -1) as numero_tracking
	end
	else
	begin
		insert into Pieza_item_orden_Floralship (id_item_orden_floralship, id_pieza)
		values (@id_item_orden_floralship, @id_pieza)
		
		select isnull(@numero_tracking, -1) as numero_tracking
	end
	
end
else
if(@accion = 'consultar_numero_piezas')
begin
	exec master..xp_cmdshell 'dtexec /FILE "D:\sales-app\Prodccon\Modify\SQLdata\Proyectos\Importar_XML_FloralShip\Importar_XML_FloralShip\Package.dtsx" /CONNECTION "DBP\PRUEBAS.BD_Fresca.sa";"\"Data Source=FRESCA-DC-0;User ID=sa;Password=DbNf2006;Initial Catalog=BD_Fresca;Provider=SQLNCLI.1;Auto Translate=False;\"" /CONNECTION "DBP\PRUEBAS.BD_Fresca_Temp.sa";"\"Data Source=Fresca-dc-0;User ID=sa;Password=DbNf2006;Initial Catalog=BD_Fresca_Temp;Provider=SQLNCLI.1;Auto Translate=False;\""  /MAXCONCURRENT " -1 " /CHECKPOINTING OFF  /REPORTING EWCDI', NO_OUTPUT 
	
	select isnull(count(item_orden_floralship.id_item_orden_floralship), 0) as cantidad_piezas
	from orden_floralship, 
	item_orden_floralship
	where orden_floralship.id_orden_floralship = item_orden_floralship.id_orden_floralship
	and orden_floralship.numero_orden = @numero_orden
	and not exists 
	(select * from pieza_item_orden_floralship
	where pieza_item_orden_floralship.id_item_orden_floralship = item_orden_floralship.id_item_orden_floralship)
end
else
if(@accion = 'eliminar_numero_tracking')
begin	
	select @id_pieza = id_pieza from pieza where idc_pieza = @idc_pieza

	if(@id_pieza is null)
		select -1 as result
	else
	begin	
		delete from Pieza_item_orden_floralship
		where id_pieza = @id_pieza
		select 1 as result
	end
end
else
if(@accion = 'consultar_numero_tracking')
begin
	select isnull(item_orden_floralship.numero_tracking, -1) as numero_tracking
	from pieza_item_orden_floralship, 
	pieza, 
	item_orden_floralship
	where pieza.id_pieza = pieza_item_orden_floralship.id_pieza
	and pieza_item_orden_floralship.id_item_orden_floralship = item_orden_floralship.id_item_orden_floralship
	and pieza.idc_pieza = @idc_pieza
end
else
if(@accion = 'consultar_productos')
begin
	select farm.idc_farm,
	farm.nombre_farm,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_orden_floralship.unidades_por_pieza,
	item_orden_floralship.numero_tracking
	from orden_floralship,
	item_orden_floralship,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_caja,
	farm
	where orden_floralship.id_orden_floralship = item_orden_floralship.id_orden_floralship
	and item_orden_floralship.id_tipo_caja = tipo_caja.id_tipo_caja
	and item_orden_floralship.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_orden_floralship.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and item_orden_floralship.id_farm = farm.id_farm
	and orden_floralship.numero_orden = @numero_orden
	and not exists
	(select * from pieza_item_orden_floralship
	where pieza_item_orden_floralship.id_item_orden_floralship = item_orden_floralship.id_item_orden_floralship)
end