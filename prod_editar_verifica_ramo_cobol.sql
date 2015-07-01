set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/03/24
-- Description:	insertar los registros que se graban de COBOL en la tabla verifica_ramo_cobol a verifica_ramo y verifica_ramo_comprado
-- =============================================

alter PROCEDURE [dbo].[prod_editar_verifica_ramo_cobol] 

@fecha datetime

as

insert into verifica_ramo (id_ramo, fecha_lectura)
select ramo.id_ramo, @fecha
from ramo,
verifica_ramo_cobol
where ramo.idc_ramo = verifica_ramo_cobol.idc_ramo
and verifica_ramo_cobol.ramo_comprado = 0
and not exists
(
	select * 
	from verifica_ramo
	where verifica_ramo.id_ramo = ramo.id_ramo
	and verifica_ramo.fecha_lectura = @fecha
)

insert into verifica_ramo_comprado (id_ramo_comprado, fecha_lectura)
select ramo_comprado.id_ramo_comprado, @fecha
from ramo_comprado,
verifica_ramo_cobol
where ramo_comprado.idc_ramo_comprado = verifica_ramo_cobol.idc_ramo
and verifica_ramo_cobol.ramo_comprado = 1
and not exists
(
	select * 
	from verifica_ramo_comprado
	where verifica_ramo_comprado.id_ramo_comprado = ramo_comprado.id_ramo_comprado
	and verifica_ramo_comprado.fecha_lectura = @fecha
)

delete from verifica_ramo_cobol