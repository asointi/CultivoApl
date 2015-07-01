/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[mapeo_editar_mapeo_comercializadora]

@accion nvarchar(50),
@id_grado_flor int, 
@id_grado_flor_natuflora int,
@id_variedad_flor int, 
@id_variedad_flor_natuflora int

as

if(@accion = 'insertar_variedad_flor')
begin
	if(@id_variedad_flor > 0 and @id_variedad_flor_natuflora > 0)
	begin
		insert into mapeo_variedad_flor_natuflora (id_variedad_flor, id_variedad_flor_natuflora)
		values (@id_variedad_flor, @id_variedad_flor_natuflora)
	end
end
else
if(@accion = 'insertar_grado_flor')
begin
	if(@id_grado_flor > 0 and @id_grado_flor_natuflora > 0)
	begin
		insert into mapeo_grado_flor_natuflora (id_grado_flor, id_grado_flor_natuflora)
		values (@id_grado_flor, @id_grado_flor_natuflora)
	end
end