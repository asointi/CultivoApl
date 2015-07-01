set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


-- =============================================
-- Author:		John Rodriguez
-- Create date: 19-04-11
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[consultar_asignacion_periferico] 
@accion nvarchar(50)

AS
select (pers.nombres + ' - ' + ar.nombre) as oficina, pr.placa, (tp.tipo + ' ' + mr.marca) as periferico, 
pr.serial, md.nombre_modelo, pr.descripcion
from periferico_asignado as pa
inner join	Periferico as pr
on pa.id_periferico = pr.id_periferico
inner join Oficina as ofi
on pa.id_oficina = ofi.id_oficina
inner join Persona as pers
on ofi.id_persona = pers.id_persona
inner join Area as ar
on ofi.id_area = ar.id_area
inner join Tipo_Periferico as tp
on pr.id_tipo = tp.id_tipo
inner join Marca_Periferico as mr
on pr.id_marca = mr.id_marca
inner join Modelo as md
on pr.id_modelo = md.id_modelo