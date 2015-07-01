SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bancos_consultar_existencia_datos_sql] 

@accion nvarchar(255),
@idc_concepto nvarchar(255),
@idc_transaccion_bancaria nvarchar(255)

AS

if(@accion = 'consultar_concepto')
begin
	select count(*) as cantidad 
	from concepto_contable
	where concepto_contable.idc_concepto = @idc_concepto
end
else
if(@accion = 'consultar_transaccion')
begin
	select count(*) as cantidad 
	from transaccion_bancaria
	where transaccion_bancaria.idc_transaccion_bancaria = @idc_transaccion_bancaria
end
else
if(@accion = 'consultar_listado_concepto')
begin
	select concepto_contable.id_concepto,
	concepto_contable.idc_concepto,
	ltrim(rtrim(concepto_contable.descripcion)) as descripcion
	from concepto_contable
	order by descripcion
end