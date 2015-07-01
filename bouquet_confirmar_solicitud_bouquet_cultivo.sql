USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_confirmar_solicitud_bouquet_cultivo]    Script Date: 20/08/2014 3:51:38 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/23
-- Description:	Trae informacion de solicitudes de Bouquets desde las comercializadoras
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_confirmar_solicitud_bouquet_cultivo] 

@accion nvarchar(255),
@usuario_cobol nvarchar(25),
@id_solicitud_confirmacion_cultivo int,
@aceptada bit, 
@cantidad_piezas int,
@observacion nvarchar(1024),
@idc_farm nvarchar(2),
@idc_capuchon nvarchar(10) = null,
@idc_pedido_pepr nvarchar(25) = null

as

if(@accion = 'insertar_confirmacion')
begin
	begin try
		insert into confirmacion_bouquet (id_solicitud_confirmacion_cultivo, aceptada, observacion, usuario_cobol, cantidad_piezas, idc_capuchon, idc_pedido_pepr)
		values (@id_solicitud_confirmacion_cultivo, @aceptada, @observacion, @usuario_cobol, @cantidad_piezas, @idc_capuchon, @idc_pedido_pepr)

		select scope_identity() as id_confirmacion_bouquet
	end try
	begin catch
		select -1 as id_confirmacion_bouquet
	end catch
end
else
if(@accion = 'consultar_solicitudes')
begin
	exec bd_fresca.bd_fresca.dbo.bouquet_consultar_solicitudes_desde_cultivo
	@idc_farm_aux = @idc_farm
end
else
if(@accion = 'consultar_pendientes_transmitir')
begin
	select id_confirmacion_bouquet,
	id_solicitud_confirmacion_cultivo,
	cantidad_piezas,
	aceptada,
	observacion,
	usuario_cobol,
	fecha_transaccion,
	isnull(idc_capuchon, '') as idc_capuchon,
	isnull(idc_pedido_pepr, '') as idc_pedido_pepr
	from confirmacion_bouquet
	where transmitida = 0
	order by id_solicitud_confirmacion_cultivo
end