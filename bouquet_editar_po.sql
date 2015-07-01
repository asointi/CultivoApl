USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_editar_po]    Script Date: 11/12/2014 9:07:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/12
-- Description:	Maneja informacion de la tabla PO
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_editar_po] 

@id_transportador int, 
@id_despacho int, 
@id_cuenta_interna int, 
@po_number nvarchar(255), 
@fecha_despacho_miami datetime, 
@fecha_emision datetime, 
@fecha_delivery datetime, 
@fecha_vuelo datetime,
@id_po int,
@accion nvarchar(255),
@id_vendedor int,
@fecha datetime,
@fecha_inicial datetime = null,
@fecha_final datetime = null,
@numero_solicitud int = null

as

set language spanish

if(@accion = 'insertar_po')
begin
	create table #id_po
	(
		id_po int
	)

	set @fecha_inicial = getdate();

    MERGE dbo.PO AS target
    USING (SELECT @id_po, @id_transportador, @id_despacho, @id_cuenta_interna, @po_number, @fecha_despacho_miami, @fecha_emision, @fecha_delivery, @fecha_inicial, @fecha_vuelo, @numero_solicitud) AS source (id_po,id_transportador,id_despacho,id_cuenta_interna,po_number,fecha_despacho_miami,fecha_emision,delivery_day,fecha_transaccion,fecha_vuelo_original,numero_solicitud)
	ON 
	(
		target.id_transportador = source.id_transportador 
		and target.id_despacho = source.id_despacho
		and target.po_number = source.po_number 
		and target.fecha_despacho_miami = source.fecha_despacho_miami 
		and target.numero_solicitud = source.numero_solicitud
	)
    WHEN MATCHED THEN 
        
	update set id_transportador = source.id_transportador, 
	id_cuenta_interna = source.id_cuenta_interna, 
	po_number = source.po_number, 
	fecha_despacho_miami = source.fecha_despacho_miami, 
	fecha_emision = source.fecha_emision, 
	delivery_day = source.delivery_day, 
	fecha_vuelo_original = source.fecha_vuelo_original,
	numero_solicitud = source.numero_solicitud,
	fecha_transaccion = source.fecha_transaccion

	WHEN NOT MATCHED THEN

    INSERT values (source.id_transportador,source.id_despacho,source.id_cuenta_interna,source.po_number,source.fecha_despacho_miami,source.fecha_emision,source.delivery_day,source.fecha_transaccion,source.fecha_vuelo_original,source.numero_solicitud)
    
	output inserted.id_po into #id_po;

	select top 1 id_po, 0 as requiere_precio_retail, 0 as requiere_upc_date from #id_po

	drop table #id_po
end
else
if(@accion = 'actualizar_po')
begin
	update po
	set id_transportador = @id_transportador, 
	id_cuenta_interna = @id_cuenta_interna, 
	po_number = @po_number, 
	fecha_despacho_miami = @fecha_despacho_miami, 
	fecha_emision = @fecha_emision, 
	delivery_day = @fecha_delivery, 
	fecha_vuelo_original = @fecha_vuelo,
	numero_solicitud = @numero_solicitud
	where id_po = @id_po

	select @id_po as id_po
end
else
if(@accion = 'eliminar_po')
begin
	declare @conteo int

	select @conteo = count(*)
	from po,
	detalle_po
	where po.id_po = detalle_po.id_po
	and po.id_po = @id_po

	if(@conteo = 0)
	begin
		delete from po
		where id_po = @id_po

		select 1 as id_po
	end
	else
	begin
		select -1 as id_po
	end
