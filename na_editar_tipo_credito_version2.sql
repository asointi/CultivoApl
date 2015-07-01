create PROCEDURE [dbo].[na_editar_tipo_credito_version2]

@idc_tipo_credito nvarchar(10),
@accion nvarchar(255),
@descripcion nvarchar(1024),
@nombre_tipo_credito nvarchar(255)

AS

if(@accion = 'modificar')
begin
	declare @conteo int,
	@id int

	select @conteo = count(*)
	from tipo_credito
	where idc_tipo_credito = @idc_tipo_credito

	if(@conteo = 0)
	begin
		begin try
			insert into tipo_credito (idc_tipo_credito, nombre_tipo_credito, descripcion, disponible)
			values (@idc_tipo_credito, @nombre_tipo_credito, @descripcion, 1)

			set @id = scope_identity()
			select @id as id_tipo_credito
		end try
		begin catch
			select -1 as id_tipo_credito
		end catch
	end
	else
	begin
		begin try
			update tipo_credito
			set descripcion = @descripcion,
			nombre_tipo_credito = @nombre_tipo_credito
			where idc_tipo_credito = @idc_tipo_credito

			select id_tipo_credito
			from tipo_credito
			where idc_tipo_credito = @idc_tipo_credito
		end try
		begin catch
			select -1 as id_tipo_credito
		end catch
	end
end
else
if(@accion = 'consultar')
begin
	select id_tipo_credito,
	idc_tipo_credito,
	ltrim(rtrim(nombre_tipo_credito)) as nombre_tipo_credito,
	descripcion
	from tipo_credito
	where idc_tipo_credito > =
	case
		when @idc_tipo_credito = '' then '%%'
		else @idc_tipo_credito
	end 
	and idc_tipo_credito < =
	case
		when @idc_tipo_credito = '' then 'ZZ'
		else @idc_tipo_credito
	end 
	order by nombre_tipo_credito
end