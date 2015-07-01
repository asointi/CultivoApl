/*
Este SP se realiza para modificar la información de las guías
a través de WebApplications y no a través de COBOL como se venía 
realizando.

Creado Por: DIEGO PIÑEROS
Fecha Creación: 2011/05/10

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[awb_editar_guias_version2]

@accion nvarchar(255),
@id_guia int,
@fecha_salida datetime,
@fecha_llegada datetime,
@fecha_llamada_terminal datetime,
@fecha_llamada_pq datetime,
@fecha_paso_pq datetime,
@nota_pq nvarchar(512),
@vuelos_adelante_para_pq int

AS

if(@accion = 'actualizar')
begin
	update guia
	SET fecha_salida = 
	case
		when @fecha_salida is null then guia.fecha_salida
		else @fecha_salida
	end,
	fecha_llegada = 
	case
		when @fecha_llegada is null then guia.fecha_llegada
		else @fecha_llegada
	end,
	fecha_llamada_terminal = 
	case
		when @fecha_llamada_terminal is null then guia.fecha_llamada_terminal
		else @fecha_llamada_terminal
	end,
	fecha_llamada_pq = 
	case
		when @fecha_llamada_pq is null then guia.fecha_llamada_pq
		else @fecha_llamada_pq
	end,
	fecha_paso_pq = 
	case
		when @fecha_paso_pq is null then guia.fecha_paso_pq
		else @fecha_paso_pq
	end,
	nota_pq = 
	case
		when @nota_pq is null then guia.nota_pq
		else @nota_pq
	end,
	vuelos_adelante_para_pq = 
	case
		when @vuelos_adelante_para_pq is null then guia.vuelos_adelante_para_pq
		else @vuelos_adelante_para_pq
	end
	where guia.id_guia = @id_guia
end