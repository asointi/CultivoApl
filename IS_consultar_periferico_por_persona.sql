set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[consultar_periferico_por_persona] 
	@id_oficina int
AS
BEGIN
	SET NOCOUNT ON;

    select pa.fecha_asignacion, p.placa, p.serial, m.marca, mo.nombre_modelo, tp.tipo, ar.nombre, pa.id_oficina,
	per.numero_identificacion, per.nombres, per.apellidos, ar.nombre as nombre_area
	from Periferico_Asignado as pa, Periferico as p, Marca_Periferico as m, Modelo as mo, Tipo_Periferico as tp,
	Oficina as ofi, Area as ar, Persona as per
	where pa.id_periferico = p.id_periferico
	and pa.id_oficina = ofi.id_oficina
	and p.id_marca = m.id_marca
	and p.id_modelo = mo.id_modelo
	and p.id_tipo = tp.id_tipo	
	and ofi.id_area = ar.id_area
	and ofi.id_persona = per.id_persona
	and pa.estado = 1
	and pa.id_oficina = @id_oficina
	order by tp.tipo, p.placa asc
END