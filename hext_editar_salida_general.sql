/****** Object:  StoredProcedure [dbo].[awb_consultar_piezas_de_guia]    Script Date: 10/06/2007 10:56:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[hext_editar_salida_general]

@accion nvarchar(255),
@fecha datetime,
@id_salida_general int,
@@control int output

AS

set language us_english
declare @fecha_inicial datetime,
@count int

set @count = 1

set @fecha_inicial = convert(nvarchar,getdate(),101)
set @fecha_inicial = @fecha_inicial - @count
while (@fecha_inicial in (select convert(nvarchar,fecha,101) from dia_no_laboral) or datepart(dw,@fecha_inicial) = 1)
	set @fecha_inicial = @fecha_inicial - @count

if(@accion = 'consultar')
begin
	select id_salida_general, 
	fecha_hora, 
	left(convert(nvarchar,fecha_hora,108),5) as hora
	from salida_general
	where not exists
	(select * 
	from salida_general_procesada
	where salida_general_procesada.id_salida_general = salida_general.id_salida_general)
	and convert(nvarchar,fecha_hora,101) between 
	@fecha_inicial and convert(nvarchar,getdate(),101)
	order by fecha_hora
end
else 
if(@accion = 'insertar')
begin
	if(convert(nvarchar,@fecha,101) > = convert(nvarchar,getdate(),101))
	begin
		if(convert(nvarchar,@fecha,101) not in (select convert(nvarchar,fecha_hora,101) from salida_general))
		begin
			insert into Salida_General (fecha_hora)
			values (@fecha)
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
if(@accion = 'consultar_dia_actual')
begin
	if(convert(nvarchar,getdate(),101) in (select convert(nvarchar,fecha_hora,101) from salida_general))
		select 1 as dia_actual
	else
		select 0 as dia_actual
end
else
if(@accion = 'modificar')
begin
	update salida_general
	set fecha_hora = @fecha
	where id_salida_general = @id_salida_general
end