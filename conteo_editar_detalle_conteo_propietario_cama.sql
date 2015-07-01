set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-13
-- Description:	Actualizar unidades estimadas en los conteos a través de subida de archivo Excel
-- =============================================

alter PROCEDURE [dbo].[conteo_editar_detalle_conteo_propietario_cama]

@accion nvarchar(255),
@id_conteo_propietario_cama int,
@id_detalle_conteo_propietario_cama nvarchar(255),
@unidades_estimadas int,
@id_cuenta_interna int,
@conteo_supervisor bit,
@numero_consecutivo int

AS

declare @conteo int,
@id_conteo_propietario_cama_actual int,
@fecha_conteo_actual datetime,
@id_item int

if(@accion = 'reporte_produccion_vs_estimados_correccion')
begin
	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as tallos_estimados_semana_actual,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque as bloque,
	bloque.id_bloque,
	detalle_conteo_propietario_cama.numero_consecutivo,
	conteo_propietario_cama.fecha_conteo
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	persona,
	tipo_flor,
	variedad_flor,
	supervisor,
	bloque
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and supervisor.id_supervisor = persona.id_supervisor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	group by persona.id_persona, 
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	tipo_flor.idc_tipo_flor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	detalle_conteo_propietario_cama.numero_consecutivo,
	conteo_propietario_cama.fecha_conteo
	order by ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	bloque.idc_bloque,
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido))
end
else
if(@accion = 'actualizar_unidades_estimadas')
begin
	/*verifica si el ítem que se desea registrar ya ha sido cargado con anterioridad*/
	select @conteo = count(*)
	from estado_detalle_conteo_propietario_cama,
	detalle_item_conteo_propietario_cama,
	conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.nombre_estado = 'Procesado'
	and detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = convert(int,right(@id_detalle_conteo_propietario_cama, 8))
	and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama

	/*El ítem no ha sido cargado con algún dato de conteo*/
	if(@conteo = 0)
	begin
		/*se verifica que el ítem exista, es decir, que se hayan generado los reportes con los conteos en 0
		para luego cargar los datos una vez diligenciados los formatos*/
		select @conteo = count(*) 
		from detalle_conteo_propietario_cama,
		conteo_propietario_cama
		where detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = convert(int,right(@id_detalle_conteo_propietario_cama, 8))
		and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
		and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama

		/*el ítem existe. El reporte ya fue generado*/
		if(@conteo = 1 )
		begin
			/*Se actualizan las unidades que están en 0 por las que vienen en el archivo*/
			update detalle_conteo_propietario_cama
			set unidades_estimadas = @unidades_estimadas,
			conteo_supervisor = @conteo_supervisor
			from conteo_Propietario_cama
			where detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = convert(int,right(@id_detalle_conteo_propietario_cama, 8))
			and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
			and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama

			/*se inserta un registro informando quien realiza la carga del archivo y pasando al registro
			al estado de Procesado, con lo cual a aprtir de allí se pueden realizar correcciones*/
			insert into detalle_item_conteo_propietario_cama (id_detalle_conteo_propietario_cama, id_estado_detalle_conteo_propietario_cama, id_cuenta_interna)
			select convert(int,right(@id_detalle_conteo_propietario_cama, 8)), estado_detalle_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama, @id_cuenta_interna
			from estado_detalle_conteo_propietario_cama
			where estado_detalle_conteo_propietario_cama.nombre_estado = 'Procesado'
		
			set @id_item = scope_identity()

			select 1 as id_item
		end
		else
		begin
			/*El ítem no existe. No se ha generado reporte*/
			select 0 as id_item
		end
	end
	else
	begin
		/*El ítem ya fue cargado con anterioridad*/
		select 0 as id_item
	end
end
else
if(@accion = 'corregir_unidades_estimadas')
begin
	/*se corrigen los conteos con los datos enviados en el archivo cargado. Lo anterior se puede realizar siempre y cuando
	el registro haya pasado por el estado Procesado con anterioridad*/
	update detalle_conteo_propietario_cama
	set unidades_estimadas = @unidades_estimadas,
	conteo_supervisor = @conteo_supervisor
	from conteo_propietario_cama
	where detalle_conteo_propietario_cama.numero_consecutivo = @numero_consecutivo
	and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
end