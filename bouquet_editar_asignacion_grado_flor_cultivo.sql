set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/23
-- Description:	Maneja informacion de los grados de flor del cultivo asignados a los tipos de flor de la comercializadora
-- =============================================

alter PROCEDURE [dbo].[bouquet_editar_asignacion_grado_flor_cultivo] 

@accion nvarchar(255),
@id_tipo_flor int, 
@id_grado_flor_cultivo int, 
@id_cuenta_interna int,
@id_tipo_flor_grado_flor_cultivo int

as

declare @conteo int

if(@accion = 'insertar')
begin
	begin try
		insert into tipo_flor_grado_flor_cultivo (id_tipo_flor, id_grado_flor_cultivo, id_cuenta_interna)
		values (@id_tipo_flor, @id_grado_flor_cultivo, @id_cuenta_interna)

		select scope_identity() as id_tipo_flor_grado_flor_cultivo
	end try
	begin catch
		select -1 as id_tipo_flor_grado_flor_cultivo
	end catch
end
else
if(@accion = 'modificar')
begin
	select @conteo = count(*)
	from tipo_flor,
	variedad_flor,
	bouquet
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and tipo_flor.id_tipo_flor = @id_tipo_flor

	select @conteo = @conteo + count(*)
	from tipo_flor,
	grado_flor,
	bouquet
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and tipo_flor.id_tipo_flor = @id_tipo_flor

	if(@conteo = 0)
	begin
		update tipo_flor_grado_flor_cultivo
		set id_grado_flor_cultivo = @id_grado_flor_cultivo
		where id_tipo_flor_grado_flor_cultivo = @id_tipo_flor_grado_flor_cultivo

		select @id_tipo_flor_grado_flor_cultivo as id_tipo_flor_grado_flor_cultivo
	end
	else
	begin
		select -1 as id_tipo_flor_grado_flor_cultivo
	end
end
else
if(@accion = 'eliminar')
begin
	select @conteo = count(*)
	from tipo_flor,
	variedad_flor,
	bouquet
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and tipo_flor.id_tipo_flor = @id_tipo_flor

	select @conteo = @conteo + count(*)
	from tipo_flor,
	grado_flor,
	bouquet
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and tipo_flor.id_tipo_flor = @id_tipo_flor

	if(@conteo = 0)
	begin
		delete from tipo_flor_grado_flor_cultivo
		where id_tipo_flor_grado_flor_cultivo = @id_tipo_flor_grado_flor_cultivo

		select @id_tipo_flor_grado_flor_cultivo as id_tipo_flor_grado_flor_cultivo
	end
	else
	begin
		select -1 as id_tipo_flor_grado_flor_cultivo
	end
end
else
if(@accion = 'consultar')
begin
	select tipo_flor_grado_flor_cultivo.id_tipo_flor_grado_flor_cultivo,
	tipo_flor_grado_flor_cultivo.fecha_transaccion,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	grado_flor_cultivo.id_grado_flor_cultivo,
	grado_flor_cultivo.idc_grado_flor,
	ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_grado_flor,
	cuenta_interna.id_cuenta_interna,
	cuenta_interna.nombre as nombre_cuenta_interna
	from tipo_flor_grado_flor_cultivo,
	tipo_flor,
	grado_flor_cultivo,
	cuenta_interna
	where tipo_flor.id_tipo_flor = tipo_flor_grado_flor_cultivo.id_tipo_flor
	and grado_flor_cultivo.id_grado_flor_cultivo = tipo_flor_grado_flor_cultivo.id_grado_flor_cultivo
	and cuenta_interna.id_cuenta_interna = tipo_flor_grado_flor_cultivo.id_cuenta_interna
	order by nombre_tipo_flor
end