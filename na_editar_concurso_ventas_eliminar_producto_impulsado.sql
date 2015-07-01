set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_concurso_ventas_eliminar_producto_impulsado]

@id_producto_impulsado int

AS

delete from producto_impulsado
where id_producto_impulsado = @id_producto_impulsado
