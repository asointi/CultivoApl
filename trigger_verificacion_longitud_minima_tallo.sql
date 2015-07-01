set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2009/01/29
-- Description:	utilizado para verificar que los tallos clasificados por rosematic cumplan con la longitud mínima establecida
-- =============================================

ALTER TRIGGER [dbo].[verificacion_longitud_minima_tallo]
   ON  [BD_Cultivo].[dbo].[Tallo_Clasificado]
   after INSERT

AS 
BEGIN
	declare @id_tallo_clasificado int,
	@largo decimal(20,4),
	@largo_minimo decimal(20,4),
	@idc_grado_flor nvarchar(255)

	select @id_tallo_clasificado = max(tallo_clasificado.id_tallo_clasificado)
	from tallo_clasificado

	select @largo = tallo_clasificado.largo,
	@largo_minimo = grado_flor.largo_minimo_clasificacion,
	@idc_grado_flor = grado_flor.idc_grado_flor
	from tallo_clasificado,
	tiempo_ejecucion_detalle_condicion,
	detalle_condicion,
	condicion,
	regla,
	tiempo_ejecucion_regla,
	grado_flor
	where.regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_regla = tiempo_ejecucion_regla.id_regla
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tallo_clasificado.id_tallo_clasificado = @id_tallo_clasificado
	and convert(decimal(20,4),tallo_clasificado.largo) < convert(decimal(20,4),grado_flor.largo_minimo_clasificacion) 

	if(@largo is not null and @largo_minimo is not null)
	begin
		declare @body1 varchar(200)
		declare @subject1 varchar(200)
		set @subject1 = 'Un tallo de grado:' + space(1) + @idc_grado_flor + space(1) + 'con longitud minima de:' + space(1) + convert(nvarchar,@largo_minimo) + space(1) + 'tuvo un largo de:' + space(1) + convert(nvarchar,@largo)
		set @body1 = ''
		EXEC msdb.dbo.sp_send_dbmail @recipients='pedro@natuflora.net;carlos@natuflora.net;dpineros@natuflora.net;ricardo@natuflora.net',
			@subject = @subject1,
			@body = @body1,
			@body_format = 'text';
	end
END