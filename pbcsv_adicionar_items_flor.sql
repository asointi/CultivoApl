/****** Object:  StoredProcedure [dbo].[pbcsv_adicionar_items_flor]    Script Date: 10/06/2007 13:04:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_adicionar_items_flor]

@nombre_equivalencia_tipo_flor nvarchar(255), 
@nombre_equivalencia_variedad_flor nvarchar(255), 
@nombre_equivalencia_grado_flor nvarchar(255), 
@marca nvarchar(255), 
@id_grupo_cliente integer,
@id_variedad_flor integer,
 @id_grado_flor integer 	

AS

if (@nombre_equivalencia_tipo_flor+@nombre_equivalencia_variedad_flor+@nombre_equivalencia_grado_flor+convert(nvarchar, @id_grupo_cliente) not in (select nombre_equivalencia_tipo_flor+nombre_equivalencia_variedad_flor+nombre_equivalencia_grado_flor+convert(nvarchar, id_grupo_cliente) from grupo_cliente_flor))
begin
	insert into Grupo_Cliente_Flor (id_grado_flor, id_variedad_flor, id_grupo_cliente, nombre_equivalencia_tipo_flor,
	nombre_equivalencia_variedad_flor, nombre_equivalencia_grado_flor, marca)
	select gf.id_grado_flor, vf.id_variedad_flor, gc.id_grupo_cliente, @nombre_equivalencia_tipo_flor,
	@nombre_equivalencia_variedad_flor, @nombre_equivalencia_grado_flor, @marca
	from Grado_Flor as gf, Tipo_Flor as tf, Variedad_Flor as vf, Grupo_Cliente as gc
	where tf.id_tipo_flor = vf.id_tipo_flor
	and tf.id_tipo_flor = gf.id_tipo_flor
	and gf.id_tipo_flor = vf.id_tipo_flor
	and vf.id_variedad_flor = @id_variedad_flor
	and gf.id_grado_flor = @id_grado_flor
	and gc.id_grupo_cliente = @id_grupo_cliente
	return SCOPE_IDENTITY()
end
else 
	RETURN -1