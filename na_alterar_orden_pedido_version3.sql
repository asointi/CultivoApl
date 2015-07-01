/****** Object:  StoredProcedure [dbo].[na_alterar_orden_pedido]    Script Date: 11/13/2007 12:49:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_alterar_orden_pedido_version3]

@idc_orden_pedido nvarchar(255),
@idc_cliente_despacho nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255), 
@idc_tipo_caja nvarchar(255),
@idc_farm nvarchar(255), 
@idc_tapa nvarchar(255), 
@idc_transportador nvarchar(255),
@idc_tipo_factura nvarchar(255),
@fecha_inicial nvarchar(255), 
@fecha_final nvarchar(255), 
@code nvarchar(255),
@unidades_por_pieza integer,
@cantidad_piezas integer,
@valor_unitario decimal(20,4), 
@comentario nvarchar(1024),
@disponible nvarchar(255), 
@idc_orden_pedido_padre nvarchar(255),
@accion nvarchar(255),
@idc_vendedor nvarchar(255),
@comida nvarchar(255),
@upc nvarchar(255),
@fecha_vencimiento_flor nvarchar(255),
@fecha_creacion_orden nvarchar(255),
@fecha_para_aprobar nvarchar(255),
@idc_transportador_anterior nvarchar(255),
@numero_po nvarchar(255)

AS

declare @conteo_transportador int,
@conteo int

IF(@fecha_para_aprobar = '')
	set @fecha_para_aprobar = null

IF(@fecha_vencimiento_flor = '')
	set @fecha_vencimiento_flor = null

set @idc_tipo_caja = left(@idc_tipo_caja,1)
set @idc_orden_pedido = convert(int,@idc_orden_pedido)
set @idc_orden_pedido_padre = convert(int, @idc_orden_pedido_padre)

select max(id_historia_transportador_orden_pedido) as id_historia_transportador_orden_pedido into #temp
from historia_transportador_orden_pedido
group by id_orden_pedido,
id_transportador

IF(@accion = 'modificar')
begin
	IF(@idc_vendedor = '')
	begin
		IF (@idc_orden_pedido in (select convert(int,idc_orden_pedido) from orden_pedido))
		begin
			update orden_pedido
			set id_despacho = cliente_despacho.id_despacho,
			id_variedad_flor = variedad_flor.id_variedad_flor,
			id_grado_flor = grado_flor.id_grado_flor,
			id_tipo_caja = tipo_caja.id_tipo_caja,
			id_farm = farm.id_farm,
			id_tapa = tapa.id_tapa,
			id_transportador = transportador.id_transportador,
			id_tipo_factura = tipo_factura.id_tipo_factura,
			fecha_inicial = convert(datetime, @fecha_inicial),
			fecha_final = convert(datetime, @fecha_final),
			marca = @code,
			unidades_por_pieza = @unidades_por_pieza,
			cantidad_piezas = @cantidad_piezas,
			valor_unitario = @valor_unitario,
			comentario = @comentario,
			disponible = replace(replace(@disponible, 'N', 1), 'S', 0),
			id_vendedor = vendedor.id_vendedor,
			comida = replace(replace(@comida, 'N', 0), 'S', 1),
			upc = @upc,
			fecha_vencimiento_flor = convert(datetime,@fecha_vencimiento_flor),
			fecha_creacion_orden = convert(datetime,@fecha_creacion_orden),
			fecha_para_aprobar = convert(datetime, @fecha_para_aprobar),
			numero_po = @numero_po
			from orden_pedido, 
			cliente_despacho, 
			tipo_flor, 
			variedad_flor, 
			grado_flor, 
			tipo_caja, 
			farm, 
			tapa, 
			transportador, 
			tipo_factura, 
			vendedor, 
			configuracion_bd
			where convert(int, orden_pedido.idc_orden_pedido) = @idc_orden_pedido
			and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
			and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
			and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
			and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
			and tipo_caja.idc_tipo_caja = @idc_tipo_caja
			and farm.idc_farm = @idc_farm
			and tapa.idc_tapa = @idc_tapa
			and transportador.idc_transportador = @idc_transportador
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			and vendedor.id_vendedor = configuracion_bd.id_vendedor_global

			select @conteo_transportador = count(*)
			from orden_pedido,
			historia_transportador_orden_pedido,
			transportador 
			where orden_pedido.id_orden_pedido_padre = historia_transportador_orden_pedido.id_orden_pedido
			and convert(int,orden_pedido.idc_orden_pedido) = convert(int,idc_orden_pedido)
			and transportador.id_transportador = historia_transportador_orden_pedido.id_transportador
			and transportador.idc_transportador = @idc_transportador_anterior
			and exists
			(
				select *
				from #temp
				where historia_transportador_orden_pedido.id_historia_transportador_orden_pedido = #temp.id_historia_transportador_orden_pedido
			)

			if(@conteo_transportador = 0)
			begin
				insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
				select transportador.id_transportador, orden_pedido.id_orden_pedido_padre
				from orden_pedido,
				transportador 
				where convert(int,orden_pedido.idc_orden_pedido) = convert(int,idc_orden_pedido)
				and transportador.idc_transportador = @idc_transportador_anterior
			end
		end
		else
			begin
				if(@idc_orden_pedido_padre = 0)
				begin
					insert into orden_pedido (idc_orden_pedido, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
					id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar, numero_po)
					select @idc_orden_pedido, 
					cliente_despacho.id_despacho, 
					variedad_flor.id_variedad_flor, 
					grado_flor.id_grado_flor, 
					tipo_caja.id_tipo_caja,
					farm.id_farm, 
					tapa.id_tapa, 
					transportador.id_transportador, 
					tipo_factura.id_tipo_factura, 
					convert(datetime, @fecha_inicial), 
					convert(datetime, @fecha_final),
					@code, 
					@unidades_por_pieza, 
					@cantidad_piezas, 
					@valor_unitario, 
					@comentario, 
					replace(replace(@disponible, 'N', 1), 'S', 0), 
					vendedor.id_vendedor, 
					replace(replace(@comida, 'N', 0), 'S', 1), 
					@upc, 
					convert(datetime,@fecha_vencimiento_flor), 
					convert(datetime,@fecha_creacion_orden), 
					convert(datetime, @fecha_para_aprobar),
					@numero_po
					from cliente_despacho, 
					tipo_flor, 
					variedad_flor, 
					grado_flor, 
					tipo_caja, 
					farm, 
					tapa, 
					transportador, 
					tipo_factura, 
					vendedor, 
					configuracion_bd
					where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
					and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
					and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
					and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
					and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
					and tipo_caja.idc_tipo_caja = @idc_tipo_caja
					and farm.idc_farm = @idc_farm
					and tapa.idc_tapa = @idc_tapa
					and transportador.idc_transportador = @idc_transportador
					and tipo_factura.idc_tipo_factura = @idc_tipo_factura
					and vendedor.id_vendedor = configuracion_bd.id_vendedor_global
					
					declare @id_orden_pedido_1 integer
					set @id_orden_pedido_1 = scope_identity()

					update orden_pedido
					set id_orden_pedido_padre = @id_orden_pedido_1
					where id_orden_pedido = @id_orden_pedido_1

					insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
					select transportador.id_transportador, @id_orden_pedido_1
					from transportador 
					where transportador.idc_transportador = @idc_transportador_anterior
				end
				else
				begin
					declare @id_orden_pedido_padre integer

					select @id_orden_pedido_padre = id_orden_pedido_padre 
					from orden_pedido 
					where convert(int,idc_orden_pedido) = @idc_orden_pedido_padre
					
					insert into orden_pedido (idc_orden_pedido, id_orden_pedido_padre, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
					id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar, numero_po)
					select @idc_orden_pedido, 
					@id_orden_pedido_padre, 
					cliente_despacho.id_despacho, 
					variedad_flor.id_variedad_flor, 
					grado_flor.id_grado_flor, 
					tipo_caja.id_tipo_caja,
					farm.id_farm, 
					tapa.id_tapa, 
					transportador.id_transportador, 
					tipo_factura.id_tipo_factura, 
					convert(datetime, @fecha_inicial), 
					convert(datetime, @fecha_final),
					@code, 
					@unidades_por_pieza, 
					@cantidad_piezas, 
					@valor_unitario, 
					@comentario, 
					replace(replace(@disponible, 'N', 1), 'S', 0), 
					vendedor.id_vendedor, 
					replace(replace(@comida, 'N', 0), 'S', 1), 
					@upc, 
					convert(datetime,@fecha_vencimiento_flor), 
					convert(datetime,@fecha_creacion_orden), 
					convert(datetime, @fecha_para_aprobar),
					@numero_po
					from cliente_despacho, 
					tipo_flor, 
					variedad_flor, 
					grado_flor, 
					tipo_caja, 
					farm, 
					tapa,	
					transportador, 
					tipo_factura, 
					vendedor, 
					configuracion_bd
					where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
					and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
					and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
					and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
					and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
					and tipo_caja.idc_tipo_caja = @idc_tipo_caja
					and farm.idc_farm = @idc_farm
					and tapa.idc_tapa = @idc_tapa
					and transportador.idc_transportador = @idc_transportador
					and tipo_factura.idc_tipo_factura = @idc_tipo_factura
					and vendedor.id_vendedor = configuracion_bd.id_vendedor_global

					select @conteo_transportador = count(*)
					from orden_pedido,
					historia_transportador_orden_pedido,
					transportador 
					where orden_pedido.id_orden_pedido_padre = historia_transportador_orden_pedido.id_orden_pedido
					and orden_pedido.id_orden_pedido_padre = @id_orden_pedido_padre
					and transportador.id_transportador = historia_transportador_orden_pedido.id_transportador
					and transportador.idc_transportador = @idc_transportador_anterior
					and exists
					(
						select *
						from #temp
						where historia_transportador_orden_pedido.id_historia_transportador_orden_pedido = #temp.id_historia_transportador_orden_pedido
					)

					if(@conteo_transportador = 0)
					begin
						insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
						select transportador.id_transportador, orden_pedido.id_orden_pedido_padre
						from orden_pedido,
						transportador 
						where orden_pedido.id_orden_pedido_padre = @id_orden_pedido_padre
						and transportador.idc_transportador = @idc_transportador_anterior
					end
				end
			end
	end
	else
	IF (@idc_orden_pedido in (select convert(int,idc_orden_pedido) from orden_pedido))
	begin
		update orden_pedido
		set id_despacho = cliente_despacho.id_despacho,
		id_variedad_flor = variedad_flor.id_variedad_flor,
		id_grado_flor = grado_flor.id_grado_flor,
		id_tipo_caja = tipo_caja.id_tipo_caja,
		id_farm = farm.id_farm,
		id_tapa = tapa.id_tapa,
		id_transportador = transportador.id_transportador,
		id_tipo_factura = tipo_factura.id_tipo_factura,
		fecha_inicial = convert(datetime, @fecha_inicial),
		fecha_final = convert(datetime, @fecha_final),
		marca = @code,
		unidades_por_pieza = @unidades_por_pieza,
		cantidad_piezas = @cantidad_piezas,
		valor_unitario = @valor_unitario,
		comentario = @comentario,
		disponible = replace(replace(@disponible, 'N', 1), 'S', 0),
		id_vendedor = vendedor.id_vendedor,
		comida = replace(replace(@comida, 'N', 0), 'S', 1),
		upc = @upc,
		fecha_vencimiento_flor = convert(datetime,@fecha_vencimiento_flor),
		fecha_creacion_orden = convert(datetime,@fecha_creacion_orden),
		fecha_para_aprobar = convert(datetime, @fecha_para_aprobar),
		numero_po = @numero_po
		from orden_pedido, 
		cliente_despacho, 
		tipo_flor, 
		variedad_flor, 
		grado_flor, 
		tipo_caja, 
		farm, 
		tapa, 
		transportador, 
		tipo_factura, 
		vendedor
		where convert(int,orden_pedido.idc_orden_pedido) = @idc_orden_pedido
		and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
		and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_caja.idc_tipo_caja = @idc_tipo_caja
		and farm.idc_farm = @idc_farm
		and tapa.idc_tapa = @idc_tapa
		and transportador.idc_transportador = @idc_transportador
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and vendedor.idc_vendedor = @idc_vendedor

		select @conteo_transportador = count(*)
		from orden_pedido,
		historia_transportador_orden_pedido,
		transportador 
		where orden_pedido.id_orden_pedido_padre = historia_transportador_orden_pedido.id_orden_pedido
		and convert(int,orden_pedido.idc_orden_pedido) = convert(int,idc_orden_pedido)
		and transportador.id_transportador = historia_transportador_orden_pedido.id_transportador
		and transportador.idc_transportador = @idc_transportador_anterior
		and exists
		(
			select *
			from #temp
			where historia_transportador_orden_pedido.id_historia_transportador_orden_pedido = #temp.id_historia_transportador_orden_pedido
		)

		if(@conteo_transportador = 0)
		begin
			insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
			select transportador.id_transportador, orden_pedido.id_orden_pedido_padre
			from orden_pedido,
			transportador 
			where convert(int,orden_pedido.idc_orden_pedido) = convert(int,idc_orden_pedido)
			and transportador.idc_transportador = @idc_transportador_anterior
		end
	end
	else
	begin
		if(@idc_orden_pedido_padre = 0)
		begin
			insert into orden_pedido (idc_orden_pedido, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
			id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar, numero_po)
			select @idc_orden_pedido, 
			cliente_despacho.id_despacho, 
			variedad_flor.id_variedad_flor, 
			grado_flor.id_grado_flor, 
			tipo_caja.id_tipo_caja,
			farm.id_farm, 
			tapa.id_tapa, 
			transportador.id_transportador, 
			tipo_factura.id_tipo_factura, 
			convert(datetime, @fecha_inicial), 
			convert(datetime, @fecha_final),
			@code, 
			@unidades_por_pieza, 
			@cantidad_piezas, 
			@valor_unitario, 
			@comentario, 
			replace(replace(@disponible, 'N', 1), 'S', 0), 
			vendedor.id_vendedor, 
			replace(replace(@comida, 'N', 0), 'S', 1), 
			@upc, 
			convert(datetime,@fecha_vencimiento_flor), 
			convert(datetime,@fecha_creacion_orden), 
			convert(datetime, @fecha_para_aprobar),
			@numero_po
			from cliente_despacho, 
			tipo_flor, 
			variedad_flor, 
			grado_flor, 
			tipo_caja, 
			farm, 
			tapa, 
			transportador, 
			tipo_factura, 
			vendedor
			where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
			and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
			and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
			and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
			and tipo_caja.idc_tipo_caja = @idc_tipo_caja
			and farm.idc_farm = @idc_farm
			and tapa.idc_tapa = @idc_tapa
			and transportador.idc_transportador = @idc_transportador
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			and vendedor.idc_vendedor = @idc_vendedor
			
			declare @id_orden_pedido integer
			set @id_orden_pedido = scope_identity()

			update orden_pedido
			set id_orden_pedido_padre = @id_orden_pedido
			where id_orden_pedido = @id_orden_pedido

			insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
			select transportador.id_transportador, @id_orden_pedido
			from transportador 
			where transportador.idc_transportador = @idc_transportador_anterior
		end
		else
		begin
			declare @id_orden_pedido_padre_1 integer

			select @id_orden_pedido_padre_1 = id_orden_pedido_padre 
			from orden_pedido 
			where convert(int,idc_orden_pedido) = @idc_orden_pedido_padre
			
			insert into orden_pedido (idc_orden_pedido, id_orden_pedido_padre, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
			id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar, numero_po)
			select @idc_orden_pedido, 
			@id_orden_pedido_padre_1, 
			cliente_despacho.id_despacho, 
			variedad_flor.id_variedad_flor, 
			grado_flor.id_grado_flor, 
			tipo_caja.id_tipo_caja,
			farm.id_farm, 
			tapa.id_tapa, 
			transportador.id_transportador, 
			tipo_factura.id_tipo_factura, 
			convert(datetime, @fecha_inicial), 
			convert(datetime, @fecha_final),
			@code, 
			@unidades_por_pieza, 
			@cantidad_piezas, 
			@valor_unitario, 
			@comentario, 
			replace(replace(@disponible, 'N', 1), 'S', 0), 
			vendedor.id_vendedor, 
			replace(replace(@comida, 'N', 0), 'S', 1), 
			@upc, 
			convert(datetime,@fecha_vencimiento_flor), 
			convert(datetime,@fecha_creacion_orden), 
			convert(datetime, @fecha_para_aprobar),
			@numero_po
			from cliente_despacho, 
			tipo_flor, 
			variedad_flor, 
			grado_flor, 
			tipo_caja, 
			farm, 
			tapa, 
			transportador, 
			tipo_factura, 
			vendedor
			where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
			and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
			and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
			and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
			and tipo_caja.idc_tipo_caja = @idc_tipo_caja
			and farm.idc_farm = @idc_farm
			and tapa.idc_tapa = @idc_tapa
			and transportador.idc_transportador = @idc_transportador
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			and vendedor.idc_vendedor = @idc_vendedor

			select @conteo_transportador = count(*)
			from orden_pedido,
			historia_transportador_orden_pedido,
			transportador 
			where orden_pedido.id_orden_pedido_padre = historia_transportador_orden_pedido.id_orden_pedido
			and orden_pedido.id_orden_pedido_padre = @id_orden_pedido_padre_1
			and transportador.id_transportador = historia_transportador_orden_pedido.id_transportador
			and transportador.idc_transportador = @idc_transportador_anterior
			and exists
			(
				select *
				from #temp
				where historia_transportador_orden_pedido.id_historia_transportador_orden_pedido = #temp.id_historia_transportador_orden_pedido
			)

			if(@conteo_transportador = 0)
			begin
				insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
				select transportador.id_transportador, orden_pedido.id_orden_pedido_padre
				from orden_pedido,
				transportador 
				where orden_pedido.id_orden_pedido_padre = @id_orden_pedido_padre_1
				and transportador.idc_transportador = @idc_transportador_anterior
			end
		end
	end
	
	drop table #temp
end
else
IF (@accion = 'borrar')
begin
	IF(@idc_orden_pedido in (select convert(int,idc_orden_pedido) from item_reporte_cambio_orden_pedido))	
	begin
		update orden_pedido
		set disponible = 0
		where convert(int,idc_orden_pedido) = @idc_orden_pedido	
	end
	ELSE
	begin
		select @conteo = count(*)
		from orden_pedido
		where convert(int,orden_pedido.idc_orden_pedido) = @idc_orden_pedido
		and orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido_padre

		if(@conteo = 1)
		begin
			delete from historia_transportador_orden_pedido
			where id_orden_pedido = 
			(
				select orden_pedido.id_orden_pedido
				from orden_pedido
				where convert(int,orden_pedido.idc_orden_pedido) = @idc_orden_pedido	
			)

			delete from orden_pedido 
			where convert(int,idc_orden_pedido) = @idc_orden_pedido
		end
		else
		begin
			delete from orden_pedido 
			where convert(int,idc_orden_pedido) = @idc_orden_pedido
		end
	end
end