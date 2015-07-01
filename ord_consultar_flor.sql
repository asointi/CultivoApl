set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_consultar_flor]

@id_tipo_flor nvarchar(255),
@id_variedad_flor nvarchar(255),
@id_grado_flor nvarchar(255),
@id_flor nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'tipo_flor')
begin
	if(@id_tipo_flor is null and @id_flor is null)
	begin
		select tipo_flor.id_tipo_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '['+tipo_flor.idc_tipo_flor+']' as nombre_tipo_flor_unido
		from tipo_flor,
		flor,
		variedad_flor,
		grado_flor
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor 
		group by 
		tipo_flor.id_tipo_flor,
		tipo_flor.idc_tipo_flor,
		tipo_flor.nombre_tipo_flor
		order by tipo_flor.nombre_tipo_flor
	end
	else if(@id_flor is not null)
	begin
		select tipo_flor.id_tipo_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '['+tipo_flor.idc_tipo_flor+']' as nombre_tipo_flor_unido
		from tipo_flor,
		flor,
		variedad_flor,
		grado_flor
		where flor.id_flor = convert(int,@id_flor)
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor 
		group by 
		tipo_flor.id_tipo_flor,
		tipo_flor.idc_tipo_flor,
		tipo_flor.nombre_tipo_flor
		order by tipo_flor.nombre_tipo_flor
	end
end 
else
if(@accion = 'variedad_flor')
begin
	if(@id_tipo_flor is null and @id_flor is null)
	begin
		select variedad_flor.id_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) +'['+variedad_flor.idc_variedad_flor+']' as nombre_variedad_flor_unido
		from variedad_flor, 
		flor
		where variedad_flor.id_variedad_flor = flor.id_variedad_flor
		group by 
		variedad_flor.id_variedad_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.idc_variedad_flor
		order by variedad_flor.nombre_variedad_flor
	end
	else if(@id_tipo_flor is null and @id_flor is not null)
	begin
		select variedad_flor.id_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) +'['+variedad_flor.idc_variedad_flor+']' as nombre_variedad_flor_unido
		from variedad_flor, 
		flor
		where flor.id_flor = convert(int,@id_flor)
		and variedad_flor.id_variedad_flor = flor.id_variedad_flor
		group by 
		variedad_flor.id_variedad_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.idc_variedad_flor
		order by variedad_flor.nombre_variedad_flor
	end
	else if(@id_tipo_flor is not null and @id_flor is null)
	begin
		select variedad_flor.id_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) +'['+variedad_flor.idc_variedad_flor+']' as nombre_variedad_flor_unido
		from variedad_flor, 
		flor, 
		tipo_flor
		where tipo_flor.id_tipo_flor  = convert(int,@id_tipo_flor)
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = flor.id_variedad_flor
		group by 
		variedad_flor.id_variedad_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.idc_variedad_flor
		order by variedad_flor.nombre_variedad_flor
	end
	else if(@id_tipo_flor is not null and @id_flor is not null)
	begin
		select variedad_flor.id_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) +'['+variedad_flor.idc_variedad_flor+']' as nombre_variedad_flor_unido
		from variedad_flor, 
		flor, 
		tipo_flor
		where flor.id_flor = convert(int,@id_flor)
		and tipo_flor.id_tipo_flor  = convert(int,@id_tipo_flor)
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = flor.id_variedad_flor
		group by 
		variedad_flor.id_variedad_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.idc_variedad_flor
		order by variedad_flor.nombre_variedad_flor
	end
end
else
if(@accion = 'grado_flor')
begin
	if(@id_tipo_flor is null and @id_flor is null)
	begin
		select grado_flor.id_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor))+space(1)+rtrim(ltrim(grado_flor.medidas)) as nombre_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '['+grado_flor.idc_grado_flor+']' as nombre_grado_flor_unido
		from grado_flor, 
		flor
		where grado_flor.id_grado_flor = flor.id_grado_flor
		group by 
		grado_flor.id_grado_flor,
		grado_flor.nombre_grado_flor,
		grado_flor.medidas,
		grado_flor.idc_grado_flor
		order by grado_flor.nombre_grado_flor
	end
	else if(@id_tipo_flor is null and @id_flor is not null)
	begin
		select grado_flor.id_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor))+space(1)+rtrim(ltrim(grado_flor.medidas)) as nombre_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '['+grado_flor.idc_grado_flor+']' as nombre_grado_flor_unido
		from grado_flor, 
		flor
		where flor.id_flor = convert(int,@id_flor)
		and grado_flor.id_grado_flor = flor.id_grado_flor
		group by 
		grado_flor.id_grado_flor,
		grado_flor.nombre_grado_flor,
		grado_flor.medidas,
		grado_flor.idc_grado_flor
		order by grado_flor.nombre_grado_flor
	end
	else if(@id_tipo_flor is not null and @id_flor is null)
	begin
		select grado_flor.id_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor))+space(1)+rtrim(ltrim(grado_flor.medidas)) as nombre_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '['+grado_flor.idc_grado_flor+']' as nombre_grado_flor_unido
		from grado_flor, 
		flor, 
		tipo_flor
		where tipo_flor.id_tipo_flor  = convert(int,@id_tipo_flor)
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and grado_flor.id_grado_flor = flor.id_grado_flor
		group by 
		grado_flor.id_grado_flor,
		grado_flor.nombre_grado_flor,
		grado_flor.medidas,
		grado_flor.idc_grado_flor
		order by grado_flor.nombre_grado_flor
	end
	else if(@id_tipo_flor is not null and @id_flor is not null)
	begin
		select grado_flor.id_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor))+space(1)+rtrim(ltrim(grado_flor.medidas)) as nombre_grado_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '['+grado_flor.idc_grado_flor+']' as nombre_grado_flor_unido
		from grado_flor, 
		flor, 
		tipo_flor
		where flor.id_flor = convert(int,@id_flor)
		and tipo_flor.id_tipo_flor  = convert(int,@id_tipo_flor)
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and grado_flor.id_grado_flor = flor.id_grado_flor
		group by 
		grado_flor.id_grado_flor,
		grado_flor.nombre_grado_flor,
		grado_flor.medidas,
		grado_flor.idc_grado_flor
		order by grado_flor.nombre_grado_flor
	end
