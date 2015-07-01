USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[ss_editar_sensores]    Script Date: 10/06/2007 14:07:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[ss_editar_sensores]

@accion nvarchar(20),
@id_sensor int,
@id_item int,
@item_description nvarchar(255)

AS
IF @accion = 'insertar'
	BEGIN
		INSERT INTO sensorsoft_sensor
		(
		id_item,
		item_description
		)
		VALUES
		(
		@id_item,
		@item_description
		)
	END
ELSE IF @accion = 'modificar'
	BEGIN
		UPDATE sensorsoft_sensor
			SET
		item_description= @item_description
		WHERE id_sensor = @id_sensor
	END
ELSE IF @accion = 'eliminar'
	BEGIN
		delete sensorsoft_alerta_pendiente
		WHERE id_sensor = @id_sensor

		DELETE sensorsoft_sensor
		WHERE id_sensor = @id_sensor
	END
	
