set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_insertar_actualizar_cliente_version3]

@LlaveCli nvarchar(25),
@LlaveCliFactCli nvarchar(25),
@LlaveVendCli nvarchar(10),
@SwnonfobfarmCli nvarchar(10),
@NombreCli nvarchar(50),
@PersonaCli nvarchar(50),
@DireccionCli nvarchar(50),
@CiudadCli nvarchar(50),
@LlaveEsusCli nvarchar(10),
@TelefonoCli nvarchar(50),
@FaxCli nvarchar(50),
@id_grupo_cliente_factura int,
@delivery_cube_rate decimal(20,4)

AS

declare @id_cliente_factura int,
@conteo int
	
/*el cliente enviado es cliente de factura*/
if(@LlaveCli <> '' and @LlaveCliFactCli = '')
begin
	select @conteo = count(*) 
	from cliente_factura 
	where idc_cliente_factura = @LlaveCli

	/*verificar que el cliente enviado no exista como cliente de factura*/
	if(@conteo = 0)
	begin
		insert into cliente_factura 
		(
			idc_cliente_factura, 
			id_vendedor, 
			visualizar_cargos, 
			id_cuenta_interna, 
			id_grupo_cliente_factura
		)
		select @LlaveCli, 
		vendedor.id_vendedor, 
		replace(replace(@SwnonfobfarmCli, '', 0), 'X', 1), 
		cuenta_interna.id_cuenta_interna,
		grupo_cliente_factura.id_grupo_cliente_factura
		from vendedor, 
		cuenta_interna,
		grupo_cliente_factura
		where idc_vendedor = @LlaveVendCli
		and cuenta_interna.cuenta = 'cobol'
		and grupo_cliente_factura.nombre_grupo_cliente_factura = 'N/A'
	end
	/*El cliente enviado existe como cliente de factura*/
	else
	begin
		update cliente_factura
		set id_vendedor = vendedor.id_vendedor,
		visualizar_cargos = replace(replace(@SwnonfobfarmCli, '', 0), 'X', 1),
		id_cuenta_interna = cuenta_interna.id_cuenta_interna	
		from vendedor, 
		cliente_factura, 
		cuenta_interna
		where vendedor.idc_vendedor = @LlaveVendCli
		and idc_cliente_factura = @LlaveCli			
		and cuenta_interna.cuenta = 'cobol'
	end

	select @conteo = count(*) 
	from cliente_despacho 
	where idc_cliente_despacho = @LlaveCli
	
	/*el cliente enviado no existe como cliente de despacho*/
	if(@conteo = 0)
	begin
		insert into cliente_despacho 
		(
			id_cliente_factura, 
			idc_cliente_despacho, 
			nombre_cliente, 
			contacto, 
			direccion, 
			ciudad,		
			estado, 
			telefono, 
			fax,
			delivery_cube_rate
		)
		select cliente_factura.id_cliente_factura, 
		@LlaveCli, 
		@NombreCli, 
		@PersonaCli, 
		@DireccionCli, 
		@CiudadCli, 
		@LlaveEsusCli, 
		@TelefonoCli, 
		@FaxCli,
		@delivery_cube_rate
		from cliente_factura 
		where cliente_factura.idc_cliente_factura = @LlaveCli
	end
	else
	begin
		update cliente_despacho
		set nombre_cliente = @NombreCli,
		contacto = @PersonaCli,
		direccion = @DireccionCli,
		ciudad = @CiudadCli,
		estado = @LlaveEsusCli,
		telefono = @TelefonoCli,
		fax = @FaxCli,
		delivery_cube_rate = @delivery_cube_rate,
		id_cliente_factura = cliente_factura.id_cliente_factura
		from cliente_factura
		where cliente_despacho.idc_cliente_despacho = @LlaveCli
		and cliente_factura.idc_cliente_factura = @LlaveCli
	end		
end
/*el cliente enviado es cliente de despacho*/
else
begin
	select @conteo = count(*) 
	from cliente_factura
	where idc_cliente_factura = @LlaveCliFactCli

	/*el cliente de factura enviado no existe*/
	if(@conteo = 0)
	begin
		insert into cliente_factura 
		(
			idc_cliente_factura, 
			id_vendedor, 
			visualizar_cargos, 
			id_cuenta_interna, 
			id_grupo_cliente_factura
		)
		select @LlaveCliFactCli, 
		vendedor.id_vendedor, 
		replace(replace(@SwnonfobfarmCli, '', 0), 'X', 1), 
		cuenta_interna.id_cuenta_interna,
		grupo_cliente_factura.id_grupo_cliente_factura
		from vendedor, 
		cuenta_interna,
		grupo_cliente_factura
		where idc_vendedor = @LlaveVendCli
		and cuenta_interna.cuenta = 'cobol'
		and grupo_cliente_factura.nombre_grupo_cliente_factura = 'N/A'
	end
	else
	begin
		update cliente_factura
		set id_vendedor = vendedor.id_vendedor,
		visualizar_cargos = replace(replace(@SwnonfobfarmCli, '', 0), 'X', 1),
		id_cuenta_interna = cuenta_interna.id_cuenta_interna
		from vendedor, 
		cliente_factura, 
		cuenta_interna
		where vendedor.idc_vendedor = @LlaveVendCli
		and idc_cliente_factura = @LlaveCliFactCli			
		and cuenta_interna.cuenta = 'cobol'
	end
	
	select @conteo = count(*) 
	from cliente_despacho
	where idc_cliente_despacho = @LlaveCli

	if(@conteo = 0)
	begin
		insert into cliente_despacho 
		(
			id_cliente_factura, 
			idc_cliente_despacho, 
			nombre_cliente, 
			contacto, 
			direccion, 
			ciudad,
			estado, 
			telefono, 
			fax,
			delivery_cube_rate
		)
		select cliente_factura.id_cliente_factura, 
		@LlaveCli, 
		@NombreCli, 
		@PersonaCli, 
		@DireccionCli, 
		@CiudadCli, 
		@LlaveEsusCli, 
		@TelefonoCli, 
		@FaxCli,
		@delivery_cube_rate
		from cliente_factura 
		where cliente_factura.idc_cliente_factura = @LlaveClifactCli
	end
	else
	begin
		update cliente_despacho
		set nombre_cliente = @NombreCli,
		contacto = @PersonaCli,
		direccion = @DireccionCli,
		ciudad = @CiudadCli,
		estado = @LlaveEsusCli,
		telefono = @TelefonoCli,
		fax = @FaxCli,
		delivery_cube_rate = @delivery_cube_rate,
		id_cliente_factura = cliente_factura.id_cliente_factura
		from cliente_factura
		where cliente_despacho.idc_cliente_despacho = @LlaveCli
		and cliente_factura.idc_cliente_factura = @LlaveCliFactCli
	end					
end