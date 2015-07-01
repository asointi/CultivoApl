/****** Object:  StoredProcedure [dbo].[na_insertar_actualizar_variedad_flor]    Script Date: 10/06/2007 12:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_insertar_actualizar_cliente_version2]

@LlaveCli nvarchar(255),
@LlaveCliFactCli nvarchar(255),
@LlaveVendCli nvarchar(255),
@SwnonfobfarmCli nvarchar(255),
@NombreCli nvarchar(255),
@PersonaCli nvarchar(255),
@DireccionCli nvarchar(255),
@CiudadCli nvarchar(255),
@LlaveEsusCli nvarchar(255),
@TelefonoCli nvarchar(255),
@FaxCli nvarchar(255),
@id_grupo_cliente_factura int

AS
BEGIN

declare @id_cliente_factura int,
@conteo int
	
/*el cliente enviado es cliente de factura*/
if(@LlaveCli <> '' and @LlaveCliFactCli = '')
begin
	select @conteo = count(*) from cliente_factura 
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

		set @id_cliente_factura = scope_identity()

		set @conteo = null

		select @conteo = count(*) from cliente_despacho 
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
				fax
			)
			values 
			(
				@id_cliente_factura, 
				@LlaveCli, 
				@NombreCli, 
				@PersonaCli, 
				@DireccionCli, 
				@CiudadCli, 
				@LlaveEsusCli, 
				@TelefonoCli, 
				@FaxCli
			)
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
			id_cliente_factura = @id_cliente_factura
			where idc_cliente_despacho = @LlaveCli
		end
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

		set @conteo = null

		select @conteo = count(*) from cliente_despacho 
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
				fax
			)
			select cliente_factura.id_cliente_factura, 
			@LlaveCli, 
			@NombreCli, 
			@PersonaCli, 
			@DireccionCli, 
			@CiudadCli, 
			@LlaveEsusCli, 
			@TelefonoCli, 
			@FaxCli
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
			id_cliente_factura = cliente_factura.id_cliente_factura
			from cliente_factura
			where cliente_despacho.idc_cliente_despacho = @LlaveCli
			and cliente_factura.idc_cliente_factura = @LlaveCli
		end		
	end
end
/*el cliente enviado es cliente de despacho*/
else
begin
	set @conteo = null

	select @conteo = count(*) from cliente_factura
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

		set @id_cliente_factura = scope_identity()

		set @conteo = null

		select @conteo = count(*) from cliente_despacho
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
				fax
			)
			values 
			(
				@id_cliente_factura, 
				@LlaveCli, 
				@NombreCli, 
				@PersonaCli, 
				@DireccionCli, 
				@CiudadCli, 
				@LlaveEsusCli, 
				@TelefonoCli, 
				@FaxCli
			)
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
			id_cliente_factura = @id_cliente_factura
			where idc_cliente_despacho = @LlaveCli
		end
	end
	else
	begin
		/*el cliente de factura enviado si existe*/
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

		/*el cliente enviado no existe como cliente de despacho*/

		set @conteo = null

		select @conteo = count(*) from cliente_despacho
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
				fax
			)
			select cliente_factura.id_cliente_factura, 
			@LlaveCli, 
			@NombreCli, 
			@PersonaCli, 
			@DireccionCli, 
			@CiudadCli, 
			@LlaveEsusCli, 
			@TelefonoCli, 
			@FaxCli
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
			id_cliente_factura = cliente_factura.id_cliente_factura
			from cliente_factura
			where cliente_despacho.idc_cliente_despacho = @LlaveCli
			and cliente_factura.idc_cliente_factura = @LlaveCliFactCli
		end		
	end
end
END
