set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_log_envio_factura_destinatario]

@id_log_envio_factura int,
@destinatario nvarchar(255)

as

insert into destinatario (correo, id_log_envio_factura)
values (@destinatario, @id_log_envio_factura)
