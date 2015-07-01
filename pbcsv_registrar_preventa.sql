/****** Object:  StoredProcedure [dbo].[pbcsv_registrar_preventa]    Script Date: 10/06/2007 13:21:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_registrar_preventa]
@fecha_despacho datetime, 
@id_cuenta_interna integer, 
@id_grupo_cliente integer

AS
	
insert into Preventa_Archivo (fecha_despacho, id_grupo_cliente, id_cuenta_interna)
values (@fecha_despacho, @id_grupo_cliente, @id_cuenta_interna)
return scope_identity()