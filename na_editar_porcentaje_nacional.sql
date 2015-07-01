set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_porcentaje_nacional]

@accion nvarchar(255),
@valor decimal(20,4), 
@fecha datetime

as

if(@accion = 'insertar')
begin
	declare @conteo int

	select @conteo = count(*) 
	from porcentaje_nacional
	where fecha = @fecha

	if(@conteo = 0)
	begin
		insert into porcentaje_nacional (valor, fecha)
		values (@valor, @fecha)
	end
	else
	begin
		update porcentaje_nacional
		set valor = @valor,
		fecha_transaccion = getdate()
		where fecha = @fecha
	end
end
else
if(@accion = 'consultar')
begin
	select id_porcentaje_nacional,
	valor,
	fecha,
	fecha_transaccion
	from porcentaje_nacional
	where fecha = @fecha
end