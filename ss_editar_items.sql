USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[ss_editar_items]    Script Date: 10/06/2007 14:05:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ss_editar_items]

@accion nvarchar(20),
@id_item int,
@id_tipo_item int,
@nombre_item nvarchar(255),
@esta_activo bit

AS
IF @accion = 'insertar'
	BEGIN
		INSERT INTO sensorsoft_item
		(
		id_item,
		id_tipo_item,
		nombre_item,
		esta_activo
		)
		VALUES
		(
		@id_item,
		@id_tipo_item,
		@nombre_item,
		@esta_activo
		)
	END
ELSE IF @accion = 'modificar'
	BEGIN
		UPDATE sensorsoft_item
			SET
		id_tipo_item = @id_tipo_item,
		nombre_item = @nombre_item,
		esta_activo = @esta_activo
		WHERE id_item = @id_item
	END
ELSE IF @accion = 'eliminar'
	BEGIN
		DELETE sensorsoft_item
		WHERE id_item = @id_item
	END