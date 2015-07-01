set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[bouquet_editar_formula_bouquet] 

@accion nvarchar(50),
@id_bouquet int,
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@id_formula_bouquet int,
@cantidad_tallos int

as

if(@accion = 'consultar')
begin
	select formula_bouquet.id_formula_bouquet,
	formula_bouquet.id_bouquet,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	formula_bouquet.cantidad_tallos 
	from formula_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor
	where formula_bouquet.id_bouquet = @id_bouquet
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = formula_bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = formula_bouquet.id_grado_flor
	order by tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor		
end
else
if(@accion = 'insertar')
begin
	declare @id_variedad_flor int,
	@id_grado_flor int,
	@conteo int

	select @id_variedad_flor = variedad_flor.id_variedad_flor,
	@id_grado_flor = grado_flor.id_grado_flor
	from tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	
	select @conteo = COUNT(*)
	from formula_bouquet
	where formula_bouquet.id_variedad_flor = @id_variedad_flor
	and formula_bouquet.id_grado_flor = @id_grado_flor
	and formula_bouquet.id_bouquet = @id_bouquet

	if(@conteo = 0)
	begin
		insert into formula_bouquet (id_bouquet, id_variedad_flor, id_grado_flor, cantidad_tallos)
		values (@id_bouquet, @id_variedad_flor, @id_grado_flor, @cantidad_tallos)

		select scope_identity() as id_formula_bouquet
	end
	else
	begin
		select -1 as id_formula_bouquet
	end
end
else
if(@accion = 'eliminar')
begin
	delete from formula_bouquet
	where id_formula_bouquet = @id_formula_bouquet
end
else
if(@accion = 'actualizar')
begin
	update formula_bouquet
	set cantidad_tallos = @cantidad_tallos
	where id_formula_bouquet = @id_formula_bouquet
end