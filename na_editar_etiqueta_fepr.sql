set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_etiqueta_fepr]

@id_etiqueta nvarchar(255), 
@id_cuenta_interna int,
@accion nvarchar(255)

as

--Create table [Etiqueta_FEPR]
--(
--	[id_etiqueta] nvarchar(255) NOT NULL,
--	[id_cuenta_interna] Integer NOT NULL
--) 
--go

if(@accion = 'consultar_reporte')
begin
	select convert(int,left(right(id_etiqueta, len(id_etiqueta)-3),len(right(id_etiqueta, len(id_etiqueta)-3))-1)) as id_etiqueta_ifsc into #etiqueta
	from etiqueta_fepr
	where id_cuenta_interna = @id_cuenta_interna
	and left(id_etiqueta, 3) = '235' 

	select convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) as fecha_entrada,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	sum(pieza_postcosecha.unidades_por_pieza) as unidades
	from tipo_flor,
	variedad_flor,
	etiqueta_impresa,
	entrada,
	pieza_postcosecha,
	#etiqueta
	where entrada.id_etiqueta_impresa = etiqueta_impresa.id_etiqueta_impresa
	and etiqueta_impresa.id_etiqueta_impresa = #etiqueta.id_etiqueta_ifsc
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
	and pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
	group by convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor))

	delete from Etiqueta_FEPR
	where Etiqueta_FEPR.id_cuenta_interna = @id_cuenta_interna

	drop table #etiqueta
end
else
if(@accion = 'insertar')
begin
	begin try
		insert into Etiqueta_FEPR (id_etiqueta, id_cuenta_interna)
		values (@id_etiqueta, @id_cuenta_interna)

		select scope_identity() as id_etiqueta_fepr
	end try
	begin catch
		select -1 as id_etiqueta_fepr
	end catch
end