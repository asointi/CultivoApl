set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2009/01/29
-- Description:	utilizado para verificar que los tallos clasificados por rosematic cumplan con las condiciones establecidas
-- =============================================

alter TRIGGER [dbo].[verificacion_condiciones_clasificacion]
   ON  [BD_Cultivo].[dbo].[Tallo_Clasificado]
   after INSERT

AS 
BEGIN
	declare @id_tallo_clasificado int,
	@id_grado_flor int,
	@idc_grado_flor nvarchar(255),
	@idc_grado_flor_aux nvarchar(255),
	@largo_insertado decimal(20,4),
	@ancho_insertado decimal(20,4),
	@alto_cabeza_insertado decimal(20,4),
	@largo decimal(20,4),
	@ancho decimal(20,4),
	@alto decimal(20,4),
	@body1 varchar(200),
	@subject1 varchar(1024),
	@conteo int,
	@tolerancia_largo decimal(20,4),
	@tolerancia_ancho_tallo decimal(20,4),
	@tolerancia_alto decimal(20,4)

	select @tolerancia_largo = tolerancia_largo,
	@tolerancia_ancho_tallo =  tolerancia_ancho_tallo,
	@tolerancia_alto = tolerancia_alto
	from globales_sql

	/*hallar el ultimo registro insertado en la tabla tallo_clasificado*/
	select @id_tallo_clasificado = max(id_tallo_clasificado)
	from tallo_clasificado 

	/*consultar los diferentes parámetros del último registro insertado*/
	select @id_grado_flor = grado_flor.id_grado_flor,
	@idc_grado_flor = grado_flor.idc_grado_flor,
	@largo_insertado = tallo_clasificado.largo,
	@ancho_insertado = tallo_clasificado.ancho,
	@alto_cabeza_insertado = tallo_clasificado.alto_cabeza
	from grado_flor, 
	condicion_clasificacion, 
	tipo_flor,
	tallo_clasificado,
	tiempo_ejecucion_detalle_condicion,
	detalle_condicion,
	condicion
	where grado_flor.id_grado_flor = condicion_clasificacion.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tallo_clasificado.id_tiempo_ejecucion_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_detalle_condicion = detalle_condicion.id_detalle_condicion
	and detalle_condicion.id_condicion = condicion.id_condicion
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tallo_clasificado.id_tallo_clasificado = @id_tallo_clasificado

	/*verificar si existen grados en los que el tallo pueda ser clasificado sobrepasando los mínimos*/
	select @conteo = count(*)
	from condicion_clasificacion,
	grado_flor,
	tipo_flor
	where condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
	and (longitud_minima >  @largo_insertado + @tolerancia_largo 
	or ancho_tallo_minimo >  @ancho_insertado + @tolerancia_ancho_tallo 
	or alto_cabeza_minimo > @alto_cabeza_insertado + @tolerancia_alto)
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_grado_flor = @id_grado_flor
	group by condicion_clasificacion.longitud_minima,
	condicion_clasificacion.ancho_tallo_minimo,
	condicion_clasificacion.alto_cabeza_minimo,
	grado_flor.idc_grado_flor

	/*si la condicion anterior es verdadera*/
	if(@conteo = 1)
	begin
		/*consultar el grado en el cual debe ser clasificado el tallo*/
		select top 1 @largo = condicion_clasificacion.longitud_minima,
		@ancho = condicion_clasificacion.ancho_tallo_minimo,
		@alto = condicion_clasificacion.alto_cabeza_minimo,
		@idc_grado_flor_aux = grado_flor.idc_grado_flor
		from condicion_clasificacion,
		grado_flor,
		tipo_flor
		where condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
		and (longitud_minima < @largo_insertado + @tolerancia_largo
		or ancho_tallo_minimo < @ancho_insertado + @tolerancia_ancho_tallo
		or alto_cabeza_minimo < @alto_cabeza_insertado + @tolerancia_alto )
		and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and grado_flor.id_grado_flor < @id_grado_flor
		order by longitud_minima desc

		/*enviar el mail*/
		insert into log_info (fecha_insercion, mensaje, tipo_mensaje)
		values (getdate(), 'Grado:' + space(1) + @idc_grado_flor + space(1) + 'puede ser clasificado en' + space(1) + @idc_grado_flor_aux + '. Largo:' + space(1) + convert(nvarchar,convert(decimal(20,2),@largo_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@largo)) + ')' + ', ancho:' + space(1) + convert(nvarchar,convert(decimal(20,2),@ancho_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@ancho)) + ')' + ', alto:' + space(1) + convert(nvarchar,convert(decimal(20,2),@alto_cabeza_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@alto)) + ')', 'clasificadora')

