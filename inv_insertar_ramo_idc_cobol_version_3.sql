set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/04/27
-- =============================================
alter PROCEDURE [dbo].[inv_insertar_ramo_idc_cobol_version_3] 

@idc_grado_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_ramo nvarchar(255),
@tallos_por_ramo int,
@fecha nvarchar(255),
@hora nvarchar(255),
@idc_punto_corte nvarchar(255),
@idc_persona nvarchar(255)

AS

declare @conteo int

select @conteo = count(*)
from ramo
where idc_ramo = @idc_ramo

if(@conteo = 0)
begin
	select @conteo = count(*)
	from ramo_despatado
	where idc_ramo_despatado = @idc_ramo

	if(@conteo > 0)
	begin
		INSERT INTO Ramo
		(
			id_grado_flor, 
			id_variedad_flor, 
			idc_ramo, 
			tallos_por_ramo, 
			fecha_entrada, 
			id_punto_corte,
			id_persona
		)
		select gf.id_grado_flor, 
		vf.id_variedad_flor, 
		@idc_ramo, 
		@tallos_por_ramo, 
		(CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)), 
		punto_corte.id_punto_corte,
		persona.id_persona
		from Grado_Flor as gf, 
		Variedad_Flor as vf, 
		Tipo_Flor as tf, 
		punto_corte,
		persona
		where tf.idc_tipo_flor = @idc_tipo_flor
		and vf.idc_variedad_flor = @idc_variedad_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.idc_tipo_flor = @idc_tipo_flor
		and gf.idc_grado_flor = @idc_grado_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and punto_corte.idc_punto_corte = @idc_punto_corte
		and persona.idc_persona = @idc_persona

		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
begin
	select -2 as result
end