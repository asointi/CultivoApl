set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_cuenta_interna]

@id_cuenta_interna int,
@accion nvarchar(255)

as

if(@accion = '')


select * from cuenta_interna