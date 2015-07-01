/****** Object:  StoredProcedure [dbo].[na_editar_pieza_version2]    Script Date: 09/09/2008 09:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_historia_marca]

@idc_pieza nvarchar(255),
@code nvarchar(255),
@usuario_cobol nvarchar(255),
@id_historia_marca int,
@accion nvarchar(255)

as

declare @id_historia_marca_aux int

if(@accion = 'insertar_marca')
begin
	insert into historia_marca (code, usuario_cobol)
	values (@code, @usuario_cobol)

	set @id_historia_marca_aux = scope_identity()

	select @id_historia_marca_aux as id_historia_marca
end
else
if(@accion = 'insertar_cambio_marca')
begin
	insert into cambio_marca (id_historia_marca, id_pieza)
	select @id_historia_marca, pieza.id_pieza
	from pieza
	where pieza.idc_pieza = @idc_pieza
end
else

if(@accion = 'consultar_marca')
begin
	select count(pieza.id_pieza) as cantidad_piezas,
	historia_marca.code,
	historia_marca.fecha_transaccion,
	convert(nvarchar,historia_marca.fecha_transaccion, 108) as hora_transaccion,
	historia_marca.usuario_cobol 
	from pieza,
	cambio_marca,
	historia_marca
	where pieza.id_pieza = cambio_marca.id_pieza
	and historia_marca.id_historia_marca = cambio_marca.id_historia_marca
	and exists
	(
		select * 
		from consulta_marca_cobol
		where consulta_marca_cobol.idc_pieza = pieza.idc_pieza
		and consulta_marca_cobol.numero_consecutivo = @id_historia_marca
	)
	group by historia_marca.code,
	historia_marca.fecha_transaccion,
	historia_marca.usuario_cobol 
	order by historia_marca.fecha_transaccion desc

	delete from consulta_marca_cobol
	where numero_consecutivo = @id_historia_marca
end