USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[ss_editar_alerta_pendiente]    Script Date: 10/06/2007 14:04:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ss_editar_alerta_pendiente]
@accion nvarchar(20),
@id_sensor int,
@fecha_lectura datetime,
@esta_pendiente bit

AS

IF @accion = 'insertar'
	BEGIN
		INSERT INTO sensorsoft_alerta_pendiente
		(
		id_sensor,
		fecha_lectura,
		esta_pendiente,
		fecha_actualizacion
		)
		VALUES
		(
		@id_sensor,
		@fecha_lectura,
		@esta_pendiente,
		getdate()
		)
	END
ELSE IF @accion = 'modificar'
	BEGIN
		UPDATE sensorsoft_alerta_pendiente
		SET
		fecha_lectura = @fecha_lectura,
		esta_pendiente = @esta_pendiente,
		fecha_actualizacion = getdate()
		WHERE id_sensor = @id_sensor
		and esta_pendiente=1
	END
