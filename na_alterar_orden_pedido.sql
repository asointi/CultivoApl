/****** Object:  StoredProcedure [dbo].[na_alterar_orden_pedido]    Script Date: 11/13/2007 12:49:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_alterar_orden_pedido]

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
@fecha_para_aprobar nvarchar(255)


AS
BEGIN
	insert into log_info
	values(getdate(), 
	'@idc_orden_pedido: '+@idc_orden_pedido+space(1)+
	'@idc_cliente_despacho: '+@idc_cliente_despacho+space(1)+
	'@idc_tipo_flor: '+@idc_tipo_flor+space(1)+
	'@idc_variedad_flor: '+@idc_variedad_flor+space(1)+
	'@idc_grado_flor: '+@idc_grado_flor+space(1)+
	'@idc_tipo_caja: '+@idc_tipo_caja+space(1)+
	'@idc_farm: '+@idc_farm+space(1)+ 
	'@idc_tapa: '+@idc_tapa+space(1)+
	'@idc_transportador: '+@idc_transportador+space(1)+
	'@idc_tipo_factura: '+@idc_tipo_factura+space(1)+
	'@fecha_inicial: '+@fecha_inicial+space(1)+
	'@fecha_final: '+@fecha_final+space(1)+
	'@code: '+@code+space(1)+
	'@unidades_por_pieza: '+convert(nvarchar,@unidades_por_pieza)+space(1)+
	'@cantidad_piezas: '+convert(nvarchar,@cantidad_piezas)+space(1)+
	'@valor_unitario: '+convert(nvarchar,@valor_unitario)+space(1)+
	'@comentario: '+@comentario+space(1)+
	'@disponible: '+@disponible+space(1)+
	'@idc_orden_pedido_padre: '+@idc_orden_pedido_padre+space(1)+
	'@accion: '+@accion+space(1)+
	'@idc_vendedor: '+@idc_vendedor+space(1)+
	'@comida: '+@comida+space(1)+
	'@upc: '+@upc+space(1)+
	'@fecha_vencimiento_flor: '+@fecha_vencimiento_flor+space(1)+
	'@fecha_creacion_orden: '+@fecha_creacion_orden+space(1)+
	'@fecha_para_aprobar: '+@fecha_para_aprobar,
	'utilizacion_procedimiento_cobol'
	)

BEGIN TRY



	SELECT CONVERT(DATETIME, @fecha_creacion_orden)

	IF(@fecha_para_aprobar = '')
		set @fecha_para_aprobar = null

	IF(@fecha_vencimiento_flor = '')
		set @fecha_vencimiento_flor = null

	set @idc_tipo_caja = left(@idc_tipo_caja,1)

	set @idc_orden_pedido = convert(int,@idc_orden_pedido)

	set @idc_orden_pedido_padre = convert(int, @idc_orden_pedido_padre)

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
				fecha_para_aprobar = convert(datetime, @fecha_para_aprobar)
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
			end
			else
				begin
					if(@idc_orden_pedido_padre = 0)
					begin
						insert into orden_pedido (idc_orden_pedido, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
						id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar)
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
						convert(datetime, @fecha_para_aprobar)
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
					end
					else
					begin
						declare @id_orden_pedido_padre integer

						select @id_orden_pedido_padre = id_orden_pedido_padre 
						from orden_pedido 
						where convert(int,idc_orden_pedido) = @idc_orden_pedido_padre
						
						insert into orden_pedido (idc_orden_pedido, id_orden_pedido_padre, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
						id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar)
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
						convert(datetime, @fecha_para_aprobar)
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
			fecha_para_aprobar = convert(datetime, @fecha_para_aprobar)
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
		end
		else
		begin
			if(@idc_orden_pedido_padre = 0)
			begin
				insert into orden_pedido (idc_orden_pedido, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
				id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar)
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
				convert(datetime, @fecha_para_aprobar)
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
			end
			else
			begin
				declare @id_orden_pedido_padre_1 integer

				select @id_orden_pedido_padre_1 = id_orden_pedido_padre 
				from orden_pedido 
				where convert(int,idc_orden_pedido) = @idc_orden_pedido_padre
				
				insert into orden_pedido (idc_orden_pedido, id_orden_pedido_padre, id_despacho, id_variedad_flor, id_grado_flor, id_tipo_caja, id_farm, id_tapa,
				id_transportador, id_tipo_factura, fecha_inicial, fecha_final, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario, disponible, id_vendedor, comida, upc, fecha_vencimiento_flor, fecha_creacion_orden, fecha_para_aprobar)
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
				convert(datetime, @fecha_para_aprobar)
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
			end
		end
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
			delete from orden_pedido 
			where convert(int,idc_orden_pedido) = @idc_orden_pedido
		end
	end
	
	return 0
END TRY
BEGIN CATCH
	RETURN 1	
END CATCH
END