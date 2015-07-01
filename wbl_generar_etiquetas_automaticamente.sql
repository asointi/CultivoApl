/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[wbl_generar_etiquetas_automaticamente]

@numero_reporte_farm int, 
@id_temporada_año int,
@id_farm int, 
@idc_tipo_factura nvarchar(255)

as

declare @id_reporte_cambio_orden_pedido int, 
@id_reporte_cambio_orden_pedido_doble int,
@id_tipo_factura int,
@id_tipo_factura_doble int,
@usuario nvarchar(100),
@conteo int,
@cantidad_piezas int,
@id_etiqueta nvarchar(25),
@id_farm_cobol nvarchar(5)

select @id_farm_cobol = id_farm_cobol from Globales_Sql
select @id_etiqueta = max(id_etiqueta) from Etiqueta

if(@id_etiqueta is null)
begin
	set @id_etiqueta = '00000001'
end

while(len(@id_etiqueta) < 8)
begin
	set @id_etiqueta = '0' + @id_etiqueta
end

select @id_tipo_factura = id_tipo_factura from tipo_factura where idc_tipo_factura = @idc_tipo_factura
select @id_tipo_factura_doble = id_tipo_factura from tipo_factura where idc_tipo_factura = '7'
select @usuario = usuario 
from usuario_farm,
farm
where farm.idc_farm = usuario_farm.farm
and farm.id_farm = @id_farm

create table #resultado 
(
	idc_farm nvarchar(5),
	idc_tipo_flor nvarchar(5),
	idc_variedad_flor nvarchar(5),
	idc_grado_flor nvarchar(5),
	idc_tapa nvarchar(5),
	idc_tipo_caja nvarchar(5),
	nombre_tipo_caja nvarchar(50),
	code nvarchar(10), 
	unidades_por_pieza int, 
	usuario_weblabel nvarchar(100),
	id_etiqueta nvarchar(25),
	nombre_tipo_flor nvarchar(50),
	nombre_variedad_flor nvarchar(50),
	nombre_grado_flor nvarchar(50)
)

if(@idc_tipo_factura = '9')
begin
	/*seleccionar las ordenes desde item_reporte_cambio_orden_pedido insertadas*/
	select farm.idc_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	code, 
	unidades_por_pieza, 
	case
		when item_reporte_cambio_orden_pedido.disponible = 0 then item_reporte_cambio_orden_pedido.cantidad_piezas *-1
		else item_reporte_cambio_orden_pedido.cantidad_piezas
	end as cantidad_piezas,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor into #temp
	from item_reporte_cambio_orden_pedido, 
	reporte_cambio_orden_pedido,
	farm, 
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	tipo_factura
	where item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.id_tipo_factura = @id_tipo_factura
	and reporte_cambio_orden_pedido.numero_reporte_farm = @numero_reporte_farm 
	and farm.id_farm = @id_farm
	
	/*insercion de registros en una nueva tabla temporal para poder realizar el agrupamiento y la suma de la cantidad de piezas*/
	select identity(int, 1,1) as id,
	idc_farm,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	idc_tapa,
	idc_tipo_caja,
	nombre_tipo_caja,
	code, 
	unidades_por_pieza, 
	SUM(cantidad_piezas) as cantidad_piezas,
	@usuario  as usuario_weblabel,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor into #temp_def_so
	from #temp 
	group by idc_farm,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	idc_tapa,
	idc_tipo_caja,
	nombre_tipo_caja,
	code, 
	unidades_por_pieza,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor
	having SUM(cantidad_piezas) > 0
	order by idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	idc_tapa,
	idc_tipo_caja,
	code

	/*volver a colocar el tipo de orden a las cancelaciones debido a que en el agrupamiento anterior se pierde*/
	select @conteo = count(*) 
	from #temp_def_so
	set @cantidad_piezas = 0

	while (@conteo > 0)
	begin
		select @cantidad_piezas = cantidad_piezas
		from #temp_def_so
		where id = @conteo

		while (@cantidad_piezas > 0)
		begin
			insert into #resultado 
			(
				idc_farm,
				idc_tipo_flor,
				idc_variedad_flor,
				idc_grado_flor,
				idc_tapa,
				idc_tipo_caja,
				nombre_tipo_caja,
				code, 
				unidades_por_pieza, 
				usuario_weblabel,
				id_etiqueta,
				nombre_tipo_flor,
				nombre_variedad_flor,
				nombre_grado_flor
			)
			select idc_farm,
			idc_tipo_flor,
			idc_variedad_flor,
			idc_grado_flor,
			idc_tapa,
			idc_tipo_caja,
			nombre_tipo_caja,
			code, 
			unidades_por_pieza, 
			usuario_weblabel,
			@id_farm_cobol + @id_etiqueta as id_etiqueta,
			nombre_tipo_flor,
			nombre_variedad_flor,
			nombre_grado_flor
			from #temp_def_so
			where id = @conteo

			set @cantidad_piezas = @cantidad_piezas - 1
			set @id_etiqueta = @id_etiqueta + 1

			while(len(@id_etiqueta) < 8)
			begin
				set @id_etiqueta = '0' + @id_etiqueta
			end
		end	

		set @conteo = @conteo - 1
	end

	/*eliminación de tablas temporales*/
	drop table #temp
	drop table #temp_def_so
