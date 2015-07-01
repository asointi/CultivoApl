/****** Object:  StoredProcedure [dbo].[pbcsv_registrar_item_preventa]    Script Date: 10/06/2007 13:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_registrar_item_preventa]	

@id_preventa_archivo integer, 	
@id_despacho integer, 
@id_farm integer,
@id_variedad_flor integer, 
@id_grado_flor integer, 
@marca nvarchar(255),
@cantidad_piezas integer, 
@unidades_por_pieza integer, 
@valor_unitario decimal(20,4)

AS

declare @id_item_preventa_archivo integer, @nombre_tipo_caja nvarchar(255), @idc_transportador nvarchar(255), @idc_tapa nvarchar(255)

set @nombre_tipo_caja = 'ADJUST.'
set @idc_transportador = 'ZZZ'
set @idc_tapa = 'ZZ'

insert into Item_Preventa_Archivo (id_preventa_archivo, cantidad_piezas, unidades_por_pieza, valor_unitario, 
			id_variedad_flor, id_grado_flor, id_farm, id_despacho, id_tipo_caja, id_transportador, id_tapa, marca)
select @id_preventa_archivo, @cantidad_piezas, @unidades_por_pieza, @valor_unitario, 
		@id_variedad_flor, @id_grado_flor, @id_farm, @id_despacho, tc.id_tipo_caja, tr.id_transportador, tp.id_tapa, @marca
from tipo_caja as tc, transportador as tr, tapa as tp
where tc.nombre_tipo_caja = @nombre_tipo_caja
and tr.idc_transportador = @idc_transportador
and tp.idc_tapa = @idc_tapa
set @id_item_preventa_archivo = scope_identity()
insert into Item_Preventa (id_item_preventa_archivo)
values (@id_item_preventa_archivo) 