/****** Object:  StoredProcedure [dbo].[awb_consultar_tablero_guias]    Script Date: 10/06/2007 10:54:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[awb_editar_guias_version4]

@accion nvarchar(255),
@idc_guia nvarchar(50),
@fecha_guia nvarchar(10),
@hora_guia nvarchar(10),
@fecha_salida nvarchar(10),
@hora_salida nvarchar(10),
@fecha_llegada nvarchar(10),
@hora_llegada nvarchar(10),
@fecha_llamada_terminal nvarchar(10),
@hora_llamada_terminal nvarchar(10),
@fecha_llegada_pq nvarchar(10),
@hora_llegada_pq nvarchar(10),
@fecha_llamada_pq nvarchar(10),
@hora_llamada_pq nvarchar(10),
@fecha_paso_pq nvarchar(10),
@hora_paso_pq nvarchar(10),
@nota_pq nvarchar(512),
@vuelos_adelante_para_pq int,
@primer_vuelo bit,
@conductor_camion nvarchar(255),
@fecha_conductor_llega_a_aerolinea nvarchar(10),
@hora_conductor_llega_a_aerolinea nvarchar(10),
@fecha_llegada_vuelo_a_natural nvarchar(10),
@hora_llegada_vuelo_a_natural nvarchar(10),
@temperatura decimal(20,4)

AS

if(@accion = 'consultar')
begin
	select guia.id_guia,
	guia.idc_guia,
	estado_guia.nombre_estado_guia,
	estado_guia.idc_estado_guia,
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
	isnull(guia.fecha_llegada_pq, '') as fecha_llegada_pq,
	isnull(convert(nvarchar, guia.fecha_llegada_pq, 108), '') as hora_llegada_pq,
	isnull(guia.fecha_paso_pq, '') as fecha_paso_pq,
	isnull(convert(nvarchar, guia.fecha_paso_pq, 108), '') as hora_paso_pq,
	isnull(guia.nota_pq, '') as nota_pq,
	isnull(guia.vuelos_adelante_para_pq, '') as vuelos_adelante_para_pq,
	isnull((
		select ciudad.codigo_aeropuerto
		from ciudad
		where guia.id_ciudad = ciudad.id_ciudad
	), '') as codigo_aeropuerto,
	isnull(convert(nvarchar,guia.primer_vuelo),'') as primer_vuelo,
	isnull(guia.conductor_camion, '') as conductor_camion,
	isnull(guia.fecha_conductor_llega_a_aerolinea, '') as fecha_conductor_llega_a_aerolinea,
	isnull(convert(nvarchar, guia.fecha_conductor_llega_a_aerolinea, 108),'') as hora_conductor_llega_a_aerolinea,
	isnull(guia.fecha_llegada_vuelo_a_natural,'') as fecha_llegada_vuelo_a_natural,
	isnull(convert(nvarchar, guia.fecha_llegada_vuelo_a_natural, 108),'') as hora_llegada_vuelo_a_natural,
	isnull(guia.temperatura,0) as temperatura,
	guia.fecha_transaccion
	from guia,
	estado_guia
	where guia.id_estado_guia = estado_guia.id_estado_guia
	and guia.fecha_guia > = (select fecha_corte_guias from configuracion_bd)
	and guia.idc_guia > =
	case
		when @idc_guia = '' then '            '
		else @idc_guia
	end
	and guia.idc_guia < =
	case
		when @idc_guia = '' then 'ZZZZZZZZZZZZ'
		else @idc_guia
	end
	order by guia.fecha_guia desc
end
else
if(@accion = 'actualizar')
begin
	update guia
	set fecha_guia = 
	case
		when @hora_guia = '' then fecha_guia
		else  [dbo].[concatenar_fecha_hora_COBOL] (@fecha_guia, @hora_guia)
	end,
	fecha_salida = 
	case
		when @hora_salida = '' then fecha_salida
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_salida, @hora_salida)
	end,
	fecha_llegada = 
	case
		when @hora_llegada = '' then fecha_llegada
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_llegada, @hora_llegada)
	end,
	fecha_llamada_terminal = 
	case
		when @hora_llamada_terminal = '' then fecha_llamada_terminal
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_llamada_terminal, @hora_llamada_terminal)
	end,
	fecha_llamada_pq = 
	case
		when @hora_llamada_pq = '' then fecha_llamada_pq
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_llamada_pq, @hora_llamada_pq)
	end,
	fecha_paso_pq = 
	case
		when @hora_paso_pq = '' then fecha_paso_pq
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_paso_pq, @hora_paso_pq)
	end,
	nota_pq = @nota_pq,
	vuelos_adelante_para_pq = @vuelos_adelante_para_pq,
	primer_vuelo = @primer_vuelo,
	conductor_camion = @conductor_camion,
	fecha_conductor_llega_a_aerolinea = 
	case
		when @hora_conductor_llega_a_aerolinea = '' then fecha_conductor_llega_a_aerolinea
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_conductor_llega_a_aerolinea, @hora_conductor_llega_a_aerolinea)
	end,
	fecha_llegada_vuelo_a_natural = 
	case
		when @hora_llegada_vuelo_a_natural = '' then fecha_llegada_vuelo_a_natural
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_llegada_vuelo_a_natural, @hora_llegada_vuelo_a_natural)
	end,
	fecha_llegada_pq =
	case
		when @hora_llegada_pq = '' then fecha_llegada_pq
		else [dbo].[concatenar_fecha_hora_COBOL] (@fecha_llegada_pq, @hora_llegada_pq)
	end,
	temperatura = @temperatura,
	fecha_transaccion = GETDATE()
	where guia.idc_guia = @idc_guia
end