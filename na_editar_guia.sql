set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_guia]

@idc_guia nvarchar(255),
@fecha_guia nvarchar(255),
@valor_impuesto decimal(20,4),
@valor_flete decimal(20,4),
@idc_estado_guia nvarchar(255)

as

declare @conteo int

select @conteo = count(*) from guia where idc_guia = @idc_guia

if(@conteo < 1)
begin
	declare @id_guia int
	
	set @fecha_guia = convert(datetime, @fecha_guia)

	insert into guia (idc_guia, id_aerolinea, id_estado_guia, id_dia_guia, id_mes_guia, fecha_guia, fecha_transaccion, valor_impuesto, valor_flete, id_ciudad)
	select @idc_guia,
	aerolinea.id_aerolinea,
	estado_guia.id_estado_guia,
	datepart(dw,@fecha_guia),
	datepart(mm,@fecha_guia),
	@fecha_guia,
	getdate(),
	@valor_impuesto,
	@valor_flete,
	ciudad.id_ciudad
	from aerolinea,
	estado_guia,
	ciudad
	where 
	left(@idc_guia,3) = aerolinea.idc_aerolinea
	and @idc_estado_guia = estado_guia.idc_estado_guia	
	and ciudad.idc_ciudad = 'N/A'

	set @id_guia = scope_identity()	 

	insert into fecha_estado_guia (id_guia, id_estado_guia)
	select @id_guia, estado_guia.id_estado_guia
	from estado_guia
	where estado_guia.idc_estado_guia = @idc_estado_guia
end
else
if(@conteo > = 1)
begin
	update guia
	set id_estado_guia = estado_guia.id_estado_guia
	from estado_guia
	where guia.idc_guia = @idc_guia
	and estado_guia.idc_estado_guia = @idc_estado_guia

	insert into fecha_estado_guia (id_guia, id_estado_guia)
	select guia.id_guia, estado_guia.id_estado_guia
	from estado_guia,
	guia
	where estado_guia.idc_estado_guia = @idc_estado_guia
	and guia.idc_guia = @idc_guia
end