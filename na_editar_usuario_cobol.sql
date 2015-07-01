set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_usuario_cobol]

@accion nvarchar(255),
@login nvarchar(255)

as

if(@accion = 'consultar')
begin
	select cliente_despacho.idc_cliente_despacho
	from usuario_cobol, 
	cliente_usuario_cobol, 
	cliente_despacho
	where usuario_cobol.id_usuario_cobol = cliente_usuario_cobol.id_usuario_cobol
	and cliente_despacho.id_despacho = cliente_usuario_cobol.id_despacho
	and usuario_cobol.login = @login
	order by cliente_despacho.idc_cliente_despacho
end