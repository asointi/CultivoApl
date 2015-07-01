set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_pais_version2]

@accion nvarchar(255),
@id_pais int,
@idc_pais nvarchar(10),
@nombre_pais nvarchar(50),
@idc_farm nvarchar(10),
@imprime_factura bit

AS

declare @conteo int

if(@accion = 'insertar_pais')
begin
	declare @id_pais_aux int 

	select @conteo = count(*)
	from pais 
	where idc_pais = @idc_pais
	or nombre_pais = @nombre_pais

	if(@conteo = 0)
	begin
		insert into pais (idc_pais, nombre_pais, imprime_factura)
		values (@idc_pais, @nombre_pais, @imprime_factura)

		set @id_pais_aux = scope_identity()

		select @id_pais_aux as id_pais
	end
	else
	begin
		select -1 as id_pais
	end
end
else
if(@accion = 'actualizar_pais')
begin
	select @conteo = count(*)
	from pais 
	where (idc_pais = @idc_pais
	or nombre_pais = @nombre_pais)
	and id_pais <> @id_pais

	if(@conteo = 0)
	begin
		update pais 
		set idc_pais = @idc_pais,
		nombre_pais = @nombre_pais,
		imprime_factura = @imprime_factura
		where id_pais = @id_pais

		select 1 as id_pais
	end
	else
	begin
		select -1 as id_pais
	end
end
else
if(@accion = 'eliminar_pais')
begin
	select @conteo = count(*)
	from ciudad,
	pais
	where pais.id_pais = ciudad.id_pais
	and pais.id_pais = @id_pais

	select @conteo = @conteo + count(*)
	from estado,
	pais
	where pais.id_pais = estado.id_pais
	and pais.id_pais = @id_pais

	if(@conteo = 0)
	begin
		delete from pais
		where id_pais = @id_pais

		select 1 as id_pais
	end
	else
	begin
		select -1 as id_pais
	end
end
else
if(@accion = 'consultar_pais')
begin
	select id_pais,
	idc_pais,
	nombre_pais,	
	imprime_factura
	from pais
	order by nombre_pais
end
else
if(@accion = 'consultar_ciudad')
begin
	select ciudad.id_ciudad,
	ciudad.idc_ciudad, 
	ciudad.nombre_ciudad,
	ciudad.codigo_aeropuerto,
	ciudad.impuesto_por_caja,
	pais.id_pais,
	pais.idc_pais,
	pais.nombre_pais + space(1) + '[' + pais.idc_pais + ']' as nombre_pais,
	pais.imprime_factura
	from ciudad left join pais on pais.id_pais = ciudad.id_pais
	where ciudad.disponible = 1
	order by ciudad.nombre_ciudad
end
else
if(@accion = 'consultar_pais_por_finca')
begin
	select idc_pais,
	nombre_pais,
	imprime_factura 
	from pais,
	ciudad,
	farm
	where ciudad.id_ciudad = farm.id_ciudad
	and pais.id_pais = ciudad.id_pais
	and farm.idc_farm = @idc_farm
end
else
if(@accion = 'consultar_estado')
begin
	select estado.id_estado,
	estado.idc_estado, 
	estado.nombre_estado,
	pais.id_pais,
	pais.idc_pais,
	pais.nombre_pais + space(1) + '[' + pais.idc_pais + ']' as nombre_pais,
	pais.imprime_factura
	from estado left join pais on pais.id_pais = estado.id_pais
	order by estado.nombre_estado
end