end
else
if(@accion = 'flor')
begin
	if(@id_flor is null and @id_tipo_flor is null and @id_variedad_flor is null and @id_grado_flor is null)
	begin
		select 
		flor.id_flor,   
		flor.idc_flor,
		tipo_flor.id_tipo_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' AS nombre_tipo_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as nombre_flor,
		flor.surtido
		from flor,
		variedad_flor,
		grado_flor,
		tipo_flor
		where flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		order by tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		grado_flor.nombre_grado_flor
	end
	else if(@id_flor is not null)
	begin
		select 
		flor.id_flor,   
		flor.idc_flor,
		tipo_flor.id_tipo_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' AS nombre_tipo_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as nombre_flor,
		flor.surtido
		from flor,
		variedad_flor,
		grado_flor,
		tipo_flor
		where flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and flor.id_flor = convert(int,@id_flor)
		order by tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		grado_flor.nombre_grado_flor
	end
	else if(@id_flor is null and @id_tipo_flor is not null and @id_variedad_flor is null and @id_grado_flor is null)
	begin
		select 
		flor.id_flor,   
		flor.idc_flor,
		tipo_flor.id_tipo_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' AS nombre_tipo_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as nombre_flor,
		flor.surtido
		from flor,
		variedad_flor,
		grado_flor,
		tipo_flor
		where flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = convert(int,@id_tipo_flor)
		order by tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		grado_flor.nombre_grado_flor
	end
	else if(@id_flor is null and @id_variedad_flor is not null and @id_grado_flor is null)
	begin
		select 
		flor.id_flor,
		flor.idc_flor,
		tipo_flor.id_tipo_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' AS nombre_tipo_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as nombre_flor,
		flor.surtido
		from flor,
		variedad_flor,
		grado_flor,
		tipo_flor
		where flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = convert(int,@id_variedad_flor)
		order by tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		grado_flor.nombre_grado_flor
	end
	else if(@id_flor is null and @id_variedad_flor is null and @id_grado_flor is not null)
	begin
		select 
		flor.id_flor,
		flor.idc_flor,
		tipo_flor.id_tipo_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' AS nombre_tipo_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as nombre_flor,
		flor.surtido
		from flor,
		variedad_flor,
		grado_flor,
		tipo_flor
		where flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and grado_flor.id_grado_flor  = convert(int,@id_grado_flor)
		order by tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		grado_flor.nombre_grado_flor
	end
	else if(@id_flor is null and @id_variedad_flor is not null and @id_grado_flor is not null)
	begin
		select 
		flor.id_flor,
		flor.idc_flor,
		tipo_flor.id_tipo_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.id_grado_flor,
		rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' AS nombre_tipo_flor,
		rtrim(ltrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		rtrim(ltrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as nombre_flor,
		flor.surtido
		from flor,
		variedad_flor,
		grado_flor,
		tipo_flor
		where flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = convert(int,@id_variedad_flor)
		and grado_flor.id_grado_flor  = convert(int,@id_grado_flor)
		order by tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		grado_flor.nombre_grado_flor
	end
end
else
if(@accion = 'flor_mapeo')
begin
	select idc_flor, 
	rtrim(ltrim(tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(variedad_flor.nombre_variedad_flor))+space(1)+rtrim(ltrim(grado_flor.nombre_grado_flor))+space(1)+rtrim(ltrim(grado_flor.medidas)) as nombre_flor,
	surtido
	from flor,
	variedad_flor,
	grado_flor,
	tipo_flor
	where flor.id_variedad_flor = variedad_flor.id_variedad_flor
	and flor.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and flor.id_flor = convert(int,@id_flor)
end
