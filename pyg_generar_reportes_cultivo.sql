set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pyg_generar_reportes_cultivo] 

@fecha_inicial_cultivo datetime, 
@fecha_final_cultivo datetime

as

exec bd_nf.bd_nf.dbo.pyg_generar_reportes

@fecha_inicial = @fecha_inicial_cultivo, 
@fecha_final = @fecha_final_cultivo,
@id_grupo_flor = null