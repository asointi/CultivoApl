set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/22
-- Description:	Maneja informacion de los capuchones de los items de version de los Bouquets
-- =============================================

alter PROCEDURE [dbo].[bouquet_editar_capuchon] 

@accion nvarchar(255),
@id_capuchon_cultivo int,
@id_detalle_version_bouquet int,
@id_capuchon_formula_bouquet int

as

declare @conteo int

if(@accion = 'consultar')
begin
	select id_capuchon_cultivo,
	ltrim(rtrim(descripcion)) + ' (' + convert(nvarchar,convert(decimal(20,1),ancho_superior)) + ')' as nombre_capuchon
	from capuchon_cultivo
	where disponible = 1
	order by nombre_capuchon
end
else
if(@accion = 'insertar_asignacion')
begin
	select @conteo = count(*)
	from capuchon_formula_bouquet
	where id_capuchon_cultivo = @id_capuchon_cultivo
	and id_detalle_version_bouquet = @id_detalle_version_bouquet
	
	if(@conteo = 0)
	begin
		insert into capuchon_formula_bouquet (id_capuchon_cultivo, id_detalle_version_bouquet)
		values (@id_capuchon_cultivo, @id_detalle_version_bouquet)

		select scope_identity() as id_capuchon_formula_bouquet
	end
	else
	begin
		select -1 as id_capuchon_formula_bouquet
	end
end
else
if(@accion = 'consultar_asignacion')
begin
	select detalle_version_bouquet.id_detalle_version_bouquet,
	capuchon_cultivo.id_capuchon_cultivo,
	ltrim(rtrim(capuchon_cultivo.descripcion)) + ' (' + convert(nvarchar,convert(decimal(20,1),ancho_superior)) + ')' as nombre_capuchon,
	capuchon_formula_bouquet.id_capuchon_formula_bouquet
	from detalle_version_bouquet,
	capuchon_formula_bouquet,
	capuchon_cultivo
	where detalle_version_bouquet.id_detalle_version_bouquet = capuchon_formula_bouquet.id_detalle_version_bouquet
	and capuchon_cultivo.id_capuchon_cultivo = capuchon_formula_bouquet.id_capuchon_cultivo
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by nombre_capuchon
end
else
if(@accion = 'eliminar_asignacion')
begin
	select @id_capuchon_formula_bouquet = capuchon_formula_bouquet.id_capuchon_formula_bouquet
	from capuchon_formula_bouquet,
	detalle_version_bouquet
	where capuchon_formula_bouquet.id_capuchon_cultivo = @id_capuchon_cultivo
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = capuchon_formula_bouquet.id_detalle_version_bouquet

	delete from capuchon_formula_bouquet
	where id_capuchon_formula_bouquet = @id_capuchon_formula_bouquet
end