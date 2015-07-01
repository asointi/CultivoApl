set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_composicion_grado_flor]

@accion nvarchar(255),
@nombre_grupo_grado_flor nvarchar(255),
@id_grado_flor int,
@id_grupo_grado_flor nvarchar(255),
@@control int output

as

declare @conteo int,
@id_item int

if(@id_grupo_grado_flor is null)
	set @id_grupo_grado_flor = '%%'

if(@accion = 'consultar_grupo_grado_flor')
begin
	select grupo_grado_flor.id_grupo_grado_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '(' + grado_flor.idc_grado_flor + ')' + ' - ' + '[' + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' + ']' as nombre_grupo_grado_flor
	from grupo_grado_flor, 
	grado_flor, 
	tipo_flor
	where grupo_grado_flor.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	order by nombre_tipo_flor,
	grado_flor.id_grado_flor
end
else
if(@accion = 'insertar_grupo_grado_flor')
begin
	select @conteo = count(*)
	from grupo_grado_flor
	where id_grado_flor = @id_grado_flor

	if(@conteo = 0)
	begin
		insert into grupo_grado_flor (id_grado_flor)
		values (@id_grado_flor)

		set @id_item = scope_identity()

		select @id_item as id_grupo_grado_flor
	end
	else
	begin
		set @@control = -2
		return @@control
	end
end
else
if(@accion = 'consultar_composicion_grado_flor')
begin
	select composicion_grado_flor.id_composicion_grado_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor )) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor )) + space(1) + '(' + grado_flor.idc_grado_flor + ')' as nombre_grado_flor,
	grupo_grado_flor.id_grupo_grado_flor,
	(select ltrim(rtrim(gf.nombre_grado_flor )) + space(1) + '(' + gf.idc_grado_flor + ')' + ' - ' + '[' + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' + ']'
	from grado_flor as gf,
	tipo_flor as tf
	where gf.id_grado_flor = grupo_grado_flor.id_grado_flor
	and tf.id_tipo_flor = gf.id_tipo_flor
	) as nombre_grupo_grado_flor
	from composicion_grado_flor,
	grado_flor,
	grupo_grado_flor,
	tipo_flor
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.id_grado_flor = composicion_grado_flor.id_grado_flor_grado_flor
	and grupo_grado_flor.id_grado_flor = composicion_grado_flor.id_grado_flor_grupo_grado_flor
	and grupo_grado_flor.id_grupo_grado_flor like @id_grupo_grado_flor
	order by nombre_tipo_flor,
	grado_flor.id_grado_flor
end
else
if(@accion = 'insertar_composicion_grado_flor')
begin
	select @conteo = count(*)
	from composicion_grado_flor, 
	grupo_grado_flor
	where grupo_grado_flor.id_grado_flor = composicion_grado_flor.id_grado_flor_grupo_grado_flor
	and grupo_grado_flor.id_grupo_grado_flor = @id_grupo_grado_flor
	and composicion_grado_flor.id_grado_flor_grado_flor = @id_grado_flor

	if(@conteo = 0)
	begin
		insert into composicion_grado_flor (id_grado_flor_grado_flor, id_grado_flor_grupo_grado_flor)
		select @id_grado_flor, grupo_grado_flor.id_grado_flor
		from grupo_grado_flor
		where grupo_grado_flor.id_grupo_grado_flor = @id_grupo_grado_flor

		set @id_item = scope_identity()
		select @id_item as id_composicion_grado_flor
	end
	else
	begin
		set @@control = -2
		return @@control
	end
end
else 
if(@accion = 'eliminar_composicion_grado_flor')
begin
	delete from composicion_grado_flor 
	where id_grado_flor_grado_flor = @id_grado_flor
	and id_grado_flor_grupo_grado_flor = (select id_grado_flor from grupo_grado_flor where id_grupo_grado_flor = convert(int,@id_grupo_grado_flor))
end