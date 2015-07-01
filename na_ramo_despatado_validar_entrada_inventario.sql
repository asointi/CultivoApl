set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_ramo_despatado_validar_entrada_inventario]

@idc_ramo nvarchar(25)

AS

declare @ramo_despatado int,
@ramo_devuelto int

select @ramo_despatado = count(*)
from ramo_despatado
where idc_ramo_despatado = @idc_ramo

select @ramo_devuelto = count(*)
from ramo_despatado,
ramo_devuelto
where idc_ramo_despatado = @idc_ramo
and ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado

if(@ramo_despatado = 1 and @ramo_devuelto = 0)
begin
	select 1 as resultado
end
else
if(@ramo_despatado = 0 and @ramo_devuelto = 0)
begin
	insert into Log_Entrada_Ramo_Cuarto_Frio (idc_ramo,	ramo_despatado,	ramo_devuelto) 
	values (@idc_ramo, @ramo_despatado, @ramo_devuelto)

	select -1 as resultado
end
else
if(@ramo_despatado = 1 and @ramo_devuelto = 1)
begin
	insert into Log_Entrada_Ramo_Cuarto_Frio (idc_ramo,	ramo_despatado,	ramo_devuelto) 
	values (@idc_ramo, @ramo_despatado, @ramo_devuelto)

	select -2 as resultado
end