set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_tablas_flor]

@idc_tipo_flor nvarchar(255), 
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@nombre_item nvarchar(255),
@compone_bouquet_rosa bit,
@medidas nvarchar(255),
@tabla nvarchar(255),
@accion nvarchar(255)

as

declare @conteo int,
@id_variedad_flor int

if(@tabla = 'tipo_flor')
begin
	select @conteo = count(*)
	from tipo_flor
	where idc_tipo_flor = @idc_tipo_flor

	if(@conteo = 0)
	begin
		insert into tipo_flor (idc_tipo_flor,nombre_tipo_flor,compone_bouquet_rosa)
		values (@idc_tipo_flor,ltrim(rtrim(@nombre_item)),@compone_bouquet_rosa)
	end
	else
	begin
		update tipo_flor
		set nombre_tipo_flor = ltrim(rtrim(@nombre_item)),
		compone_bouquet_rosa = @compone_bouquet_rosa
		where idc_tipo_flor = @idc_tipo_flor
	end
end
else
if(@tabla = 'variedad_flor')
begin
	select @id_variedad_flor = variedad_flor.id_variedad_flor
	from tipo_flor,
	variedad_flor
	where idc_tipo_flor = @idc_tipo_flor
	and idc_variedad_flor = @idc_variedad_flor 
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor

	if(@id_variedad_flor is null)
	begin
		insert into variedad_flor (idc_variedad_flor, id_tipo_flor, nombre_variedad_flor)
		select @idc_variedad_flor,
		tipo_flor.id_tipo_flor,
		ltrim(rtrim(@nombre_item))+ltrim(rtrim(@medidas))
		from tipo_flor 
		where tipo_flor.idc_tipo_flor = @idc_tipo_flor

		set @id_variedad_flor = scope_identity()

		--insert into bd_fresca.bd_fresca.dbo.variedad_flor_cultivo (id_variedad_flor_cultivo, id_tipo_flor_cultivo, idc_variedad_flor, nombre_variedad_flor, disponible)
		insert into bd_fresca.dbo.variedad_flor_cultivo (id_variedad_flor_cultivo, id_tipo_flor_cultivo, idc_variedad_flor, nombre_variedad_flor, disponible)
		select @id_variedad_flor,
		tipo_flor.id_tipo_flor,
		@idc_variedad_flor,
		ltrim(rtrim(@nombre_item))+ltrim(rtrim(@medidas)),
		1
		from tipo_flor 
		where tipo_flor.idc_tipo_flor = @idc_tipo_flor

		select @id_variedad_flor as id_variedad_flor
	end
	else
	begin
		update variedad_flor
		set nombre_variedad_flor = ltrim(rtrim(@nombre_item))+ltrim(rtrim(@medidas))
		from variedad_flor, 
		tipo_flor
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor

		--update bd_fresca.bd_fresca.dbo.variedad_flor_cultivo
		update bd_fresca.dbo.variedad_flor_cultivo
		set nombre_variedad_flor = ltrim(rtrim(@nombre_item))+ltrim(rtrim(@medidas))
		where id_variedad_flor_cultivo = @id_variedad_flor

		select @id_variedad_flor as id_variedad_flor
	end
end
else
if(@tabla = 'grado_flor')
begin
	select @conteo = count(*)
	from tipo_flor,
	grado_flor
	where idc_tipo_flor = @idc_tipo_flor
	and idc_grado_flor = @idc_grado_flor 
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor

	if(@conteo = 0)
	begin
		insert into grado_flor (idc_grado_flor,id_tipo_flor,nombre_grado_flor,medidas)
		select @idc_grado_flor,
		tipo_flor.id_tipo_flor,
		ltrim(rtrim(@nombre_item)),
		@medidas
		from tipo_flor 
		where tipo_flor.idc_tipo_flor = @idc_tipo_flor
	end
	else
	begin
		update grado_flor
		set nombre_grado_flor = ltrim(rtrim(@nombre_item)),
		medidas = @medidas
		from tipo_flor, grado_flor
		where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
	end
end