--		set @subject1 = 'Grado:' + space(1) + @idc_grado_flor + space(1) + 'puede ser clasificado en' + space(1) + @idc_grado_flor_aux + '. Largo:' + space(1) + convert(nvarchar,convert(decimal(20,2),@largo_insertado)) + ', ancho:' + space(1) + convert(nvarchar,convert(decimal(20,2),@ancho_insertado)) + ', alto:' + space(1) + convert(nvarchar,convert(decimal(20,2),@alto_cabeza_insertado))
--		set @body1 = ''
--		EXEC msdb.dbo.sp_send_dbmail 
--		@recipients='dpineros@natuflora.net;carlos@natuflora.net',
--		@subject = @subject1,
--		@body = @body1,
--		@body_format = 'text';
	end
	else
	begin
		/*verificar si existen grados en los que el tallo pueda ser clasificado sobrepasando los máximos*/
		select @conteo = count(*)
		from condicion_clasificacion,
		grado_flor,
		tipo_flor
		where condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
		and (longitud_minima + @tolerancia_largo < = @largo_insertado
		and ancho_tallo_minimo + @tolerancia_ancho_tallo < = @ancho_insertado
		and alto_cabeza_minimo + @tolerancia_alto < = @alto_cabeza_insertado)
		and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and grado_flor.id_grado_flor > @id_grado_flor
		group by condicion_clasificacion.longitud_minima,
		condicion_clasificacion.ancho_tallo_minimo,
		condicion_clasificacion.alto_cabeza_minimo,
		grado_flor.idc_grado_flor
		
		/*si la condicion anterior es verdadera*/
		if(@conteo = 1)
		begin
			/*consultar el grado en el cual debe ser clasificado el tallo*/
			select top 1 @largo = condicion_clasificacion.longitud_minima,
			@ancho = condicion_clasificacion.ancho_tallo_minimo,
			@alto = condicion_clasificacion.alto_cabeza_minimo,
			@idc_grado_flor_aux = grado_flor.idc_grado_flor
			from condicion_clasificacion,
			grado_flor,
			tipo_flor
			where condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
			and (longitud_minima + @tolerancia_largo < = @largo_insertado
			and ancho_tallo_minimo + @tolerancia_ancho_tallo < = @ancho_insertado
			and alto_cabeza_minimo + @tolerancia_alto < = @alto_cabeza_insertado)
			and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
			and grado_flor.id_grado_flor > @id_grado_flor
			group by condicion_clasificacion.longitud_minima,
			condicion_clasificacion.ancho_tallo_minimo,
			condicion_clasificacion.alto_cabeza_minimo,
			grado_flor.idc_grado_flor
			order by longitud_minima desc

			/*enviar el mail*/
			insert into log_info (fecha_insercion, mensaje, tipo_mensaje)
			values (getdate(), 'Grado:' + space(1) + @idc_grado_flor + space(1) + 'puede ser clasificado en' + space(1) + @idc_grado_flor_aux + '. Largo:' + space(1) + convert(nvarchar,convert(decimal(20,2),@largo_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@largo)) + ')' + ', ancho:' + space(1) + convert(nvarchar,convert(decimal(20,2),@ancho_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@ancho)) + ')' + ', alto:' + space(1) + convert(nvarchar,convert(decimal(20,2),@alto_cabeza_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@alto)) + ')', 'clasificadora')
--			set @subject1 = 'Grado:' + space(1) + @idc_grado_flor + space(1) + 'puede ser clasificado en' + space(1) + @idc_grado_flor_aux + '. Largo:' + space(1) + convert(nvarchar,convert(decimal(20,2),@largo_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@largo)) + ')' + ', ancho:' + space(1) + convert(nvarchar,convert(decimal(20,2),@ancho_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@ancho)) + ')' + ', alto:' + space(1) + convert(nvarchar,convert(decimal(20,2),@alto_cabeza_insertado)) + '('+ convert(nvarchar,convert(decimal(20,2),@alto)) + ')'
--			set @body1 = ''
--			EXEC msdb.dbo.sp_send_dbmail 
--			@recipients='dpineros@natuflora.net;carlos@natuflora.net',
--			@subject = @subject1,
--			@body = @body1,
--			@body_format = 'text';
		end
	end
END