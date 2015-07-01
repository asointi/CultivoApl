/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_ramo_devuelto]

@idc_ramo_despatado nvarchar(255),
@accion nvarchar(255)

AS

if(@accion = 'insertar')
begin
	insert into ramo_devuelto (id_ramo_despatado)
	select ramo_despatado.id_ramo_despatado
	from ramo_despatado
	where ramo_despatado.idc_ramo_despatado = @idc_ramo_despatado
end
else
if(@accion = 'consultar_ramo')
begin
	declare @conteo int

	select @conteo = count(*)
	from ramo_despatado,
	ramo_devuelto
	where ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado
	and ramo_despatado.idc_ramo_despatado = @idc_ramo_despatado

	if(@conteo = 0)
	begin
		select 0 as result
	end
	else
	begin
		select 1 as result
	end
end