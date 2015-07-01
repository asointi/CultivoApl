set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_ramo_distribuidora]

@idc_ramo nvarchar(255),
@tallos_por_ramo int,
@idc_pieza nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@fecha nvarchar(255),
@hora nvarchar(255)

as

begin try
	declare @fecha_entrada datetime

	set @fecha_entrada = (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME))

	insert into ramo (id_pieza, id_grado_flor,id_variedad_flor, fecha_entrada, idc_ramo, tallos_por_ramo)
	select pieza.id_pieza, grado_flor.id_grado_flor, variedad_flor.id_variedad_flor, @fecha_entrada, @idc_ramo, @tallos_por_ramo
	from pieza, variedad_flor, grado_flor, tipo_flor
	where pieza.idc_pieza = @idc_pieza
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
end try
begin catch

end catch

