SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[wbl_consultar_informacion_receiving]

@idc_farm nvarchar(255),
@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255),
@hora_inicial nvarchar(255),
@hora_final nvarchar(255),
@usuario nvarchar(255)

as

if(@usuario <> '')
begin
	select etiqueta.tipo,
	etiqueta.variedad,
	etiqueta.grado,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	etiqueta.marca,
	count(etiqueta.codigo) as numero_piezas 
	from etiqueta,
	usuarios
	where etiqueta.usuario = usuarios.usuario
	and not exists
	(
		select * 
		from etiqueta_receiving
		where etiqueta_receiving.etiqueta = etiqueta.codigo
	)
	and not exists
	(
		select * 
		from etiqueta_creci
		where etiqueta_creci.etiqueta = etiqueta.codigo
	)
	and etiqueta.farm = @idc_farm
	and usuarios.nombre = @usuario
	and etiqueta.fecha between
	(CAST(CONVERT(char(12),@fecha_inicial,113)+(LEFT(@hora_inicial, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_inicial), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_inicial), 5, 2)) AS DATETIME)) and 
	(CAST(CONVERT(char(12),@fecha_final,113)+(LEFT(@hora_final, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_final), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_final), 5, 2)) AS DATETIME)) 
	group by etiqueta.tipo,
	etiqueta.variedad,
	etiqueta.grado,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	etiqueta.marca
	order by etiqueta.tipo,
	etiqueta.variedad,
	etiqueta.grado,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	etiqueta.marca
end
else
begin
	select etiqueta.tipo,
	etiqueta.variedad,
	etiqueta.grado,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	etiqueta.marca,
	count(etiqueta.codigo) as numero_piezas 
	from etiqueta
	where not exists
	(
		select * 
		from etiqueta_receiving
		where etiqueta_receiving.etiqueta = etiqueta.codigo
	)
	and not exists
	(
		select * 
		from etiqueta_creci
		where etiqueta_creci.etiqueta = etiqueta.codigo
	)
	and etiqueta.farm = @idc_farm
	and etiqueta.fecha between
	(CAST(CONVERT(char(12),@fecha_inicial,113)+(LEFT(@hora_inicial, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_inicial), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_inicial), 5, 2)) AS DATETIME)) and 
	(CAST(CONVERT(char(12),@fecha_final,113)+(LEFT(@hora_final, 2) +':'+ SUBSTRING(convert(nvarchar, @hora_final), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora_final), 5, 2)) AS DATETIME)) 
	group by etiqueta.tipo,
	etiqueta.variedad,
	etiqueta.grado,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	etiqueta.marca
	order by etiqueta.tipo,
	etiqueta.variedad,
	etiqueta.grado,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	etiqueta.marca
end