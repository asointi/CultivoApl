set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ped_editar_correo_finca]

@id_farm int,
@correo nvarchar(1024)

as

update farm
set correo = @correo
where id_farm = @id_farm