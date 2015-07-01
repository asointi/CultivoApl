/****** Object:  StoredProcedure [dbo].[fs_editar_flora_stats]    Script Date: 10/06/2007 11:18:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[fs_editar_flora_stats]
@accion nvarchar(20),
@id_flora_stats int,
@id_packaging int,
@numero_flora_stats int,
@nombre_flora_stats_flower nvarchar(255),
@nombre_flora_stats_grade nvarchar(255),
@nombre_flora_stats_color nvarchar(255)

AS
IF @accion = 'consultar'
BEGIN
	SELECT f.*, p.nombre_packaging 
    FROM flora_stats as f, flora_stats_packaging as p 
    WHERE f.id_packaging = p.id_packaging
    ORDER BY numero_flora_stats 
END

ELSE IF @accion = 'registrar'
BEGIN
 	DECLARE @next int, @id int, @numero int

	SELECT @next = MAX(numero_flora_stats) 
	FROM flora_stats
	
	IF @next IS NULL
		SET @next = 1
	ELSE 
		SET @next = @next + 1
	
	
	INSERT INTO flora_stats
		(
		numero_flora_stats,
		id_packaging,
		nombre_flora_stats_flower,
		nombre_flora_stats_grade,
		nombre_flora_stats_color
		)
	VALUES(
		@next,
		@id_packaging,
		@nombre_flora_stats_flower,
		@nombre_flora_stats_grade,
		@nombre_flora_stats_color
	)
	return scope_identity()
END

ELSE IF @accion = 'modificar'
BEGIN
	IF @numero_flora_stats > 0 AND @numero_flora_stats <= (SELECT MAX(numero_flora_stats) FROM flora_stats)
	BEGIN
		DECLARE @old int
		--selecciono actual numero
		SELECT @old = numero_flora_stats 
		FROM flora_stats
		WHERE id_flora_stats = @id_flora_stats

		IF @numero_flora_stats > @old
		BEGIN
			DECLARE fs_cursor CURSOR FOR 
				SELECT id_flora_stats, numero_flora_stats 
				FROM flora_stats 
				WHERE numero_flora_stats > @old
						and numero_flora_stats <= @numero_flora_stats

			OPEN fs_cursor
				FETCH NEXT FROM fs_cursor 
				INTO @id, @numero

				WHILE @@FETCH_STATUS = 0
				BEGIN
					UPDATE flora_stats
						SET numero_flora_stats = @numero - 1
					WHERE id_flora_stats = @id
					-- Get the next numero
					FETCH NEXT FROM fs_cursor 
					INTO @id, @numero
				END 
			CLOSE fs_cursor
			DEALLOCATE fs_cursor
		END
		ELSE IF @numero_flora_stats < @old
		BEGIN
			DECLARE fs_cursor CURSOR FOR 
				SELECT id_flora_stats, numero_flora_stats 
				FROM flora_stats 
				WHERE numero_flora_stats >= @numero_flora_stats
				and numero_flora_stats < @old

			OPEN fs_cursor
				FETCH NEXT FROM fs_cursor 
				INTO @id, @numero

				WHILE @@FETCH_STATUS = 0
				BEGIN
					UPDATE flora_stats
						SET numero_flora_stats = @numero + 1
					WHERE id_flora_stats = @id
					-- Get the next numero
					FETCH NEXT FROM fs_cursor 
					INTO @id, @numero
				END 
			CLOSE fs_cursor
			DEALLOCATE fs_cursor
		END
		UPDATE Flora_Stats
		SET
			numero_flora_stats = @numero_flora_stats,
			id_packaging = @id_packaging,
			nombre_flora_stats_flower = @nombre_flora_stats_flower,
			nombre_flora_stats_grade = @nombre_flora_stats_grade,
			nombre_flora_stats_color = @nombre_flora_stats_color
		WHERE id_flora_stats = @id_flora_stats
	END
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE flora_stats
	WHERE id_flora_stats = @id_flora_stats

END
--
--ELSE IF @accion = 'subir'
--BEGIN
--	--DECLARE @numero int
--
--	SELECT @numero = numero_flora_stats 
--	FROM flora_stats
--	WHERE id_flora_stats = @id_flora_stats
--	
--	IF @numero <> 1
--	BEGIN
--		UPDATE flora_stats
--			SET numero_flora_stats = @numero
--		WHERE id_flora_stats = 
--			( SELECT id_flora_stats 
--			  FROM flora_stats
--			  WHERE  numero_flora_stats = @numero - 1)
--		UPDATE flora_stats
--			SET numero_flora_stats = @numero - 1
--		WHERE id_flora_stats = @id_flora_stats
--	END
--END
--
--ELSE IF @accion = 'bajar'
--BEGIN
--	--DECLARE @numero int
--
--	SELECT @numero = numero_flora_stats 
--	FROM flora_stats
--	WHERE id_flora_stats = @id_flora_stats
--	
--	IF @numero <> (SELECT MAX(numero_flora_stats) FROM flora_stats)
--	BEGIN
--		UPDATE flora_stats
--			SET numero_flora_stats = @numero
--		WHERE id_flora_stats = 
--			( SELECT id_flora_stats 
--			  FROM flora_stats
--			  WHERE  numero_flora_stats = @numero + 1)
--		UPDATE flora_stats
--			SET numero_flora_stats = @numero + 1
--		WHERE id_flora_stats = @id_flora_stats
--	END
--END
