
/****** Object:  Trigger [dbo].[alterar_temporada_cubo]    Script Date: 04/08/2008 16:03:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Pi�eros
-- Create date: 2008/02/21
-- Description:	para crear tabla con fecha de finalizacion de temporadas y usarlas en los cubos
-- =============================================
ALTER TRIGGER [dbo].[alterar_temporada_cubo]
   ON  [BD_Nf].[dbo].[Temporada_A�o]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	drop table Temporada_cubo
	
	create table Temporada_cubo
	(id_temporada_cubo int identity(1,1),
	id_temporada int,
	id_a�o int,
	fecha_inicial datetime,
	fecha_final datetime,
Constraint [pk_temporada_cubo] Primary Key (id_temporada,id_a�o)
	)
	
	insert into Temporada_cubo (id_temporada,id_a�o,fecha_inicial,fecha_final)
	SELECT dbo.Temporada.id_temporada, 
	dbo.A�o.id_a�o, 
	t1.fecha_inicial, 
	MIN(t2.fecha_inicial) - 1 AS fecha_final
	FROM dbo.Temporada_A�o AS t1, 
	dbo.Temporada_A�o AS t2,
	dbo.Temporada,
	dbo.A�o 
	WHERE t1.fecha_inicial < t2.fecha_inicial
	and t1.id_temporada = dbo.Temporada.id_temporada
	and t1.id_a�o = dbo.A�o.id_a�o
	GROUP BY t1.fecha_inicial, dbo.Temporada.id_temporada, dbo.Temporada.nombre_temporada, dbo.A�o.id_a�o, dbo.A�o.nombre_a�o
	ORDER BY t1.fecha_inicial

	insert into Temporada_cubo (id_temporada,id_a�o,fecha_inicial,fecha_final)
	select top 1 temporada_a�o.id_temporada,
	temporada_a�o.id_a�o,
	temporada_a�o.fecha_inicial,
	convert(datetime,'31-12'+'-'+convert(nvarchar,datepart(yyyy,temporada_a�o.fecha_inicial))) as fecha_final
	from temporada_a�o
	order by temporada_a�o.fecha_inicial desc	
END


