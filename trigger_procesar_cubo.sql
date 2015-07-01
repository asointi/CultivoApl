set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2009/02/19
-- Description:	Correr cubo cuando se cierre la ejecucion de una determinada regla
-- =============================================

alter TRIGGER [dbo].[procesar_cubo]
   ON  [BD_Cultivo].[dbo].[Tiempo_Ejecucion_Regla]
   after INSERT

AS 
BEGIN
	declare @id_tiempo_ejecucion_regla int,
	@conteo int
	
	select @id_tiempo_ejecucion_regla = max(id_tiempo_ejecucion_regla) 
	from tiempo_ejecucion_regla

	select @conteo = count(*) 
	from tiempo_ejecucion_regla, 
	tipo_transaccion
	where tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
	and tipo_transaccion.nombre_tipo_transaccion = 'fin'
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = @id_tiempo_ejecucion_regla

	if(@conteo <> 0)
	begin
		exec master..xp_cmdshell 'dtexec /SQL "\Maintenance Plans\PackageSQL" /SERVER "DB4\NATUFLORA" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF  /REPORTING EWCDI'
	end
END
