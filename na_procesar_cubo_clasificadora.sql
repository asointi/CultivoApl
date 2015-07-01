set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter procedure [dbo].[na_procesar_cubo_clasificadora]

AS 

exec master..xp_cmdshell 'dtexec /SQL "\Maintenance Plans\PackageSQL" /SERVER "DB4\NATUFLORA" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF  /REPORTING EWCDI'
