SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_caja]

@accion nvarchar(255),
@idc_caja nvarchar(255)

AS

if(@accion = 'consultar')
begin
	select caja.nombre_caja,
	tipo_caja.idc_tipo_caja,
	caja.idc_caja,
	caja.medida,
	caja.codigo_armellini,
	caja.disponible,
	caja_asignada.idc_caja_asignada
	from tipo_caja,
	caja left join caja_asignada on caja.id_caja_asignada = caja_asignada.id_caja_asignada
	where tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.disponible = 1
	and tipo_caja.idc_tipo_caja + caja.idc_caja > = 
	case
		when @idc_caja = '' then '%%'
		else @idc_caja
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja < = 
	case
		when @idc_caja = '' then 'ZZ'
		else @idc_caja
	end
end


