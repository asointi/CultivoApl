set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_flor]

@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255)

as

declare @id_flor int

insert into flor (id_variedad_flor, id_grado_flor, idc_flor, surtido)
select variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+grado_flor.idc_grado_flor as idc_flor,
0 as surtido
from variedad_flor, grado_flor, tipo_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor

set @id_flor = scope_identity()

update BD_Cultivo.dbo.Flor
set surtido = 1
from BD_Cultivo.dbo.Flor, 
BD_Cultivo_Temp.dbo.Variflor, 
BD_Cultivo_Temp.dbo.Tamaflor 
where 
@idc_tipo_flor + @idc_variedad_flor = BD_Cultivo_Temp.dbo.Variflor.LlaveTif + BD_Cultivo_Temp.dbo.Variflor.LlaveVf
and @idc_tipo_flor + @idc_grado_flor = BD_Cultivo_Temp.dbo.Tamaflor.llaveTif + BD_Cultivo_Temp.dbo.Tamaflor.LlaveTaf
and (BD_Cultivo_Temp.dbo.Variflor.SwSurtida = 'S' or BD_Cultivo_Temp.dbo.Tamaflor.SwSurtidoTaf = 'X')
and BD_Cultivo.dbo.Flor.id_flor = @id_flor

