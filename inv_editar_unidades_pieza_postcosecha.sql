set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[inv_editar_unidades_pieza_postcosecha] 

@idc_pieza_postcosecha nvarchar(255),
@unidades_por_pieza int

AS

update pieza_postcosecha
set unidades_por_pieza = @unidades_por_pieza
where idc_pieza_postcosecha = @idc_pieza_postcosecha