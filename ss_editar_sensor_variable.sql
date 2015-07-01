USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[ss_editar_sensor_variable]    Script Date: 10/06/2007 14:06:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ss_editar_sensor_variable]

@accion nvarchar(20),
@id_sensor_variable int,
@id_sensor int,
@id_variable int,
@limite_critico decimal(20,2)

AS
IF @accion = 'insertar'
	BEGIN
		INSERT INTO sensorsoft_sensor_variable
		(
		id_sensor,
		id_variable,
		limite_critico
		)
		VALUES
		(
		@id_sensor,
		@id_variable,
		@limite_critico
		)
	END
ELSE IF @accion = 'modificar'
	BEGIN
		UPDATE sensorsoft_sensor_variable
			SET
		id_variable = @id_variable,
		limite_critico = @limite_critico
		WHERE id_sensor_variable = @id_sensor_variable
	END
ELSE IF @accion = 'eliminar'
	BEGIN
		DELETE sensorsoft_sensor_variable
		WHERE id_sensor_variable = @id_sensor_variable
	END
	
	
