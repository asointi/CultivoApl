alter PROCEDURE [dbo].[na_editar_apertura]

@accion NVARCHAR(255),
@nombre_apertura nvarchar(255), 
@apertura_minima decimal (20,4), 
@apertura_maxima decimal (20,4),
@id_apertura int

AS
declare @conteo int

if(@accion = 'consultar')
begin
	select 
	id_apertura,
	nombre_apertura,
	apertura_minima,
	apertura_maxima 
	from apertura
	order by nombre_apertura
end
else
if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from apertura
	where ltrim(rtrim(apertura.nombre_apertura)) = ltrim(rtrim(@nombre_apertura))
	
	if(@conteo = 0)
	begin
		insert into apertura (nombre_apertura, apertura_minima, apertura_maxima)
		values (@nombre_apertura, @apertura_minima, @apertura_maxima)
			
		declare @id_aperura_aux int

		set @id_aperura_aux = scope_identity()

		select @id_aperura_aux as result
	end
	else
	begin
		select -2 as result
	end
end
else
if(@accion = 'eliminar')
begin
	select @conteo = count(*)
	from regla,
	apertura
	where apertura.id_apertura = regla.id_apertura
	and apertura.id_apertura = @id_apertura

	if(@conteo = 0)
	begin
		delete from apertura
		where apertura.id_apertura = @id_apertura

		select 1 as result
	end
	else
	begin
		select -3 as result
	end
end
else
if(@accion = 'modificar')
begin
	select @conteo = count(*)
	from apertura
	where ltrim(rtrim(apertura.nombre_apertura)) = ltrim(rtrim(@nombre_apertura))
	and apertura.id_apertura <> @id_apertura
	
	if(@conteo = 0)
	begin
		update apertura
		set nombre_apertura = @nombre_apertura,
		apertura_minima = @apertura_minima,
		apertura_maxima = @apertura_maxima
		where id_apertura = @id_apertura	

		select 1 as result
	end
	else
	begin
		select -2 as result
	end
end