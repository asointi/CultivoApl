set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_editar_capuchon_cobol]

@accion nvarchar(50),
@idc_capuchon nvarchar(255),
@descripcion nvarchar(255),
@ancho_superior decimal(20,4),
@ancho_inferior decimal(20,4),
@alto decimal(20,4),
@decorado bit,
@idc_temporada_capuchon nvarchar(255),
@nombre_temporada_capuchon nvarchar(255)

AS

declare @conteo int

IF (@accion = 'editar_capuchon')
BEGIN
	select @conteo = count(*) from capuchon
	where idc_capuchon = @idc_capuchon
	
	if(@conteo = 0)
	begin
		INSERT INTO capuchon
		(
		idc_capuchon,
		descripcion,
		ancho_superior,
		ancho_inferior,
		alto,
		decorado,
		id_temporada_capuchon
		)
		select 
		@idc_capuchon,
		@descripcion,
		@ancho_superior,
		@ancho_inferior,
		@alto,
		@decorado,
		temporada_capuchon.id_temporada_capuchon
		from
		temporada_capuchon
		where idc_temporada_capuchon = @idc_temporada_capuchon
	end
	else
	begin
   		UPDATE capuchon 
		SET	descripcion = @descripcion,
		ancho_superior = @ancho_superior,
		ancho_inferior = @ancho_inferior,
		alto = @alto,
		decorado = @decorado,
		id_temporada_capuchon = temporada_capuchon.id_temporada_capuchon
		from temporada_capuchon
		WHERE idc_capuchon = @idc_capuchon
		and temporada_capuchon.idc_temporada_capuchon = @idc_temporada_capuchon
	end
END
ELSE
IF (@accion = 'editar_temporada_capuchon')
BEGIN
	select @conteo = count(*) from temporada_capuchon
	where idc_temporada_capuchon = @idc_temporada_capuchon
	
	if(@conteo = 0)
	begin
		INSERT INTO temporada_capuchon
		(
			idc_temporada_capuchon,
			nombre_temporada_capuchon
		)
		values
		( 
			@idc_temporada_capuchon,
			@nombre_temporada_capuchon
		)
	end
	else
	begin
   		UPDATE temporada_capuchon 
		SET	nombre_temporada_capuchon = @nombre_temporada_capuchon
		from temporada_capuchon
		WHERE idc_temporada_capuchon = @idc_temporada_capuchon
	end
END
ELSE 
IF (@accion = 'consultar_capuchon')
BEGIN
	SELECT capuchon.id_capuchon,
	capuchon.idc_capuchon,
	capuchon.descripcion,
	capuchon.ancho_superior,
	capuchon.ancho_inferior,
	capuchon.alto,
	capuchon.decorado,
	temporada_capuchon.idc_temporada_capuchon,
	temporada_capuchon.nombre_temporada_capuchon
	FROM capuchon,
	temporada_capuchon
	where capuchon.id_temporada_capuchon = temporada_capuchon.id_temporada_capuchon 
	and capuchon.disponible = 1
	ORDER BY capuchon.descripcion
END
ELSE 
IF (@accion = 'consultar_temporada_capuchon')
BEGIN
	SELECT temporada_capuchon.id_temporada_capuchon,
	temporada_capuchon.idc_temporada_capuchon,
	temporada_capuchon.nombre_temporada_capuchon
	FROM temporada_capuchon
	ORDER BY temporada_capuchon.nombre_temporada_capuchon
END