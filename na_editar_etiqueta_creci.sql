/****** Object:  StoredProcedure [dbo].[ped_ordenes_pedido_por_cliente]    Script Date: 03/14/2008 12:29:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_editar_etiqueta_creci]

@idc_etiqueta nvarchar(255), 
@idc_creci nvarchar(255)

AS
begin try
	insert into etiqueta_creci (etiqueta, creci, fecha)
	values (@idc_etiqueta, @idc_creci, getdate())
	select 1 as valor
end try
BEGIN CATCH
	insert into (mensaje)
	select 'na_editar_etiqueta_creci: ' + ', ' +
	'@idc_etiqueta: ' + @idc_etiqueta + ', ' +
	'@idc_creci: ' + @idc_creci + ', ' +
	ERROR_MESSAGE()

	select 0 as valor
END CATCH