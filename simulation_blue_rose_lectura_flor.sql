ALTER PROCEDURE [dbo].[simulation_blue_rose_lectura_flor]

@accion nvarchar(50),
@id_imagen_flor int,
@imagen image,
@id_temperatura_flor int,
@temperatura decimal(20,4),
@id_cuenta_interna int,
@numero_prueba int

AS

declare @conteo int,
@ruta_imagen nvarchar(1024)

set @ruta_imagen = '~/images/fotosbluerose/Simulation1/foto'

if(@accion = 'consultar')
begin
	select lectura_flor.id_lectura_flor,
	dia.nombre_dia,
	ubicacion_flor.nombre_ubicacion_flor,
	cadena_frio.nombre_cadena_frio,
	@ruta_imagen +  convert(nvarchar, imagen_flor.id_imagen_flor) as ruta_imagen,
	imagen_flor.id_imagen_flor,
	imagen_flor.imagen,
	(
		select nombre 
		from cuenta_interna
		where imagen_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	) as usuario_carga_imagen,
	imagen_flor.fecha_carga_imagen, 
	temperatura_flor.id_temperatura_flor,
	temperatura_flor.temperatura,
	(
		select nombre 
		from cuenta_interna
		where temperatura_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	) as usuario_modifica_temperatura,
	temperatura_flor.fecha_lectura
	from lectura_flor,
	dia,
	ubicacion_flor,
	cadena_frio,
	imagen_flor,
	temperatura_flor,
	prueba
	where lectura_flor.id_dia = dia.id_dia
	and lectura_flor.id_ubicacion_flor = ubicacion_flor.id_ubicacion_flor
	and lectura_flor.id_cadena_frio = cadena_frio.id_cadena_frio
	and lectura_flor.id_imagen_flor = imagen_flor.id_imagen_flor
	and lectura_flor.id_temperatura_flor = temperatura_flor.id_temperatura_flor
	and lectura_flor.id_prueba = prueba.id_prueba
	and prueba.numero_prueba = @numero_prueba
	order by dia.id_dia
end
else
if(@accion = 'modificar')
begin
	if(@imagen is not null)
	begin	
		select @conteo = count(*)
		from imagen_flor
		where dbo.compara_imagenes(imagen, datalength(imagen)) = dbo.compara_imagenes(@imagen, datalength(@imagen))
		and id_imagen_flor = @id_imagen_flor

		if(@conteo = 0)
		begin
			update imagen_flor
			set imagen = @imagen,
			fecha_carga_imagen = getdate(),
			id_cuenta_interna = @id_cuenta_interna
			where imagen_flor.id_imagen_flor = @id_imagen_flor
		end
	end

	set @conteo = null

	select @conteo = count(*)
	from temperatura_flor
	where temperatura = @temperatura
	and id_temperatura_flor = @id_temperatura_flor

	if(@conteo = 0)
	begin
		update temperatura_flor
		set temperatura = @temperatura,
		fecha_lectura = getdate(),
		id_cuenta_interna = @id_cuenta_interna
		where temperatura_flor.id_temperatura_flor = @id_temperatura_flor
	end
end