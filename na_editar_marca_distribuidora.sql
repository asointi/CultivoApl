set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/05/06
-- =============================================

alter PROCEDURE [dbo].[na_editar_marca_distribuidora] 

@accion nvarchar(255),
@code nvarchar(255),
@idc_cliente_despacho nvarchar(255),
@usuario_cobol nvarchar(255)

AS

declare @conteo int,
@id_marca int

if(@accion = 'consultar_cliente_despacho')
begin
	select @conteo = count(marca_asignada.id_marca)
	from marca,
	marca_asignada,
	cliente_despacho
	where marca.id_marca = marca_asignada.id_marca
	and cliente_despacho.id_despacho = marca_asignada.id_despacho
	and marca.code = @code
	
	if(@conteo = 0)
	begin
		select @conteo = count(*) from marca
		where code = @code

		if(@conteo = 0)
		begin
			select -1 as idc_cliente_despacho
		end
		else
		begin
			select replace(asignacion_general, 0, -1) as idc_cliente_despacho
			from marca
			where code = @code
		end
	end
	else
	begin
		select cliente_despacho.idc_cliente_despacho 
		from marca,
		marca_asignada,
		cliente_despacho
		where marca.id_marca = marca_asignada.id_marca
		and cliente_despacho.id_despacho = marca_asignada.id_despacho
		and marca.code = @code
	end
end
else
if(@accion = 'insertar_marca')
begin
	select @conteo = count(marca_asignada.id_marca) 
	from marca,
	marca_asignada
	where marca.code = @code
	and marca.id_marca = marca_asignada.id_marca

	if(@conteo = 0)
	begin
		select @conteo = count(*) 
		from marca
		where code = @code
		
		if(@conteo = 0)
		begin
			insert into marca (code)
			values (@code)

			set @id_marca = scope_identity()

			insert into marca_asignada (id_marca, id_despacho, usuario_cobol)
			select @id_marca, cliente_despacho.id_despacho, @usuario_cobol
			from cliente_despacho
			where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho

			select 1 as result
		end
		else
		begin
			select @id_marca = marca.id_marca
			from marca
			where code = @code			

			insert into marca_asignada (id_marca, id_despacho, usuario_cobol)
			select @id_marca, cliente_despacho.id_despacho, @usuario_cobol
			from cliente_despacho
			where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho

			select 1 as result
		end
		end
	else
	begin
		select 0 as result
	end
end