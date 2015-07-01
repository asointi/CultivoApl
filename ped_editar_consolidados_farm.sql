set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ped_editar_consolidados_farm]

@accion nvarchar(50),
@id_forma_despacho_farm int,
@id_dia_despacho int,
@id_tipo_despacho int,
@id_tipo_factura int,
@id_farm int,
@id_ciudad int

AS

IF @accion = 'registrar'
BEGIN
	INSERT INTO forma_despacho_farm
	(
	id_dia_despacho,
	id_tipo_despacho,
	id_farm,
	id_tipo_factura
	)
	VALUES(
	@id_dia_despacho,
	@id_tipo_despacho,
	@id_farm,
	@id_tipo_factura
	)
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE forma_despacho_farm
	SET id_tipo_despacho = @id_tipo_despacho
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
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_1,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 1
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_1,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 2
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_2,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 2
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_2,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 3
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_3,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 3
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_3,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 4
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_4,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 4
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_4,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 5
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_5,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 5
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_5,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 6
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_6,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 6
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_6,

	(select id_forma_despacho_farm
	from forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_dia_despacho = 7
	and fd.id_tipo_factura = @id_tipo_factura
	) as id_7,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_farm as fd
	where fd.id_farm = f.id_farm
	and fd.id_tipo_despacho = t.id_tipo_despacho
	and fd.id_dia_despacho = 7
	and fd.id_tipo_factura = @id_tipo_factura
	) as nombre_7
	from farm as f, forma_despacho_farm as f1, ciudad as c
	where f1.id_farm = f.id_farm
	and f.id_ciudad = c.id_ciudad
	and f.disponible = 1
	and c.id_ciudad = @id_ciudad
	and f1.id_tipo_factura = @id_tipo_factura
	group by f.id_farm, f.nombre_farm, c.id_ciudad

END
