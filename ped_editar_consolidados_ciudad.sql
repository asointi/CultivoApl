set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[ped_editar_consolidados_ciudad]

@accion nvarchar(50),
@id_forma_despacho_ciudad int,
@id_dia_despacho int,
@id_tipo_despacho int,
@id_tipo_factura int,
@id_ciudad int

AS

IF @accion = 'registrar'
BEGIN
	INSERT INTO forma_despacho_ciudad
	(
	id_dia_despacho,
	id_tipo_despacho,
	id_ciudad,
	id_tipo_factura
	)
	VALUES(
	@id_dia_despacho,
	@id_tipo_despacho,
	@id_ciudad,
	@id_tipo_factura
	)
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE forma_despacho_ciudad
	SET id_tipo_despacho = @id_tipo_despacho
	WHERE id_forma_despacho_ciudad = @id_forma_despacho_ciudad
END

ELSE IF @accion = 'eliminar'
BEGIN

	declare @conteo int

	select @conteo = count(*) 
	from forma_despacho_farm, 
	farm,
	ciudad,
	forma_despacho_ciudad
	where forma_despacho_farm.id_farm = farm.id_farm
	and farm.id_ciudad = ciudad.id_ciudad
	and ciudad.id_ciudad = forma_despacho_ciudad.id_ciudad
	and forma_despacho_ciudad.id_forma_despacho_ciudad = @id_forma_despacho_ciudad
	and forma_despacho_ciudad.id_tipo_factura = forma_despacho_farm.id_tipo_factura

	if(@conteo = 0)
	begin
		DELETE forma_despacho_ciudad
		WHERE id_forma_despacho_ciudad = @id_forma_despacho_ciudad
	end
	else
		return -1
END

ELSE IF @accion = 'seleccionar'
BEGIN
	select c.id_ciudad, c.nombre_ciudad,
	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 1
	and f.id_tipo_factura = @id_tipo_factura
	) as id_1,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 1
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_1,

	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 2
	and f.id_tipo_factura = @id_tipo_factura
	) as id_2,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 2
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_2,

	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 3
	and f.id_tipo_factura = @id_tipo_factura
	) as id_3,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 3
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_3,

	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 4
	and f.id_tipo_factura = @id_tipo_factura
	) as id_4,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 4
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_4,

	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 5
	and f.id_tipo_factura = @id_tipo_factura
	) as id_5,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 5
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_5,

	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 6
	and f.id_tipo_factura = @id_tipo_factura
	) as id_6,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 6
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_6,

	(select id_forma_despacho_ciudad
	from forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_dia_despacho = 7
	and f.id_tipo_factura = @id_tipo_factura
	) as id_7,
	(select t.nombre_tipo_despacho
	from tipo_despacho as t, forma_despacho_ciudad as f
	where f.id_ciudad = c.id_ciudad
	and f.id_tipo_despacho = t.id_tipo_despacho
	and f.id_dia_despacho = 7
	and f.id_tipo_factura = @id_tipo_factura
	) as nombre_7
	from ciudad as c, forma_despacho_ciudad as f1
	where f1.id_ciudad = c.id_ciudad
	and c.disponible = 1
	and f1.id_tipo_factura = @id_tipo_factura
	group by c.id_ciudad, c.nombre_ciudad
END