end
else 
IF (@idc_tipo_factura = '4')
begin
	select @id_reporte_cambio_orden_pedido = id_reporte_cambio_orden_pedido 
	from reporte_cambio_orden_pedido 
	where numero_reporte_farm = @numero_reporte_farm 
	and id_farm = @id_farm 
	and id_tipo_factura = @id_tipo_factura
	and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año
	
	select @id_reporte_cambio_orden_pedido_doble = id_reporte_cambio_orden_pedido 
	from reporte_cambio_orden_pedido 
	where reporte_cambio_orden_pedido.numero_reporte_farm = @numero_reporte_farm 
	and reporte_cambio_orden_pedido.id_farm = @id_farm 
	and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura_doble
	and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año

	/*seleccionar las ordenes desde Item_Reporte_Cambio_Orden_Pedido ingresados anteriormente*/
	select farm.idc_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	code, 
	unidades_por_pieza, 
	case
		when item_reporte_cambio_orden_pedido.disponible = 0 then item_reporte_cambio_orden_pedido.cantidad_piezas *-1
		else item_reporte_cambio_orden_pedido.cantidad_piezas
	end as cantidad_piezas,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor  into #temp_pb
	from item_reporte_cambio_orden_pedido, 
	reporte_cambio_orden_pedido,
	farm, 
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	tipo_factura
	where item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and reporte_cambio_orden_pedido.id_farm = @id_farm
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and (reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = @id_reporte_cambio_orden_pedido or reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = @id_reporte_cambio_orden_pedido_doble)
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.id_tipo_factura = @id_tipo_factura or tipo_factura.id_tipo_factura = @id_tipo_factura_doble)

	/*insercion de registros en una nueva tabla temporal para poder realizar el agrupamiento y la suma de la cantidad de piezas*/
	select identity(int, 1,1) as id,
	idc_farm,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	idc_tapa,
	idc_tipo_caja,
	nombre_tipo_caja,
	code, 
	unidades_por_pieza, 
	SUM(cantidad_piezas) as cantidad_piezas,
	@usuario  as usuario_weblabel,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor into #temp_def_pb
	from #temp_pb
	group by idc_farm,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	idc_tapa,
	idc_tipo_caja,
	nombre_tipo_caja,
	code, 
	unidades_por_pieza,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor
	having SUM(cantidad_piezas) > 0
	order by idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	idc_tapa,
	idc_tipo_caja,
	code

	/*volver a colocar el tipo de orden a las cancelaciones debido a que en el agrupamiento anterior se pierde*/
	select @conteo = count(*) 
	from #temp_def_pb
	set @cantidad_piezas = 0

	while (@conteo > 0)
	begin
		select @cantidad_piezas = cantidad_piezas
		from #temp_def_pb
		where id = @conteo

		while (@cantidad_piezas > 0)
		begin
			insert into #resultado 
			(
				idc_farm,
				idc_tipo_flor,
				idc_variedad_flor,
				idc_grado_flor,
				idc_tapa,
				idc_tipo_caja,
				nombre_tipo_caja,
				code, 
				unidades_por_pieza, 
				usuario_weblabel,
				id_etiqueta,
				nombre_tipo_flor,
				nombre_variedad_flor,
				nombre_grado_flor
			)
			select idc_farm,
			idc_tipo_flor,
			idc_variedad_flor,
			idc_grado_flor,
			idc_tapa,
			idc_tipo_caja,
			nombre_tipo_caja,
			code, 
			unidades_por_pieza, 
			usuario_weblabel,
			@id_farm_cobol + @id_etiqueta as id_etiqueta,
			nombre_tipo_flor,
			nombre_variedad_flor,
			nombre_grado_flor
			from #temp_def_pb
			where id = @conteo

			set @cantidad_piezas = @cantidad_piezas - 1
			set @id_etiqueta = @id_etiqueta + 1

			while(len(@id_etiqueta) < 8)
			begin
				set @id_etiqueta = '0' + @id_etiqueta
			end
		end	

		set @conteo = @conteo - 1
	end

	/*eliminación de tablas temporales*/
	drop table #temp_pb
	drop table #temp_def_pb
end

select * 
from #resultado

drop table #resultado