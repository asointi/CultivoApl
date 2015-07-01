set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_transportador]

@accion nvarchar(255),
@idc_transportador nvarchar(10), 
@nombre_transportador nvarchar(255), 
@direccion_transportador nvarchar(255), 
@cuenta_transportador nvarchar(255)

as

if(@accion = 'consultar')
begin
	select id_transportador,
	idc_transportador,
	ltrim(rtrim(nombre_transportador)) as nombre_transportador,
	ltrim(rtrim(nombre_transportador)) + ' [' + idc_transportador + ']' as nombre_transportador_compuesto,
	direccion_transportador,
	cuenta_transportador 
	from transportador
	order by idc_transportador
end
else
if(@accion = 'modificar')
begin
	declare @conteo int

	select @conteo = count(*)
	from transportador
	where idc_transportador = @idc_transportador

	if(@conteo = 0)
	begin
		insert into transportador (idc_transportador, nombre_transportador, direccion_transportador, cuenta_transportador)
		values (@idc_transportador, @nombre_transportador, @direccion_transportador, @cuenta_transportador)
	end
	else
	begin
		update transportador
		set nombre_transportador = @nombre_transportador, 
		direccion_transportador = @direccion_transportador, 
		cuenta_transportador = @cuenta_transportador
		where idc_transportador = @idc_transportador
	end
end