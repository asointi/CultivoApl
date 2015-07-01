/****** Object:  StoredProcedure [dbo].[awb_consultar_tablero_guias]    Script Date: 10/06/2007 10:54:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[awb_editar_guias]

@accion nvarchar(255),
@id_guia int,
@fecha_guia datetime,
@hora_guia nvarchar(10),
@fecha_salida datetime,
@hora_salida nvarchar(10),
@fecha_llegada datetime,
@hora_llegada nvarchar(10),
@fecha_llamada_terminal datetime,
@hora_llamada_terminal nvarchar(10),
@fecha_llamada_pq datetime,
@hora_llamada_pq nvarchar(10),
@fecha_paso_pq datetime,
@hora_paso_pq nvarchar(10),
@nota_pq nvarchar(512),
@vuelos_adelante_para_pq int

AS

if(@accion = 'consultar')
begin
	select guia.id_guia,
	guia.idc_guia,
	estado_guia.nombre_estado_guia,
	isnull(guia.fecha_guia, '') as fecha_guia,
	isnull(convert(nvarchar, guia.fecha_guia, 108), '') as hora_guia,
	isnull(guia.fecha_salida, 0) as fecha_salida,
	isnull(convert(nvarchar, guia.fecha_salida, 108), '') as hora_salida,
	isnull(guia.fecha_llegada, '') as fecha_llegada,
	isnull(convert(nvarchar, guia.fecha_llegada, 108), '') as hora_llegada,
	isnull(guia.fecha_llamada_terminal, '') as fecha_llamada_terminal,
	isnull(convert(nvarchar, guia.fecha_llamada_terminal, 108), '') as hora_llamada_terminal,
	isnull(guia.fecha_llamada_pq, '') as fecha_llamada_pq,
	isnull(convert(nvarchar, guia.fecha_llamada_pq, 108), '') as hora_llamada_pq,
	isnull(guia.fecha_paso_pq, '') as fecha_paso_pq,
	isnull(convert(nvarchar, guia.fecha_paso_pq, 108), '') as hora_paso_pq,
	isnull(guia.nota_pq, '') as nota_pq,
	isnull(guia.vuelos_adelante_para_pq, '') as vuelos_adelante_para_pq,
	isnull((
		select ciudad.codigo_aeropuerto
		from ciudad
		where guia.id_ciudad = ciudad.id_ciudad
	), '') as codigo_aeropuerto
	from guia,
	estado_guia
	where guia.id_estado_guia = estado_guia.id_estado_guia
	and guia.fecha_guia > = (select fecha_corte_guias from configuracion_bd)
	order by guia.fecha_guia desc
end
else
if(@accion = 'actualizar')
begin
	update guia
	set fecha_guia = 
	case
		when @hora_guia = '' then fecha_guia
		else (CAST(CONVERT(char(12),@fecha_guia,113)+(LEFT(@hora_guia, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_guia), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_guia), 5, 2)) AS DATETIME))
	end,
	fecha_salida = 
	case
		when @hora_salida = '' then fecha_salida
		else (CAST(CONVERT(char(12),@fecha_salida,113)+(LEFT(@hora_salida, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_salida), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_salida), 5, 2)) AS DATETIME))
	end,
	fecha_llegada = 
	case
		when @hora_llegada = '' then fecha_llegada
		else (CAST(CONVERT(char(12),@fecha_llegada,113)+(LEFT(@hora_llegada, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_llegada), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_llegada), 5, 2)) AS DATETIME))
	end,
	fecha_llamada_terminal = 
	case
		when @hora_llamada_terminal = '' then fecha_llamada_terminal
		else (CAST(CONVERT(char(12),@fecha_llamada_terminal,113)+(LEFT(@hora_llamada_terminal, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_llamada_terminal), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_llamada_terminal), 5, 2)) AS DATETIME))
	end,
	fecha_llamada_pq = 
	case
		when @hora_llamada_pq = '' then fecha_llamada_pq
		else (CAST(CONVERT(char(12),@fecha_llamada_pq,113)+(LEFT(@hora_llamada_pq, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_llamada_pq), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_llamada_pq), 5, 2)) AS DATETIME))
	end,
	fecha_paso_pq = 
	case
		when @hora_paso_pq = '' then fecha_paso_pq
		else(CAST(CONVERT(char(12),@fecha_paso_pq,113)+(LEFT(@hora_paso_pq, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_paso_pq), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_paso_pq), 5, 2)) AS DATETIME))
	end,
	nota_pq = @nota_pq,
	vuelos_adelante_para_pq = @vuelos_adelante_para_pq
	where guia.id_guia = @id_guia
end