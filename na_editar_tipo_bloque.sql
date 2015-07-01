/****** Object:  StoredProcedure [dbo].[gc_editar_cuenta_interna_grupo]    Script Date: 10/06/2007 11:25:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_tipo_bloque]

@id_bloque int,
@id_tipo_bloque nvarchar(255),
@nombre_tipo_bloque nvarchar(255),
@accion nvarchar(255),
@@control int output

AS

declare @conteo int

if(@accion = 'insertar_tipo_bloque')
begin
	if(@id_tipo_bloque is null)
	begin
		select @conteo = count(*) from tipo_bloque
		where nombre_tipo_bloque = @nombre_tipo_bloque
	
		if(@conteo = 0)
		begin
			insert into tipo_bloque (nombre_tipo_bloque)
			values (@nombre_tipo_bloque)

			set @@control = 1
			return @@control 
		end
		else
		begin
			set @@control = -2
			return @@control 
		end
	end
	else
	begin
		select @conteo = count(*) from tipo_bloque
		where nombre_tipo_bloque = @nombre_tipo_bloque
	
		if(@conteo = 0)
		begin
			update tipo_bloque
			set nombre_tipo_bloque = @nombre_tipo_bloque
			where id_tipo_bloque = convert(int,@id_tipo_bloque)
			
			set @@control = 1
			return @@control 
		end
		else
		begin
			set @@control = -2
			return @@control 
		end
	end
end
else
if(@accion = 'consultar_tipo_bloque')
begin
	if(@id_tipo_bloque is null)
		set @id_tipo_bloque = '%%'

	select id_tipo_bloque, nombre_tipo_bloque 
	from tipo_bloque
	where id_tipo_bloque like @id_tipo_bloque
end
else
if(@accion = 'actualizar_tipo_bloque_asignado')
begin
	update bloque
	set id_tipo_bloque = convert(int,@id_tipo_bloque)
	where id_bloque = @id_bloque
end
else
if(@accion = 'consultar_bloque')
begin
	select bloque.id_bloque,
	bloque.idc_bloque,
	tipo_bloque.id_tipo_bloque,
	isnull(tipo_bloque.nombre_tipo_bloque, 'Sin Asignar') as nombre_tipo_bloque
	from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque
	where bloque.disponible = 1
	order by bloque.idc_bloque
end