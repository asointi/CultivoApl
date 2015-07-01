/****** Object:  StoredProcedure [dbo].[fs_editar_flora_stats_registro]    Script Date: 10/06/2007 11:20:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[fs_editar_flora_stats_registro]

@accion nvarchar(20),
@id_flora_stats_registro int,
@id_variedad_flor int,
@id_grado_flor int,
@id_flora_stats int

AS
IF @accion = 'consultar'
BEGIN
	SELECT t.id_tipo_flor, t.nombre_tipo_flor, v.nombre_variedad_flor, g.nombre_grado_flor, r.*
	FROM flora_stats_registro as r, tipo_flor as t, variedad_flor as v, grado_flor as g 
	WHERE r.id_flora_stats = @id_flora_stats
	and r.id_variedad_flor = v.id_variedad_flor
	and v.id_tipo_flor = t.id_tipo_flor
	and r.id_grado_flor = g.id_grado_flor                                       
	ORDER BY t.nombre_tipo_flor
END

ELSE IF @accion = 'registrar'
BEGIN
	
	INSERT INTO Flora_Stats_Registro
		(
		id_variedad_flor,
		id_grado_flor,
		id_flora_stats
		)
	VALUES(
		@id_variedad_flor,
		@id_grado_flor,
		@id_flora_stats
	)
	return scope_identity()
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE Flora_Stats_Registro
	SET
		id_variedad_flor = @id_variedad_flor,
		id_grado_flor = @id_grado_flor
	WHERE id_flora_stats_registro = @id_flora_stats_registro
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE flora_stats_registro
	WHERE id_flora_stats_registro = @id_flora_stats_registro

END
