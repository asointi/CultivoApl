alter PROCEDURE [dbo].[simulation_blue_rose_lectura_flor_florero]

@accion nvarchar(50),
@id_lectura_flor int,
@id_imagen_flor int,
@imagen image,
@id_cuenta_interna int

AS

declare @conteo int

if(@accion = 'consultar')
begin
	select dia.nombre_dia,
	imagen_flor.id_imagen_flor,
	imagen_flor.imagen, 
	imagen_flor.fecha_carga_imagen,
	(
		select nombre 
		from cuenta_interna
		where imagen_flor.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	) as usuario_carga_imagen
	from lectura_flor_florero,
	lectura_flor,
	dia,
	imagen_flor
	where lectura_flor_florero.id_prueba = lectura_flor.id_prueba
	and lectura_flor_florero.id_dia = lectura_flor.id_dia
	and lectura_flor_florero.id_ubicacion_flor = lectura_flor.id_ubicacion_flor
	and lectura_flor_florero.id_cadena_frio = lectura_flor.id_cadena_frio
	and lectura_flor.id_lectura_flor = @id_lectura_flor
	and lectura_flor_florero.id_dia_florero = dia.id_dia
	and lectura_flor_florero.id_imagen_flor = imagen_flor.id_imagen_flor
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
end