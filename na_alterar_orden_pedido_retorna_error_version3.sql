/****** Object:  StoredProcedure [dbo].[na_alterar_orden_pedido]    Script Date: 11/13/2007 12:49:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_alterar_orden_pedido_retorna_error_version3]

@idc_orden_pedido nvarchar(20),
@idc_cliente_despacho nvarchar(20),
@idc_tipo_flor nvarchar(10),
@idc_variedad_flor nvarchar(10),
@idc_grado_flor nvarchar(10), 
@idc_tipo_caja nvarchar(10),
@idc_farm nvarchar(10), 
@idc_tapa nvarchar(10), 
@idc_transportador nvarchar(10),
@idc_tipo_factura nvarchar(10),
@fecha_inicial nvarchar(20), 
@fecha_final nvarchar(20), 
@code nvarchar(10),
@unidades_por_pieza integer,
@cantidad_piezas integer,
@valor_unitario decimal(20,4), 
@disponible nvarchar(10), 
@idc_orden_pedido_padre nvarchar(20),
@accion nvarchar(50),
@idc_vendedor nvarchar(20),
@comida nvarchar(20),
@upc nvarchar(50),
@fecha_vencimiento_flor nvarchar(20),
@fecha_creacion_orden nvarchar(20),
@fecha_para_aprobar nvarchar(20),
@idc_transportador_anterior nvarchar(10),
@numero_po nvarchar(30),
@idc_cliente_corporativo nvarchar(15),
@id_marca_encabezado_bouquet int

AS

BEGIN TRY
	declare @id_orden_pedido int,
	@conteo int,
	@idc_orden_pedido_padre_revision nvarchar(20),
	@idc_orden_pedido_revision nvarchar(20),
	@id_vendedor int,
	@idc_transportador_aux nvarchar(10),
	@id_historia_transportador_orden_pedido int,
	@id_cliente_corporativo int

	select @id_cliente_corporativo = cliente_corporativo.id_cliente_corporativo
	from cliente_corporativo
	where cliente_corporativo.idc_cliente_corporativo = @idc_cliente_corporativo


	IF(@fecha_para_aprobar = '')
		set @fecha_para_aprobar = null

	IF(@fecha_vencimiento_flor = '')
		set @fecha_vencimiento_flor = null

	select @id_vendedor = vendedor.id_vendedor
	from vendedor
	where vendedor.id_vendedor =
	case
		when @idc_vendedor = '' then (select id_vendedor_global from configuracion_bd)
		else (select id_vendedor from vendedor where idc_vendedor = @idc_vendedor)
	end

	set @idc_tipo_caja = left(@idc_tipo_caja,1)
	set @idc_orden_pedido = convert(int,@idc_orden_pedido)
	set @idc_orden_pedido_padre = convert(int, @idc_orden_pedido_padre)
	set @idc_orden_pedido_padre_revision = @idc_orden_pedido_padre
	set @idc_orden_pedido_revision = @idc_orden_pedido

	select @id_orden_pedido = orden_pedido.id_orden_pedido
	from orden_pedido
	where convert(int,orden_pedido.idc_orden_pedido) = @idc_orden_pedido

	IF(@accion = 'modificar')
	begin
		/*La orden ya existe*/
		IF (@id_orden_pedido is not null)
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
			disponible = replace(replace(@disponible, 'N', 1), 'S', 0),
			id_vendedor = @id_vendedor,
			comida = replace(replace(@comida, 'N', 0), 'S', 1),
			upc = @upc,
			fecha_vencimiento_flor = convert(datetime,@fecha_vencimiento_flor),
			fecha_creacion_orden = convert(datetime,@fecha_creacion_orden),
			fecha_para_aprobar = convert(datetime, @fecha_para_aprobar),
			numero_po = @numero_po
			from cliente_despacho, 
			tipo_flor, 
			variedad_flor, 
			grado_flor, 
			tipo_caja, 
			farm, 
			tapa, 
			transportador, 
			tipo_factura
			where orden_pedido.id_orden_pedido = @id_orden_pedido 
			and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
			and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
			and tipo_flor.idc_tipo_flor = @idc_tipo_flor
			and variedad_flor.idc_variedad_flor = @idc_variedad_flor			
			and grado_flor.idc_grado_flor = @idc_grado_flor
			and tipo_caja.idc_tipo_caja = @idc_tipo_caja
			and farm.idc_farm = @idc_farm
			and tapa.idc_tapa = @idc_tapa
			and transportador.idc_transportador = @idc_transportador
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura

			select @id_historia_transportador_orden_pedido = max(historia_transportador_orden_pedido.id_historia_transportador_orden_pedido)
			from historia_transportador_orden_pedido
			where historia_transportador_orden_pedido.id_orden_pedido = @id_orden_pedido

			select @idc_transportador_aux = transportador.idc_transportador
			from transportador,
			historia_transportador_orden_pedido
			where transportador.id_transportador = historia_transportador_orden_pedido.id_transportador
			and historia_transportador_orden_pedido.id_historia_transportador_orden_pedido = @id_historia_transportador_orden_pedido

			if(@id_cliente_corporativo is not null)
			begin
				insert into cliente_corporativo_orden_pedido (id_orden_pedido, id_cliente_corporativo)
				values (@id_orden_pedido, @id_cliente_corporativo)			
			end

			if(@idc_transportador_aux <> @idc_transportador_anterior)
			begin
				insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
				select transportador.id_transportador, @id_orden_pedido
				from transportador 
				where transportador.idc_transportador = @idc_transportador_anterior
			end

			select @id_orden_pedido as id_orden_pedido,
			'' as error
		end
		/*La orden no existe*/
		else
			begin
				insert into orden_pedido 
				(
					idc_orden_pedido, 
					id_despacho, 
					id_variedad_flor, 
					id_grado_flor, 
					id_tipo_caja, 
					id_farm, 
					id_tapa,
					id_transportador, 
					id_tipo_factura, 
					fecha_inicial, 
					fecha_final, 
					marca, 
					unidades_por_pieza, 
					cantidad_piezas, 
					valor_unitario, 
					disponible, 
					id_vendedor, 
					comida, 
					upc, 
					fecha_vencimiento_flor, 
					fecha_creacion_orden, 
					fecha_para_aprobar, 
					numero_po
				)
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
				replace(replace(@disponible, 'N', 1), 'S', 0), 
				@id_vendedor, 
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
				tipo_factura
				where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho	
				and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
				and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor				
				and tipo_flor.idc_tipo_flor = @idc_tipo_flor
				and variedad_flor.idc_variedad_flor = @idc_variedad_flor
				and grado_flor.idc_grado_flor = @idc_grado_flor
				and tipo_caja.idc_tipo_caja = @idc_tipo_caja
				and farm.idc_farm = @idc_farm
				and tapa.idc_tapa = @idc_tapa
				and transportador.idc_transportador = @idc_transportador
				and tipo_factura.idc_tipo_factura = @idc_tipo_factura
				
				declare @id_orden_pedido_1 int
				set @id_orden_pedido_1 = scope_identity()

				update orden_pedido
				set id_orden_pedido_padre = 
				case
					when @idc_orden_pedido_padre = 0 then @id_orden_pedido_1
					else (select id_orden_pedido_padre from orden_pedido where idc_orden_pedido = @idc_orden_pedido_padre)
				end
				where orden_pedido.id_orden_pedido = @id_orden_pedido_1

				insert into historia_transportador_orden_pedido (id_transportador, id_orden_pedido)
				select transportador.id_transportador, @id_orden_pedido_1
				from transportador 
				where transportador.idc_transportador = @idc_transportador_anterior

				if(@id_cliente_corporativo is not null)
				begin
					insert into cliente_corporativo_orden_pedido (id_orden_pedido, id_cliente_corporativo)
					values (@id_orden_pedido_1, @id_cliente_corporativo)			
				end

				if(@id_marca_encabezado_bouquet > 0)
				begin
					insert into marca_orden_pedido (id_orden_pedido, id_marca, id_grado_flor, id_variedad_flor, id_farm, id_tipo_caja, id_tapa, unidades)
					select @id_orden_pedido_1,
					marca_encabezado_bouquet.id_marca,
					marca_encabezado_bouquet.id_grado_flor, 
					marca_encabezado_bouquet.id_variedad_flor, 
					marca_encabezado_bouquet.id_farm, 
					marca_encabezado_bouquet.id_tipo_caja, 
					marca_encabezado_bouquet.id_tapa, 
					marca_encabezado_bouquet.unidades
					from marca_encabezado_bouquet
					where marca_encabezado_bouquet.id_marca_encabezado_bouquet = @id_marca_encabezado_bouquet	
				end

				/*Se llama al SP que revisa si la orden padre ingresada ya ha sido utilizada con anterioridad*/

				if(@idc_tipo_factura = '9' and convert(int,@idc_orden_pedido_padre_revision) > 0)
				begin
					exec	na_consulta_orden_pedido_llaveantofpv_proceso_automatico
							@idc_orden_pedido_padre = @idc_orden_pedido_padre_revision,
							@idc_orden_pedido = @idc_orden_pedido_revision
				end

				select @id_orden_pedido_1 as id_orden_pedido,
				'' as error	
			end
	end
	else
	IF (@accion = 'borrar')
	begin
		select @conteo = count(*)
		from item_reporte_cambio_orden_pedido
		where item_reporte_cambio_orden_pedido.id_orden_pedido = @id_orden_pedido

		IF(@conteo is not null)	
		begin
			update orden_pedido
			set disponible = 0
			where id_orden_pedido = @id_orden_pedido	
		end
		ELSE
		begin
			delete from orden_pedido 
			where id_orden_pedido = @id_orden_pedido
		end
	end
END TRY
BEGIN CATCH
	SELECT 0 as id_orden_pedido,
	ERROR_MESSAGE() as error
END CATCH