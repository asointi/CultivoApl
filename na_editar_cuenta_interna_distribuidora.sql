SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[na_editar_cuenta_interna_distribuidora] 

@comercializadora nvarchar(255),
@cuenta nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar_usuarios')
begin
	select cuenta_interna_distribuidora.nombre as nombre_cuenta,
	cuenta_interna_distribuidora.correo
	from cuenta_interna_distribuidora,
	distribuidora
	where distribuidora.id_distribuidora = cuenta_interna_distribuidora.id_distribuidora
	and distribuidora.nombre_distribuidora = @comercializadora
	and cuenta_interna_distribuidora.cuenta > = 
	case
		when @cuenta = '' then '                    '
		else @cuenta
	end
	and cuenta_interna_distribuidora.cuenta < = 
	case
		when @cuenta = '' then 'ZZZZZZZZZZZZZZZZZZZZ'
		else @cuenta
	end
end
else
if(@accion = 'consultar_comercializadora')
begin
	select id_distribuidora,
	nombre_distribuidora
	from distribuidora
	order by nombre_distribuidora
end