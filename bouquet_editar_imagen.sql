set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[bouquet_editar_imagen] 

@id_bouquet int

as

update bouquet
set imagen = null
where id_bouquet = @id_bouquet