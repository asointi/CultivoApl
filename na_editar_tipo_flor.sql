set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_tipo_flor]

@accion nvarchar(255),
@idc_tipo_flor nvarchar(255)
AS
        
IF (@accion = 'consultar')
BEGIN
  select idc_variedad_flor,
  ltrim(rtrim(nombre_variedad_flor)) as nombre_variedad_flor,
  idc_color,
  ltrim(rtrim(nombre_color)) as nombre_color
  from tipo_flor,
  variedad_flor,
  color
  where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
  and variedad_flor.id_color = color.id_color
  and tipo_flor.idc_tipo_flor = @idc_tipo_flor
  and dbo.Tipo_Flor.disponible = 1
  and variedad_flor.disponible = 1
  order by nombre_variedad_flor,
  nombre_color
end
else
if(@accion = 'consultar_caja_asignada')
begin
	SELECT id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_caja_asignada
	FROM tipo_flor left join caja_asignada on tipo_flor.id_caja_asignada = caja_asignada.id_caja_asignada
	WHERE /*tipo_flor.disponible = 1
	and*/ idc_tipo_flor > = 
	case
		when @idc_tipo_flor = '' then '%%'
		else @idc_tipo_flor
	end
	and idc_tipo_flor < = 
	case
		when @idc_tipo_flor = '' then 'ZZ'
		else @idc_tipo_flor
	end
end

