set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ramo_devuelto_version3]

@idc_ramo_despatado nvarchar(255),
@fecha_inicial nvarchar(15),
@fecha_final nvarchar(15),
@idc_persona_inicial nvarchar(255),
@idc_persona_final nvarchar(255),
@accion nvarchar(255),
@id_tipo_devolucion int

AS

if(@accion = 'insertar')
begin
	declare @id_ramo_despatado int,
	@id_ramo_devuelto int,
	@id_ramo_comprado int,
	@id_ramo int

	select @id_ramo_comprado = ramo_comprado.id_ramo_comprado
	from ramo_comprado
	where ramo_comprado.idc_ramo_comprado = @idc_ramo_despatado

	select @id_ramo = ramo.id_ramo
	from ramo
	where ramo.idc_ramo = @idc_ramo_despatado

	select @id_ramo_despatado = ramo_despatado.id_ramo_despatado
	from ramo_despatado
	where ramo_despatado.idc_ramo_despatado = @idc_ramo_despatado

	select @id_ramo_devuelto = ramo_devuelto.id_ramo_devuelto
	from ramo_devuelto
	where ramo_devuelto.id_ramo_despatado = @id_ramo_despatado

	if(@id_ramo_comprado is not null)
	begin
		select -1 as resultado --El ramo ya entro al inventario
	end
	else
	if(@id_ramo is not null)
	begin
		select -1 as resultado --El ramo ya entro al inventario
	end
	else
	begin
		if(@id_ramo_despatado is null)
		begin
			select -3 as resultado --El ramo NO existe en Despate
		end
		else
		begin
			if(@id_ramo_devuelto is not null)
			begin
				select -2 as resultado --El ramo ya fue devuelto
			end
			else
			begin
				insert into ramo_devuelto (id_ramo_despatado, id_tipo_devolucion)
				values (@id_ramo_despatado, @id_tipo_devolucion)

				select 1 as resultado --La devolucion fue grabada con exito
			end
		end
	end
end
else
if(@accion = 'consultar')
begin
	select ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.idc_persona,
	persona.identificacion,
	ramo_despatado.idc_ramo_despatado as numero_ramo,
	ramo_devuelto.fecha_transaccion as fecha_devolucion,
	convert(nvarchar, ramo_devuelto.fecha_transaccion, 108) as hora_devolucion,
	tipo_devolucion.id_tipo_devolucion,
	tipo_devolucion.nombre_tipo_devolucion
	from ramo_despatado,
	ramo_devuelto,
	persona,
	mesa_trabajo_persona,
	mesa,
	tipo_devolucion
	where tipo_devolucion.id_tipo_devolucion = ramo_devuelto.id_tipo_devolucion
	and ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado
	and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) > = 
	case
		when @fecha_inicial = '' then convert(datetime, '19900101')
		else @fecha_inicial
	end
	and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) < = 
	case
		when @fecha_final = '' then convert(datetime, '21000101')
		else @fecha_final
	end
	and persona.idc_persona > = 
	case
		when @idc_persona_inicial = '' then ''
		else @idc_persona_inicial
	end
	and persona.idc_persona < = 
	case
		when @idc_persona_final = '' then 'ZZZZZZZZZZZZZ'
		else @idc_persona_final
	end
	and ramo_despatado.idc_ramo_despatado > = 
	case
		when @idc_ramo_despatado = '' then '0'
		else @idc_ramo_despatado
	end
	and ramo_despatado.idc_ramo_despatado < =
	case
		when @idc_ramo_despatado = '' then '9999999999999999999999999999'
		else @idc_ramo_despatado
	end
	and ramo_despatado.id_persona = mesa_trabajo_persona.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and persona.id_persona = mesa_trabajo_persona.id_persona
	order by fecha_devolucion desc
end