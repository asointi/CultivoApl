set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/04/13
-- Description:	Graba las piezas a través de la etiqueta impresa
-- =============================================

alter PROCEDURE [dbo].[inv_insertar_pieza_postcosecha_idc_cobol_version3] 

@idc_pieza_postcosecha nvarchar(15),
@fecha nvarchar(15),
@hora nvarchar(15),
@id_etiqueta_impresa int,
@accion nvarchar(15),
@fecha_inicial nvarchar(15),
@fecha_final nvarchar(15),
@unidades_por_pieza int

AS

INSERT INTO Pieza_Postcosecha
(
	id_caracteristica_tipo_flor, 
	id_variedad_flor, 
	id_bloque, 
	idc_pieza_postcosecha, 
	id_persona, 
	unidades_por_pieza, 
	fecha_entrada, 
	id_punto_corte
)
select caracteristica_tipo_flor.id_caracteristica_tipo_flor,
variedad_flor.id_variedad_flor,
bloque.id_bloque,
@idc_pieza_postcosecha, 
persona.id_persona,
case
	when etiqueta.unidades = 0 then @unidades_por_pieza
	else etiqueta.unidades
end,
dbo.concatenar_fecha_hora_COBOL (@fecha, @hora),
punto_corte.id_punto_corte
from caracteristica_tipo_flor, 
Variedad_Flor, 
Tipo_Flor, 
Bloque, 
Persona,
punto_corte,
etiqueta,
etiqueta_impresa
where etiqueta.id_persona = persona.id_persona
and etiqueta.id_bloque = bloque.id_bloque
and etiqueta.id_variedad_flor = variedad_flor.id_variedad_flor
and etiqueta.id_punto_corte = punto_corte.id_punto_corte
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = caracteristica_tipo_flor.id_tipo_flor
and etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa

insert into entrada (id_etiqueta_impresa, id_pieza_postcosecha, usuario_cobol, computador, sesion)
values (@id_etiqueta_impresa, @@identity, 'Version3', 'Version3', 'Version3')

select 0 as result