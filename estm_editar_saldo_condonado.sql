set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_saldo_condonado]

@id_cuenta_interna int, 
@id_saldo_condonado int,
@fecha datetime,
@accion nvarchar(255),
@@control int output

as

declare @conteo int

if(@accion = 'insertar')
begin
	if(convert(datetime,convert(nvarchar,getdate(),101)) < = @fecha)
	begin
		set @@control = -3
		return @@control
	end
	else
	if((select max(fecha) from saldo_condonado) > @fecha)
	begin
		set @@control = -4
		return @@control
	end
	else
	begin
		select @conteo = count(*) from saldo_condonado where fecha = @fecha
		if(@conteo = 0)
		begin
			insert into saldo_condonado (id_cuenta_interna, fecha)
			values (@id_cuenta_interna, @fecha)
		end
		else
		begin
			set @@control = -2
			return @@control
		end
	end
end
else
if(@accion = 'consultar')
begin
	select top 1 id_saldo_condonado, fecha
	from saldo_condonado
	order by fecha desc
end
else 
if(@accion = 'eliminar')
begin
	delete from saldo_condonado where id_saldo_condonado = @id_saldo_condonado
end