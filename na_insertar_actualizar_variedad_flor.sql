/****** Object:  StoredProcedure [dbo].[na_insertar_actualizar_variedad_flor]    Script Date: 10/06/2007 12:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_insertar_actualizar_variedad_flor]

@idc_tipo_flor nvarchar(255), 
@idc_variedad_flor nvarchar(255), 
@nombre_variedad_flor nvarchar(255), 
@idc_color nvarchar(255)

AS
BEGIN
	if(@idc_tipo_flor+@idc_variedad_flor in (select idc_tipo_flor+idc_variedad_flor from tipo_flor, variedad_flor where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor))
	begin
		update variedad_flor
		set nombre_variedad_flor = @nombre_variedad_flor,
		id_color = color.id_color
		from color, tipo_flor, variedad_flor
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and idc_tipo_flor+idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
		and color.idc_color = @idc_color
	end

	else
	begin
		insert into variedad_flor (idc_variedad_flor,id_tipo_flor,id_color,nombre_variedad_flor)
		select @idc_variedad_flor,tipo_flor.id_tipo_flor,color.id_color,@nombre_variedad_flor
		from tipo_flor, color
		where tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and color.idc_color = @idc_color
	end
END
