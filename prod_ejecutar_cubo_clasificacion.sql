set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_ejecutar_cubo_clasificacion]

as

declare @id_tallo_clasificado int

select @id_tallo_clasificado = max(id_tallo_clasificado)
from tallo_clasificado

update globales_sql
set id_tallo_clasificado = @id_tallo_clasificado

exec master..xp_cmdshell 'dtexec /SQL "\Maintenance Plans\PackageSQL" /SERVER "DB4\NATUFLORA" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF  /REPORTING EWCDI'