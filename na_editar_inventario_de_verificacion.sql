SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_editar_inventario_de_verificacion]

@accion nvarchar(255),
@codigo nvarchar(255),
@id_verificacion_inventario_direccion_fisica int

as

declare @id int,
@conteo int,
@direccion_actual int, 
@direccion_anterior int,
@consecutivo int

create table #temp
(
	id int identity(1,1),
	id_verificacion_inventario_direccion_fisica int, 
	direccion nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
	id_verificacion_inventario_pieza int, 
	idc_pieza nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
	consecutivo int,
	fecha_lectura datetime,
	cantidad_piezas int,
	cantidad_piezas_decimal int
)

if(@accion = 'consultar')
begin
	insert into #temp (id_verificacion_inventario_direccion_fisica, direccion, id_verificacion_inventario_pieza, idc_pieza, consecutivo, fecha_lectura, cantidad_piezas, cantidad_piezas_decimal)
	select verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica,
	verificacion_inventario_direccion_fisica.direccion,
	verificacion_inventario_pieza.id_verificacion_inventario_pieza,
	pieza.idc_pieza,
	1,
	verificacion_inventario_pieza.fecha_lectura,
	verificacion_inventario_direccion_fisica.cantidad_piezas,
	verificacion_inventario_direccion_fisica.cantidad_piezas_decimal
	from verificacion_inventario_direccion_fisica,
	verificacion_inventario_pieza,
	pieza
	where verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica = verificacion_inventario_pieza.id_verificacion_inventario_direccion_fisica
	and verificacion_inventario_pieza.id_pieza = pieza.id_pieza
	order by verificacion_inventario_direccion_fisica.direccion,
	verificacion_inventario_pieza.id_verificacion_inventario_pieza

	set @id = 2

	select @conteo = count(*) from #temp

	while(@id < = @conteo)
	begin
		set @direccion_actual = null
		set @direccion_anterior = null
		set @consecutivo = null

		select @direccion_actual = id_verificacion_inventario_direccion_fisica from #temp where id = @id
		select @direccion_anterior = id_verificacion_inventario_direccion_fisica from #temp where id = @id - 1
		select @consecutivo = consecutivo from #temp where id = @id - 1

		if(@direccion_actual = @direccion_anterior)
		begin
			update #temp
			set consecutivo = @consecutivo + 1
			where id = @id
		end
		else
		begin
			update #temp
			set consecutivo = 1
			where id = @id
		end

		set @id = @id + 1
	end

	select direccion,
	convert(decimal(20,2), convert(nvarchar,cantidad_piezas) + '.' + convert(nvarchar,cantidad_piezas_decimal)) as fulls,
	idc_pieza,
	consecutivo as posicion,
	fecha_lectura
	from #temp
	order by fecha_lectura desc
end
else
if(@accion = 'consultar_log')
begin
	insert into #temp (id_verificacion_inventario_direccion_fisica, direccion, id_verificacion_inventario_pieza, idc_pieza, consecutivo, fecha_lectura)
	select verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica,
	verificacion_inventario_direccion_fisica.direccion,
	verificacion_inventario_pieza.id_verificacion_inventario_pieza,
	pieza.idc_pieza,
	1,
	verificacion_inventario_pieza.fecha_lectura
	from verificacion_inventario_direccion_fisica,
	verificacion_inventario_pieza,
	pieza
	where verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica = verificacion_inventario_pieza.id_verificacion_inventario_direccion_fisica
	and verificacion_inventario_pieza.id_pieza = pieza.id_pieza
	order by verificacion_inventario_direccion_fisica.direccion,
	verificacion_inventario_pieza.id_verificacion_inventario_pieza

	set @id = 2

	select @conteo = count(*) from #temp

	while(@id < = @conteo)
	begin
		set @direccion_actual = null
		set @direccion_anterior = null
		set @consecutivo = null

		select @direccion_actual = id_verificacion_inventario_direccion_fisica from #temp where id = @id
		select @direccion_anterior = id_verificacion_inventario_direccion_fisica from #temp where id = @id - 1
		select @consecutivo = consecutivo from #temp where id = @id - 1

		if(@direccion_actual = @direccion_anterior)
		begin
			update #temp
			set consecutivo = @consecutivo + 1
			where id = @id
		end
		else
		begin
			update #temp
			set consecutivo = 1
			where id = @id
		end

		set @id = @id + 1
	end

	select #temp.direccion as direccion_grabada,
	#temp.idc_pieza,
	#temp.consecutivo as posicion,
	verificacion_inventario_log.direccion_nueva,
	#temp.fecha_lectura
	from #temp left join verificacion_inventario_log on verificacion_inventario_log.idc_pieza = #temp.idc_pieza
	group by #temp.direccion,
	#temp.idc_pieza,
	#temp.consecutivo,
	verificacion_inventario_log.direccion_nueva,
	#temp.fecha_lectura
	order by 
	#temp.fecha_lectura DESC
