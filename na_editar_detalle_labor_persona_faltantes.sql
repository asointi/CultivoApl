USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[na_editar_detalle_labor_persona_faltantes]    Script Date: 2/3/2015 2:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_editar_detalle_labor_persona_faltantes]

@fecha_marcacion nvarchar(8),
@hora_marcacion nvarchar(8),
@idc_persona nvarchar(8),
@idc_detalle_labor nvarchar(8)

as

declare @id_persona int,
@id_detalle_labor int,
@fecha datetime,
@id_detalle_labor_persona int, 
@comentario nvarchar (512), 
@fecha_lectura datetime

select @id_persona = persona.id_persona from persona where idc_persona = @idc_persona
select @id_detalle_labor = detalle_labor.id_detalle_labor from detalle_labor where idc_detalle_labor = @idc_detalle_labor
set @fecha = [dbo].[concatenar_fecha_hora_COBOL](@fecha_marcacion, @hora_marcacion)

MERGE dbo.detalle_labor_persona AS target
USING (SELECT @id_detalle_labor_persona, @id_detalle_labor, @id_persona, @fecha, @comentario, @fecha_lectura) as source 
(id_detalle_labor_persona, id_detalle_labor, id_persona, fecha, comentario, fecha_lectura)
ON 
(
	target.id_persona = source.id_persona
	and target.id_detalle_labor = source.id_detalle_labor
	and convert(nvarchar, target.fecha, 101) = convert(nvarchar, source.fecha, 101) 
	and convert(nvarchar, target.fecha, 108) = convert(nvarchar, source.fecha, 108) 
)
WHEN NOT MATCHED THEN 

INSERT values (source.id_detalle_labor, source.id_persona, source.fecha, source.comentario, source.fecha_lectura)

output inserted.id_detalle_labor_persona;