USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[inv_insertar_pieza_postcosecha_bloque]    Script Date: 10/06/2007 13:58:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Diego Piñeros
-- Create date: 06/06/07
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[inv_insertar_pieza_postcosecha_bloque] 
	
@idc_grado_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_bloque nvarchar(255),
@unidades_por_pieza int,
@fecha nvarchar(255),
@hora nvarchar(255)

AS

DECLARE @Tries int
SET @Tries = 1
WHILE @Tries <= 6
BEGIN TRY
BEGIN

IF (len(@idc_grado_flor)>2 OR len(@idc_variedad_flor)>2 OR len(@idc_tipo_flor)>2)
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el tamaño de las variables de flor es mayor a 2'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
IF (@idc_tipo_flor not in (select idc_tipo_flor from Tipo_Flor))
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el codigo del tipo de la flor no existe en Sql'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
IF (@idc_variedad_flor not in (select idc_variedad_flor from Variedad_Flor))
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el codigo de la variedad de la flor no existe en Sql'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
IF (@idc_grado_flor not in (select idc_grado_flor from Grado_Flor))
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el codigo del grado de la flor no existe en Sql'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
IF (@idc_tipo_flor+@idc_variedad_flor not in (select idc_tipo_flor+idc_variedad_flor from Variedad_Flor, Tipo_Flor where Tipo_Flor.id_tipo_flor=Variedad_Flor.id_tipo_flor))
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el codigo del tipo y variedad de la flor no existe en Sql'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
IF (@idc_tipo_flor+@idc_grado_flor not in (select idc_tipo_flor+idc_grado_flor from Grado_Flor, Tipo_Flor where Tipo_Flor.id_tipo_flor=Grado_Flor.id_tipo_flor))
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el codigo del tipo y grado de la flor no existe en Sql'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
IF (@idc_bloque not in (select idc_bloque from Bloque))
	BEGIN
		insert into log_info (mensaje, tipo_mensaje)
		values ('el codigo del bloque no existe en Sql'+space(2)+'dataerror:'+space(1)+
				'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
				'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
				+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
				'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
				'error insercion entradas')
	END
ELSE
	BEGIN
    INSERT INTO Pieza_Postcosecha
	(id_grado_flor, id_variedad_flor, id_bloque, unidades_por_pieza, fecha_entrada)
	select gf.id_grado_flor, vf.id_variedad_flor, b.id_bloque, @unidades_por_pieza, (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) 
	+':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME))
	from Grado_Flor as gf, Variedad_Flor as vf, Tipo_Flor as tf, Bloque as b
	where @idc_tipo_flor+@idc_variedad_flor = tf.idc_tipo_flor+vf.idc_variedad_flor
	and tf.id_tipo_flor=vf.id_tipo_flor
	and @idc_tipo_flor+@idc_grado_flor = tf.idc_tipo_flor+gf.idc_grado_flor
	and tf.id_tipo_flor=gf.id_tipo_flor
	and b.idc_bloque=@idc_bloque
	END	
SET @Tries = 7
END
END TRY
BEGIN CATCH
IF(ERROR_NUMBER()=1205)
	BEGIN
	insert into log_info (mensaje, tipo_mensaje)
	values ('ErrorNumber:'+space(1)+convert(nvarchar, ERROR_NUMBER())+
	space(1)+'ErrorSeverity:'+space(1)+convert(nvarchar, ERROR_SEVERITY())+
	space(1)+'ErrorState:'+space(1)+convert(nvarchar, ERROR_STATE())+
	space(1)+'ErrorProcedure'+space(1)+convert(nvarchar, ERROR_PROCEDURE())+
	space(1)+'ErrorMessage:'+space(1)+convert(nvarchar, ERROR_MESSAGE())+
	space(1)+'ErrorLine:'+space(1)+convert(nvarchar, ERROR_LINE())+space(1)+'dataerror:'+space(1)+
	'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
	'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
	+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
	'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
	'error insercion entradas')
	SET @Tries = @Tries + 1
    CONTINUE
	END
ELSE
BEGIN
insert into log_info (mensaje, tipo_mensaje)
values ('ErrorNumber:'+space(1)+convert(nvarchar, ERROR_NUMBER())+
space(1)+'ErrorSeverity:'+space(1)+convert(nvarchar, ERROR_SEVERITY())+
space(1)+'ErrorState:'+space(1)+convert(nvarchar, ERROR_STATE())+
space(1)+'ErrorProcedure'+space(1)+convert(nvarchar, ERROR_PROCEDURE())+
space(1)+'ErrorMessage:'+space(1)+convert(nvarchar, ERROR_MESSAGE())+
space(1)+'ErrorLine:'+space(1)+convert(nvarchar, ERROR_LINE())+space(1)+'dataerror:'+space(1)+
'grado:'+space(1)+@idc_grado_flor+','+space(1)+'variedad:'+space(1)+@idc_variedad_flor+','+space(1)+
'tipo:'+space(1)+@idc_tipo_flor+','+space(1)+'bloque:'+space(1)+@idc_bloque+','
+space(1)+'unidades por pieza:'+space(1)+convert(nvarchar, @unidades_por_pieza)+','+space(1)+
'fecha:'+space(1)+@fecha+','+space(1)+'hora:'+space(1)+@hora,
'error insercion entradas')
SET @Tries = 7
END
END CATCH