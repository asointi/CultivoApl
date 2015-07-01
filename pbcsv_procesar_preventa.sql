/****** Object:  StoredProcedure [dbo].[pbcsv_procesar_preventa]    Script Date: 10/06/2007 13:11:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_procesar_preventa]

@Nroofpv_sql integer

AS
	
update item_preventa
set procesado = 1
where id_item_preventa = @Nroofpv_sql