set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_surtido_flor]

@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_cliente_despacho nvarchar(255),
@idc_caja nvarchar(255),
@numero_surtido int,
@disponible bit,
@nombre_surtido_flor nvarchar(255),
@accion nvarchar(255)

as

declare @conteo int

update flor
set surtido = 1
from tipo_flor,
variedad_flor,
grado_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = flor.id_variedad_flor
and grado_flor.id_grado_flor = flor.id_grado_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from flor,
	caja,
	cliente_despacho,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_caja,
	surtido_flor
	where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja
	and surtido_flor.numero_surtido = @numero_surtido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = flor.id_variedad_flor
	and grado_flor.id_grado_flor = flor.id_grado_flor
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and flor.id_flor = surtido_flor.id_flor
	and caja.id_caja = surtido_flor.id_caja
	and cliente_despacho.id_cliente_despacho = surtido_flor.id_cliente_despacho

	if(@conteo = 0)
	begin
		insert into surtido_flor (id_flor,id_caja,id_cliente_despacho,numero_surtido,nombre_surtido_flor,disponible,idc_surtido_flor)
		select flor.id_flor,
		caja.id_caja,
		cliente_despacho.id_cliente_despacho,
		@numero_surtido,
		ltrim(rtrim(@nombre_surtido_flor)),
		@disponible,
		left(@idc_cliente_despacho + '       ' , 7)+@idc_tipo_flor+@idc_variedad_flor+@idc_grado_flor+@idc_caja+convert(nvarchar,@numero_surtido)
		from flor,
		caja,
		cliente_despacho,
		tipo_flor,
		variedad_flor,
		grado_flor,
		tipo_caja
		where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = flor.id_variedad_flor
		and grado_flor.id_grado_flor = flor.id_grado_flor
		and tipo_caja.idc_tipo_caja+caja.idc_caja = @idc_caja
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja

		return scope_identity()
	end
	else
	begin
		update surtido_flor
		set disponible = @disponible,
		nombre_surtido_flor = ltrim(rtrim(@nombre_surtido_flor))
		from cliente_despacho,tipo_flor,variedad_flor,grado_flor,flor,tipo_caja,caja,surtido_flor
		where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = flor.id_variedad_flor
		and grado_flor.id_grado_flor = flor.id_grado_flor
		and tipo_caja.idc_tipo_caja+caja.idc_caja = @idc_caja
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and flor.id_flor = surtido_flor.id_flor
		and caja.id_caja = surtido_flor.id_caja
		and cliente_despacho.id_cliente_despacho = surtido_flor.id_cliente_despacho
		and surtido_flor.numero_surtido = @numero_surtido
	end
end
else
if(@accion = 'modificar')
begin
	update surtido_flor
	set disponible = @disponible,
	nombre_surtido_flor = ltrim(rtrim(@nombre_surtido_flor))
	from cliente_despacho,tipo_flor,variedad_flor,grado_flor,flor,tipo_caja,caja,surtido_flor
	where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = flor.id_variedad_flor
	and grado_flor.id_grado_flor = flor.id_grado_flor
	and tipo_caja.idc_tipo_caja+caja.idc_caja = @idc_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and flor.id_flor = surtido_flor.id_flor
	and caja.id_caja = surtido_flor.id_caja
	and cliente_despacho.id_cliente_despacho = surtido_flor.id_cliente_despacho
	and surtido_flor.numero_surtido = @numero_surtido
end