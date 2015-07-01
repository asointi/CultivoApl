/****** Object:  StoredProcedure [dbo].[pbinv_actualizar_preventa_sin_confirmar_cobol]    Script Date: 10/06/2007 13:24:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_actualizar_preventa_sin_confirmar_cobol]

@id_preventa_sin_confirmar integer, 
@idc_transportador nvarchar(3),
@idc_despacho nvarchar(7),
@valor_unitario decimal(20,4),
@fecha_despacho datetime

AS

declare @id_transportador integer, @id_despacho integer
select @id_transportador = id_transportador from transportador where idc_transportador = @idc_transportador
select @id_despacho = id_despacho from Cliente_Despacho where idc_cliente_despacho = @idc_despacho

BEGIN
	if (@id_preventa_sin_confirmar not in (select id_preventa_sin_confirmar from Item_Preventa))
		begin
			update Preventa_Sin_Confirmar
			set id_transportador = @id_transportador,
			id_despacho = @id_despacho,
			valor_unitario = @valor_unitario,
			fecha_despacho = @fecha_despacho
			from Preventa_Sin_Confirmar
			where id_preventa_sin_confirmar = @id_preventa_sin_confirmar

			select 0
		end
	else
		select -1
END