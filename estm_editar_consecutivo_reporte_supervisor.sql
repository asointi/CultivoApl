set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[estm_editar_consecutivo_reporte_supervisor]

@id_cuenta_interna int,
@id_consecutivo_reporte_supervisor int,
@estado_reporte nvarchar(255),
@accion nvarchar(255)

as

declare @id_item int

if(@accion = 'consultar_consecutivo')
begin
	select id_consecutivo_reporte_supervisor,
	convert(nvarchar,numero_consecutivo) + ' - ' + '[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor))  + space(1) + '(' + convert(nvarchar,grupo_consecutivo.fecha_transaccion,100) + ')' as numero_consecutivo
	from consecutivo_reporte_supervisor,
	supervisor,
	grupo_consecutivo
	where grupo_consecutivo.id_grupo_consecutivo = consecutivo_reporte_supervisor.id_grupo_consecutivo
	and consecutivo_reporte_supervisor.id_supervisor = supervisor.id_supervisor
	and not exists
	(select * from reporte_supervisor_procesado
	where reporte_supervisor_procesado.id_consecutivo_reporte_supervisor = consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor)
	order by consecutivo_reporte_supervisor.numero_consecutivo
end
else
if(@accion = 'insertar_consecutivo_procesado')
begin
	insert into reporte_supervisor_procesado (id_consecutivo_reporte_supervisor, id_cuenta_interna)
	values (@id_consecutivo_reporte_supervisor, @id_cuenta_interna)
end
else
if(@accion = 'consultar_todos_consecutivo')
begin
	select id_consecutivo_reporte_supervisor,
	numero_consecutivo as orden,
	convert(nvarchar,numero_consecutivo) + ' - ' + '(' + '[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) + ')' as numero_consecutivo,
	convert(nvarchar,grupo_consecutivo.fecha_transaccion, 100) as fecha_solicitud into #temp
	from consecutivo_reporte_supervisor,
	supervisor,
	grupo_consecutivo
	where consecutivo_reporte_supervisor.id_supervisor = supervisor.id_supervisor
	and grupo_consecutivo.id_grupo_consecutivo = consecutivo_reporte_supervisor.id_grupo_consecutivo
	
	alter table #temp
	add estado nvarchar(255)

	update #temp
	set estado = 'No Procesado'
	where id_consecutivo_reporte_supervisor not in 
	(
		select id_consecutivo_reporte_supervisor 
		from reporte_supervisor_procesado
	)

	if(@estado_reporte = 'Todos')
	begin	
		select id_consecutivo_reporte_supervisor,
		numero_consecutivo,
		fecha_solicitud
		from #temp
		order by orden
	end
	else
	if(@estado_reporte = 'Procesados')
	begin	
		select id_consecutivo_reporte_supervisor,
		numero_consecutivo,
		fecha_solicitud
		from #temp
		where estado is null
		order by orden
	end
	else
	if(@estado_reporte = 'No Procesados')
	begin	
		select id_consecutivo_reporte_supervisor,
		numero_consecutivo,
		fecha_solicitud
		from #temp
		where estado is not null
		order by orden
	end

	drop table #temp
end