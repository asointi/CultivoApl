set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2009/01/29
-- Description:	utilizado para verificar que los tallos clasificados por rosematic cumplan con la longitud mínima establecida
-- =============================================
alter TRIGGER [dbo].[verificacion_alto_cabeza_minima_tallo]
   ON  [BD_Cultivo].[dbo].[Tallo_Clasificado]
   after INSERT

AS 
BEGIN
	declare @id_tallo_clasificado int,
	@alto_cabeza decimal(20,4),
	@alto_cabeza_minima decimal(20,4),
	@eyector int

	set @alto_cabeza_minima = '44.9000'

	select @id_tallo_clasificado = max(tallo_clasificado.id_tallo_clasificado)
	from tallo_clasificado

	select @alto_cabeza = tallo_clasificado.alto_cabeza,
	@eyector = tallo_clasificado.eyector
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
	and convert(decimal(20,4),tallo_clasificado.alto_cabeza) < convert(decimal(20,4),@alto_cabeza_minima) 

	if(@alto_cabeza is not null and @eyector is not null)
	begin
		declare @body1 varchar(200)
		declare @subject1 varchar(512)
		set @subject1 = 'Un tallo con alto de cabeza:' + space(1) + convert(nvarchar,@alto_cabeza) + space(1) + 'salio por el eyector:' + space(1) + convert(nvarchar,@eyector)
		set @body1 = ''
		EXEC msdb.dbo.sp_send_dbmail @recipients='dpineros@natuflora.net',
			@subject = @subject1,
			@body = @body1,
			@body_format = 'text';
	end
END