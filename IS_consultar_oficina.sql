set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 19-04-11
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[consultar_oficina] 
@accion nvarchar(50)

AS

if (@accion = 'consultar')
select ofi.id_oficina, ofi.fecha_creacion, (ar.nombre + ' - ' + per.nombres + ' ' + per.apellidos) as Nombre_Oficina
from Oficina as ofi, Area as ar, Persona as per
where ar.id_area = ofi.id_area
AND per.id_persona = ofi.id_persona
order by Nombre_Oficina