end
else
if(@accion = 'consultar_po')
begin
	select max(id_detalle_po) as id_detalle_po into #detalle_po_maximo
	from detalle_po
	group by id_detalle_po_padre

	if(@fecha is null)
	BEGIN
		set @fecha =  '20001231'
	END
	ELSE		
	BEGIN
		set @fecha_inicial = @fecha
		set @fecha_final = dateadd(dd, 30, @fecha)
	END
	
	if(@fecha_inicial is null)
		set @fecha_inicial = '20001231'

	if(@fecha_final is null)
		set @fecha_final = '20501231'

	select cliente_despacho.idc_cliente_despacho,
	transportador.idc_transportador,
	transportador.nombre_transportador,
	po.id_po,
	po.po_number,
	po.numero_solicitud,
	po.fecha_despacho_miami,
	po.fecha_emision,
	po.delivery_day as fecha_delivery,
	convert(datetime, convert(nvarchar, po.fecha_transaccion, 103)) as fecha_transaccion,
	datepart(dw, po.fecha_vuelo_original) as dia_fecha_vuelo,
	po.fecha_vuelo_original as fecha_vuelo,
	cliente_factura.idc_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente_despacho,
	ltrim(rtrim(cliente_despacho.contacto)) as contacto,
	ltrim(rtrim(cliente_despacho.direccion)) as direccion,
	ltrim(rtrim(cliente_despacho.ciudad)) as ciudad,
	ltrim(rtrim(cliente_despacho.estado)) as estado,
	cliente_despacho.telefono,
	cliente_despacho.fax,
	[dbo].[consultar_estado_PO] (po.id_po) as status,
	vendedor.id_vendedor,
	vendedor.idc_vendedor + ' [' + ltrim(rtrim(vendedor.nombre)) + ']' as nombre_vendedor,
	cliente_despacho.id_despacho,
	0 as borrar,
	isnull(cliente_despacho.requiere_precio_retail, 0) as requiere_precio_retail,
	isnull(cliente_despacho.requiere_upc_date, 0) as requiere_upc_date,
	isnull((
		select sum(detalle_po.cantidad_piezas)
		from detalle_po
		where po.id_po = detalle_po.id_po
		and exists
		(
			select *
			from #detalle_po_maximo
			where detalle_po.id_detalle_po = #detalle_po_maximo.id_detalle_po
		)
	),0) as cantidad_piezas into #resultado
	from po,
	transportador,
	cliente_despacho,
	cliente_factura,
	vendedor
	where cliente_despacho.id_despacho = po.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and transportador.id_transportador = po.id_transportador
	and fecha_despacho_miami > = @fecha
	and fecha_despacho_miami > = @fecha_inicial
	and fecha_despacho_miami < = @fecha_final

	select top 50 idc_cliente_despacho,
	idc_transportador,
	nombre_transportador,
	id_po,
	po_number,
	numero_solicitud,
	fecha_despacho_miami,
	fecha_emision,
	fecha_delivery,
	fecha_transaccion,
	dia_fecha_vuelo,
	fecha_vuelo,
	idc_cliente_factura,
	nombre_cliente_despacho,
	contacto,
	direccion,
	ciudad,
	estado,
	telefono,
	fax,
	status,
	id_vendedor,
	nombre_vendedor,
	id_despacho,
	case
		when status = '' then 0
		when status = 'Without Farm' then 0
		when status = 'Without Recipe' then 0
		when status = 'Not Sent to Farm' then 0
		else 1
	end as borrar,
	requiere_precio_retail,
	requiere_upc_date,
	cantidad_piezas
	from #resultado
	order by numero_solicitud desc

	select id_vendedor,
	nombre_vendedor
	from #resultado
	group by id_vendedor,
	nombre_vendedor
	order by nombre_vendedor

	select id_despacho,
	ltrim(rtrim(idc_cliente_despacho)) + ' [' + ltrim(rtrim(nombre_cliente_despacho)) + ']' as nombre_cliente
	from #resultado
	group by id_despacho,
	ltrim(rtrim(idc_cliente_despacho)),
	ltrim(rtrim(nombre_cliente_despacho))
	order by nombre_cliente

	drop table #resultado
	drop table #detalle_po_maximo	
end