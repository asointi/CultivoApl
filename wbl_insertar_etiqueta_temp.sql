/****** Object:  StoredProcedure [dbo].[wbl_insertar_etiqueta_temp]    Script Date: 10/06/2007 12:43:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_insertar_etiqueta_temp]

@usuario NVARCHAR(255),
@farm NVARCHAR(255),
@tipo NVARCHAR(255),
@variedad NVARCHAR(255),
@grado NVARCHAR(255),
@tapa NVARCHAR(255),
@tipo_caja NVARCHAR(255),
@marca NVARCHAR(255),
@unidades_caja INT,
@fecha DATETIME,
@cantidad INT

AS

INSERT INTO ETIQUETA_TEMP_USER 
(
	usuario, 
	farm, 
	tipo, 
	variedad, 
	grado, 
	tapa, 
	tipo_caja, 
	marca, 
	unidades_por_caja,  
	fecha, 
	cantidad
)
VALUES 
(
	@usuario, 
	@farm, 
	@tipo, 
	@variedad, 
	@grado, 
	@tapa, 
	@tipo_caja, 
	@marca, 
	@unidades_caja, 
	@fecha, 
	@cantidad
)