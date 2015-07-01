set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_descripcion_produccion_solicitada]

@comentario nvarchar(512),
@id_cuenta_interna int

as

insert into descripcion_produccion_solicitada (comentario,id_cuenta_interna,fecha_transaccion)
values (@comentario,@id_cuenta_interna,getdate())

select scope_identity() as id_descripcion_produccion_solicitada