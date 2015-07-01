/****** Object:  StoredProcedure [dbo].[pbcsv_consultar_items_existentes_cliente_despacho_farm]    Script Date: 10/06/2007 13:06:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_consultar_items_existentes_cliente_despacho_farm]

@nombre_grupo_cliente_despacho nvarchar(255), 
@id_grupo_cliente integer,
@nombre_grupo_cliente_farm nvarchar(255)

AS

select cd.id_despacho, cd.nombre_cliente, f.id_farm, f.nombre_farm
from farm as f,
Grupo_Cliente_Farm as gcf, Grupo_Cliente as gc, Cliente_Factura as cf, 
Cliente_Despacho as cd, Grupo_Cliente_Despacho as gcd
where f.id_farm = gcf.id_farm
and gcf.id_grupo_cliente = gc.id_grupo_cliente
and gc.id_grupo_cliente = cf.id_grupo_cliente
and cf.id_cliente_factura=cd.id_cliente_factura
and cd.id_despacho=gcd.id_despacho
and gc.id_grupo_cliente=gcd.id_grupo_cliente
and gcf.nombre_grupo_cliente_farm = @nombre_grupo_cliente_farm
and gcd.nombre_grupo_cliente_despacho = @nombre_grupo_cliente_despacho
and gc.id_grupo_cliente = @id_grupo_cliente
