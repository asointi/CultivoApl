/****** Object:  StoredProcedure [dbo].[ped_editar_consolidados]    Script Date: 10/06/2007 12:23:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ped_editar_consolidados_farm]

@accion nvarchar(50),
@id_forma_despacho_farm int,
@id_dia_despacho int,
@id_tipo_despacho int,
@id_farm int,

@id_ciudad int
AS

IF @accion = 'registrar'
BEGIN
	INSERT INTO forma_despacho_farm
	(
	id_dia_despacho,
	id_tipo_despacho,
	id_farm
	)
	VALUES(
	@id_dia_despacho,
	@id_tipo_despacho,
	@id_farm
	)
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE forma_despacho_farm
	SET id_tipo_despacho = @id_tipo_despacho,
	id_farm = @id_farm
	WHERE id_forma_despacho_farm = @id_forma_despacho_farm
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE forma_despacho_farm
	WHERE id_forma_despacho_farm = @id_forma_despacho_farm
END

ELSE IF @accion = 'seleccionar'
BEGIN
	select f.id_farm, f.nombre_farm, c.id_ciudad,
	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 1
	) as id_1,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 1
	) as nombre_1,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 2
	) as id_2,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 2
	) as nombre_2,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 3
	) as id_3,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 3
	) as nombre_3,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 4
	) as id_4,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 4
	) as nombre_4,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 5
	) as id_5,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 5
	) as nombre_5,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 6
	) as id_6,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 6
	) as nombre_6,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 7
	) as id_7,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 7
	) as nombre_7

	from farm as f, forma_despacho_farm as f1, ciudad as c
	where f1.id_farm = f.id_farm
	and f.id_ciudad = c.id_ciudad
	and f.disponible = 1
	and c.id_ciudad = @id_ciudad
	group by f.id_farm, f.nombre_farm, c.id_ciudad

END