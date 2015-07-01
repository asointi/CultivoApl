set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ramo_distribuidora_version2]

@idc_ramo nvarchar(50),
@tallos_por_ramo int,
@idc_pieza nvarchar(50),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@fecha nvarchar(15),
@hora nvarchar(15),
@idc_finca nvarchar(2)

as

declare @conteo int

select @conteo = count(*) from finca where idc_finca = @idc_finca

if(@conteo = 0)
begin
	begin transaction;
		insert into finca (idc_finca, nombre_finca)
		values (@idc_finca, 'PENDIENTE POR CODIFICAR')
	commit transaction;
end

insert into ramo (id_pieza, id_grado_flor,id_variedad_flor, fecha_entrada, idc_ramo, tallos_por_ramo, id_finca)
select pieza.id_pieza, grado_flor.id_grado_flor, variedad_flor.id_variedad_flor, [dbo].[concatenar_fecha_hora_COBOL](@fecha, @hora), @idc_ramo, @tallos_por_ramo, finca.id_finca
from pieza, 
variedad_flor, 
grado_flor, 
tipo_flor,
finca
where pieza.idc_pieza = @idc_pieza
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and finca.idc_finca = @idc_finca