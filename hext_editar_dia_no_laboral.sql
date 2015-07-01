/****** Object:  StoredProcedure [dbo].[awb_consultar_piezas_de_guia]    Script Date: 10/06/2007 10:56:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[hext_editar_dia_no_laboral]

@accion nvarchar(255),
@año nvarchar(255),
@mes nvarchar(255),
@fecha datetime, 
@descripcion nvarchar(512),
@id_dia_no_laboral int,
@@control int output

AS
set language spanish

if(@año is null)
	set @año = '%%'
if(@mes is null)
	set @mes = '%%'

if(@accion = 'consultar_filtros')
begin
	if(@año <> '%%')
	begin
		select datename(mm, fecha) as mes
		from dia_no_laboral
		where datepart(yyyy, fecha) like @año
		group by datename(mm, fecha),datepart(mm,fecha)
		order by datepart(mm,fecha)
	end
	else
	begin
		select datepart(yyyy, fecha) as año
		from dia_no_laboral
		group by datepart(yyyy, fecha)
		order by datepart(yyyy, fecha)
	end
end
else
if(@accion = 'consultar_registros')
begin
	select id_dia_no_laboral, 
	fecha, 
	descripcion 
	from dia_no_laboral
	where datepart(yyyy, fecha) like @año
	and datename(mm, fecha) like @mes
	order by fecha
end
else
if(@accion = 'insertar')
begin
	if(@fecha > = getdate())
	begin
		if(@fecha not in (select fecha from dia_no_laboral))
		begin
			insert into dia_no_laboral (fecha, descripcion)
			values (@fecha, @descripcion)
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
if(@accion = 'eliminar')
begin
	delete from dia_no_laboral where id_dia_no_laboral = @id_dia_no_laboral
end
else
if(@accion = 'modificar')
begin
	update dia_no_laboral
	set descripcion = @descripcion
	where id_dia_no_laboral = @id_dia_no_laboral
end	