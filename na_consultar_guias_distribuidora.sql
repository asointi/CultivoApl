set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_guias_distribuidora]

@fecha_inicial datetime,
@fecha_final datetime,
@distribuidora nvarchar(255),
@idc_tipo_factura_inicial nvarchar(2),
@idc_tipo_factura_final nvarchar(2)

as

if(@distribuidora = 'FRESCA')
begin
	exec bd_fresca.bd_fresca.dbo.na_consultar_guias_fresca_desde_cultivo

	@fecha_inicial_fresca = @fecha_inicial,
	@fecha_final_fresca = @fecha_final,
	@idc_tipo_factura_ini = @idc_tipo_factura_inicial,
	@idc_tipo_factura_fin = @idc_tipo_factura_final
end
else
if(@distribuidora = 'NATURAL')
begin
	exec bd_nf.bd_nf.dbo.na_consultar_guias_natural_desde_cultivo

	@fecha_inicial_natural = @fecha_inicial,
	@fecha_final_natural = @fecha_final,
	@idc_tipo_factura_ini = @idc_tipo_factura_inicial,
	@idc_tipo_factura_fin = @idc_tipo_factura_final
end
else
if(@distribuidora = 'FRESCA_FECHA_FACTURA')
begin
	exec bd_fresca.bd_fresca.dbo.na_consultar_guias_fresca_desde_cultivo_fecha_factura

	@fecha_inicial_fresca = @fecha_inicial,
	@fecha_final_fresca = @fecha_final,
	@idc_tipo_factura_ini = @idc_tipo_factura_inicial,
	@idc_tipo_factura_fin = @idc_tipo_factura_final
end
else
if(@distribuidora = 'NATURAL_FECHA_FACTURA')
begin
	exec bd_nf.bd_nf.dbo.na_consultar_guias_natural_desde_cultivo_fecha_factura

	@fecha_inicial_natural = @fecha_inicial,
	@fecha_final_natural = @fecha_final,
	@idc_tipo_factura_ini = @idc_tipo_factura_inicial,
	@idc_tipo_factura_fin = @idc_tipo_factura_final
end