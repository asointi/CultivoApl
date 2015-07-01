set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_etiqueta_unificada]

@id_etiqueta_unificada int,
@unidades_por_pieza int

AS

declare @unidades_grabadas int,
@id_persona int,
@id_bloque int,
@id_variedad_flor int,
@fecha_transaccion datetime,
@id_punto_corte int,
@id_area int,
@id int

select @unidades_grabadas = etiqueta.unidades, 
@id_persona = etiqueta.id_persona, 
@id_bloque = etiqueta.id_bloque, 
@id_variedad_flor = etiqueta.id_variedad_flor, 
@fecha_transaccion = etiqueta.fecha_transaccion, 
@id_punto_corte = etiqueta.id_punto_corte, 
@id_area = etiqueta.id_area
from etiqueta,
etiqueta_impresa
where etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_unificada

if(@unidades_grabadas <> @unidades_por_pieza)
begin
	insert into etiqueta (id_persona, id_bloque, id_variedad_flor, unidades, fecha_transaccion, id_punto_corte, id_area)
	values(@id_persona, @id_bloque, @id_variedad_flor, @unidades_por_pieza, @fecha_transaccion, @id_punto_corte, @id_area)

	set @id = scope_identity()

	update etiqueta_impresa
	set id_etiqueta = @id
	where etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_unificada
end
