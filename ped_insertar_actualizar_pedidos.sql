/****** Object:  StoredProcedure [dbo].[ped_insertar_actualizar_pedidos]    Script Date: 11/13/2007 13:05:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ped_insertar_actualizar_pedidos]

@idc_pepr bigint, 
@ubicacion nvarchar(5), 
@comentario nvarchar(1024)

AS
BEGIN
IF(convert(nvarchar(255),@idc_pepr) + @ubicacion in (select convert(nvarchar(255),idc_pepr) + ubicacion from pepr))
begin
	update pepr
	set comentario = @comentario
	where idc_pepr = @idc_pepr
	and ubicacion = @ubicacion
end
else
begin
	insert into pepr (idc_pepr, ubicacion, comentario)
	values (@idc_pepr, @ubicacion, @comentario)
end
END