end
else
if(@accion = 'borrar')
begin
	/*Inicializar verificacion de inventario*/
	delete from verificacion_inventario_pieza
	delete from verificacion_inventario_direccion_fisica
	delete from verificacion_inventario_log
end
else
begin try
if(@accion = 'insertar')
begin
	set @codigo = SUBSTRING(@codigo, 5, len(@codigo))
	
	/*si el dato leído empieza con este prefijo es una dirección física*/
	if(left(@codigo, 4) = '0000')
	begin
		set @codigo = left(@codigo, len(@codigo)-2)

		select @id = verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica
		from verificacion_inventario_direccion_fisica
		where verificacion_inventario_direccion_fisica.direccion = @codigo		

		/*se verifica que la dirección ingresada no haya sido ingresada con anterioridad*/
		if(@id is null)
		begin
			insert into verificacion_inventario_direccion_fisica (direccion, cantidad_piezas)
			values (@codigo, 0)
			
			set @id = null
			set @id = scope_identity()
		end
		
		select @id as id_verificacion_inventario_direccion_fisica
	end
	else
	if(left(@codigo, 2) = '99')
	begin
		/*se verifica que la pieza venga ligada a una dirección física*/
		if(@id_verificacion_inventario_direccion_fisica is not null)
		begin
			update verificacion_inventario_direccion_fisica
			set cantidad_piezas = convert(int, SUBSTRING(@codigo, 7, 2)),
			cantidad_piezas_decimal = convert(int, SUBSTRING(@codigo, 9, 2))
			where id_verificacion_inventario_direccion_fisica = @id_verificacion_inventario_direccion_fisica
			/*Se adicionó de manera correcta la cantidad de piezas a la dirección del rack ingresado - se envía 5 por que la aplicación verifica para el sonido que el dato enviado sea mayor a 0*/
			
			select 5 as id
		end
		else
		begin
			/*se intento ingresar la cantidad de piezas del rack sin ligarla a una dirección física*/
			select -2 as id
		end
	end
	else
	begin
		/*el dato leído es una pieza*/

		/*se verifica que la pieza venga ligada a una dirección física*/
		if(@id_verificacion_inventario_direccion_fisica is not null)
		begin
			declare @id_pieza int
			set @id = null
			
			select @id_pieza = pieza.id_pieza
			from pieza
			where pieza.idc_pieza = @codigo

			/*se verifica que la pieza leída exista en la tabla de las piezas*/
			if(@id_pieza is not null)
			begin
				select @id = verificacion_inventario_pieza.id_verificacion_inventario_pieza
				from verificacion_inventario_pieza
				where verificacion_inventario_pieza.id_pieza = @id_pieza
				and verificacion_inventario_pieza.id_verificacion_inventario_direccion_fisica = @id_verificacion_inventario_direccion_fisica

				/*se verifica que la pieza y la dirección física no hayan sido leídas con anterioridad*/
				if(@id is null)
				begin
					set @id = null

					select @id = verificacion_inventario_pieza.id_verificacion_inventario_pieza
					from verificacion_inventario_pieza
					where verificacion_inventario_pieza.id_pieza = @id_pieza

					if(@id is null)
					begin
						insert into verificacion_inventario_pieza (id_pieza, id_verificacion_inventario_direccion_fisica)
						values(@id_pieza, @id_verificacion_inventario_direccion_fisica)

						set @id = null
						set @id = scope_identity()
					end
					else
					begin
						insert into verificacion_inventario_log (direccion_grabada, idc_pieza, direccion_nueva)
						select 
						(
							select verificacion_inventario_direccion_fisica.direccion
							from verificacion_inventario_pieza,
							verificacion_inventario_direccion_fisica
							where verificacion_inventario_pieza.id_pieza = @id_pieza
							and verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica = verificacion_inventario_pieza.id_verificacion_inventario_direccion_fisica
						), 
						@codigo, 
						verificacion_inventario_direccion_fisica.direccion
						from verificacion_inventario_direccion_fisica
						where verificacion_inventario_direccion_fisica.id_verificacion_inventario_direccion_fisica = @id_verificacion_inventario_direccion_fisica

						set @id = -3
					end
				end
				else
				begin
					/*si la pieza y la dirección física ya existen únicamente se actualiza la fecha de lectura*/
					update verificacion_inventario_pieza
					set fecha_lectura = getdate()
					where verificacion_inventario_pieza.id_pieza = @id_pieza
					and verificacion_inventario_pieza.id_verificacion_inventario_direccion_fisica = @id_verificacion_inventario_direccion_fisica
				end
				
				/*la pieza fue grabada*/
				select @id as result
			end
			else
			begin
				/*la pieza no existe*/
				select -1 as result
			end			
		end
		else
		begin
			/*se intento ingresar una pieza sin ligarla a una dirección física*/
			select -2 as result
		end
	end
end
end try
begin catch
	select -4 as result
end catch

drop table #temp