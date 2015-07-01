/****** Object:  StoredProcedure [dbo].[awb_consultar_piezas_de_guia]    Script Date: 10/06/2007 10:56:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[hext_editar_salida_general_area]

@accion nvarchar(255),
@id_salida_general int,
@id_salida_general_area int,
@nombre_salida nvarchar(255),
@fecha datetime,
@@control int output

AS

set language us_english

if(@accion = 'consultar')
begin
	select id_salida_general_area, 
	nombre_salida, 
	fecha_hora, 
	left(convert(nvarchar,fecha_hora,108),5) as hora
	from salida_general_area
	where id_salida_general = @id_salida_general
end
else
if(@accion = 'insertar')
begin
	if(convert(nvarchar,@fecha,101) > = convert(nvarchar,getdate(),101))
	begin
		if(convert(nvarchar,@fecha,101) + ltrim(rtrim(@nombre_salida)) not in (select convert(nvarchar,fecha_hora,101) + ltrim(rtrim(nombre_salida)) from salida_general_area))
		begin
			insert into salida_general_area (id_salida_general, nombre_salida, fecha_hora)
			values (@id_salida_general, @nombre_salida, @fecha)
		end
		else
		begin
			set @@control = -6
			return @@control
		end
	end
	else
	begin
		set @@control = -5
		return @@control
	end
end
else
if(@accion = 'modificar')
begin
	update salida_general_area
	set nombre_salida = @nombre_salida,
	fecha_hora = @fecha
	where id_salida_general_area = @id_salida_general_area
end
else
if(@accion = 'eliminar')
begin
	if((select convert(nvarchar,fecha_hora,101) from salida_general_area where id_salida_general_area = @id_salida_general_area) > =  convert(nvarchar,getdate(),101))
	begin
		delete from salida_general_area 
		where id_salida_general_area = @id_salida_general_area
		and convert(nvarchar,fecha_hora,101) > =  convert(nvarchar,getdate(),101)
	end
	else
	begin
		set @@control = -4
		return @@control
	end
end