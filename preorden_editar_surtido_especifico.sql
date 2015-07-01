set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[preorden_editar_surtido_especifico]

@idc_farm nvarchar(5),
@idc_tipo_flor nvarchar(5),
@codigo int,
@comentario nvarchar(512),
@accion nvarchar(255)

as

declare @id_tipo_flor int,
@id_farm int

select @id_tipo_flor = id_tipo_flor from tipo_flor where idc_tipo_flor = @idc_tipo_flor
select @id_farm = id_farm from farm where idc_farm = @idc_farm

if(@accion = 'solicitar_codigo')
begin
	begin try
		declare @codigo_maximo int

		select @codigo_maximo = max(surtido.codigo)
		from surtido
		where id_tipo_flor = @id_tipo_flor
		and id_farm = @id_farm

		if(@codigo_maximo is null)
		begin
			set @codigo_maximo = 1
		end
		else
		begin
			set @codigo_maximo = @codigo_maximo + 1
		end

		insert into surtido (id_farm, id_tipo_flor, codigo, comentario)
		values (@id_farm, @id_tipo_flor, @codigo_maximo, @comentario)
		

		select [dbo].[longitud_codigo_preorden] (@codigo_maximo) as codigo
	end try
	begin catch
		select '0000' as codigo
	end catch
end
else
if(@accion = 'actualizar')
begin
	update surtido
	set comentario = @comentario
	where id_tipo_flor = @id_tipo_flor
	and id_farm = @id_farm
	and codigo = @codigo
end
else
if(@accion = 'consultar')
begin
	select [dbo].[longitud_codigo_preorden] (surtido.codigo) as codigo, surtido.comentario 
	from surtido,
	farm,
	tipo_flor
	where farm.id_farm = surtido.id_farm
	and tipo_flor.id_tipo_flor = surtido.id_tipo_flor
	and farm.id_farm = @id_farm
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	order by surtido.codigo
end
else
if(@accion = 'consultar_comentario')
begin
	select surtido.comentario 
	from surtido,
	farm,
	tipo_flor
	where farm.id_farm = surtido.id_farm
	and tipo_flor.id_tipo_flor = surtido.id_tipo_flor
	and farm.id_farm = @id_farm
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	and surtido.codigo = @codigo
end