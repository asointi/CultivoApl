set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_item_surtido_flor]

@idc_cliente_despacho nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_caja nvarchar(255),
@numero_surtido int,
@idc_tipo_flor_composicion_surtido nvarchar(255),
@idc_variedad_flor_composicion_surtido nvarchar(255),
@idc_grado_flor_composicion_surtido nvarchar(255),
@idc_capuchon nvarchar(255),
@id_version_surtido_flor int,
@cantidad_ramos int

as

declare @id_surtido_flor int,
@conteo int

select @id_surtido_flor = surtido_flor.id_surtido_flor
from surtido_flor, 
cliente_despacho, 
tipo_flor, 
variedad_flor, 
grado_flor, 
flor, 
tipo_caja, 
caja
where 
cliente_despacho.id_cliente_despacho = surtido_flor.id_cliente_despacho
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = flor.id_variedad_flor
and grado_flor.id_grado_flor = flor.id_grado_flor
and flor.id_flor = surtido_flor.id_flor
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = surtido_flor.id_caja
and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and tipo_caja.idc_tipo_caja+caja.idc_caja = @idc_caja
and surtido_flor.numero_surtido = @numero_surtido

select @conteo = count(*) from version_surtido_flor
where version_surtido_flor.id_surtido_flor = @id_surtido_flor
and version_surtido_flor.id_version_surtido_flor = @id_version_surtido_flor

if(@conteo = 0)
begin
	insert into Version_Surtido_Flor (id_version_surtido_flor, id_surtido_flor, fecha_creacion)
	select @id_version_surtido_flor, @id_surtido_flor, getdate() 
	
	insert into Item_Surtido_Flor (id_flor, id_capuchon, id_surtido_flor, id_version_surtido_flor, cantidad_ramos)
	select flor.id_flor, capuchon.id_capuchon, @id_surtido_flor, @id_version_surtido_flor, @cantidad_ramos
	from flor, capuchon, tipo_flor, variedad_flor, grado_flor
	where tipo_flor.idc_tipo_flor = @idc_tipo_flor_composicion_surtido
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor_composicion_surtido
	and grado_flor.idc_grado_flor = @idc_grado_flor_composicion_surtido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = flor.id_variedad_flor
	and grado_flor.id_grado_flor = flor.id_grado_flor
	and capuchon.idc_capuchon = @idc_capuchon
end
else
begin
	insert into Item_Surtido_Flor (id_flor, id_capuchon, id_surtido_flor, id_version_surtido_flor, cantidad_ramos)
	select flor.id_flor, capuchon.id_capuchon, @id_surtido_flor, @id_version_surtido_flor, @cantidad_ramos
	from flor, capuchon, tipo_flor, variedad_flor, grado_flor
	where tipo_flor.idc_tipo_flor = @idc_tipo_flor_composicion_surtido
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor_composicion_surtido
	and grado_flor.idc_grado_flor = @idc_grado_flor_composicion_surtido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = flor.id_variedad_flor
	and grado_flor.id_grado_flor = flor.id_grado_flor
	and capuchon.idc_capuchon = @idc_capuchon
end
