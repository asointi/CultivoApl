/****** Object:  StoredProcedure [dbo].[gc_editar_cuenta]    Script Date: 10/06/2007 11:23:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[wbl_editar_etiqueta]

@accion nvarchar(50),
@id_etiqueta int 

AS

DECLARE @mensaje nvarchar(255)
        
IF @accion = 'seleccionar'
BEGIN
	select id_etiqueta, 
	codigo, 
	nombre_farm, 
	nombre_tipo_flor,
	nombre_variedad_flor, 
	nombre_grado_flor, 
	nombre_tapa, 
	nombre_tipo_caja,
	marca, 
	unidades_por_caja, 
	fecha as fecha_impresion, 
	fecha_digita as fecha_creacion
	from etiqueta as e, 
	farm as f, 
	tipo_flor as t, 
	variedad_flor as v,
	grado_flor as g, 
	tapa tp, 
	tipo_caja as tc, 
	caja as c
	where not exists 
	(
		select * 
		from etiqueta_creci 
		where etiqueta = codigo
	)
	and not exists 
	(
		select * 
		from etiqueta_receiving 
		where etiqueta = codigo
	)
	and e.farm = f.idc_farm
	and e.tipo = t.idc_tipo_flor
	and e.variedad = v.idc_variedad_flor
	and e.grado = g.idc_grado_flor
	and t.id_tipo_flor = v.id_tipo_flor
	and t.id_tipo_flor = g.id_tipo_flor
	and e.tapa = tp.idc_tapa
	and e.tipo_caja = tc.idc_tipo_caja + c.idc_caja
	and tc.id_tipo_caja = c.id_tipo_caja
END
ELSE IF @accion = 'eliminar'
BEGIN
	delete from etiqueta where @id_etiqueta = id_etiqueta
END
