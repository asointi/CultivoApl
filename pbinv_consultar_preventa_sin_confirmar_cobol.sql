/****** Object:  StoredProcedure [dbo].[pbinv_consultar_preventa_sin_confirmar_cobol]    Script Date: 10/06/2007 13:30:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[pbinv_consultar_preventa_sin_confirmar_cobol]

@idc_cliente_despacho nvarchar(255),
@idc_transportador nvarchar(255),
@fecha_despacho nvarchar(255)

AS

BEGIN
if(@idc_cliente_despacho = '' and @idc_transportador = '' and @fecha_despacho = '')
begin
	SELECT id_preventa_sin_confirmar,
	Cliente_Despacho.nombre_cliente,
	Transportador.nombre_transportador,
	Fecha_Despacho,
	Sum(Cantidad_Piezas)
	FROM
	Preventa_Sin_Confirmar, 
	Transportador, 
	Cliente_Despacho
	WHERE
	Preventa_Sin_Confirmar.id_transportador = Transportador.id_transportador
	and Preventa_Sin_Confirmar.id_despacho = Cliente_Despacho.id_despacho
	GROUP BY id_preventa_sin_confirmar, Cliente_Despacho.nombre_cliente,
	Transportador.nombre_transportador, Fecha_Despacho
end
else
begin
	declare @id_cliente_despacho integer,
	@id_transportador integer

	select @id_cliente_despacho = id_despacho from cliente_despacho where idc_cliente_despacho = @idc_cliente_despacho
	select @id_transportador = id_transportador from transportador where idc_transportador = @idc_transportador

	SELECT id_preventa_sin_confirmar,
	Cliente_Despacho.nombre_cliente,
	Transportador.nombre_transportador,
	Fecha_Despacho,
	Sum(Cantidad_Piezas)
	FROM
	Preventa_Sin_Confirmar, 
	Transportador, 
	Cliente_Despacho
	WHERE
	Preventa_Sin_Confirmar.id_transportador = transportador.id_transportador
	and transportador.id_transportador = @id_transportador
	and Preventa_Sin_Confirmar.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_despacho = @id_cliente_despacho
	and convert(nvarchar,Fecha_Despacho,101) = convert(nvarchar,convert(datetime, @fecha_despacho),101)
	GROUP BY id_preventa_sin_confirmar, Cliente_Despacho.nombre_cliente,
	Transportador.nombre_transportador, Fecha_Despacho
end
END