SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bouquet_editar_saldos_por_digitar] 

@numero_consecutivo int, 
@cantidad_piezas int, 
@observacion nvarchar(1024),
@id_cuenta_interna int,
@accion nvarchar(25)

as

if(@accion = 'insertar')
begin
	begin try
		insert into descontar_piezas_numero_consecutivo (numero_consecutivo, cantidad_piezas, observacion, id_cuenta_interna)
		values (@numero_consecutivo, @cantidad_piezas, @observacion, @id_cuenta_interna)

		select 1 as resultado
	end try
	begin catch
		select -1 as resultado
	end catch
end
else
if(@accion = 'consultar')
begin
	select top 30 descontar_piezas_numero_consecutivo.id_descontar_piezas_numero_consecutivo,
	descontar_piezas_numero_consecutivo.numero_consecutivo,
	descontar_piezas_numero_consecutivo.cantidad_piezas,
	descontar_piezas_numero_consecutivo.observacion,
	cuenta_interna.nombre as nombre_usuario,
	descontar_piezas_numero_consecutivo.fecha_creacion
	from descontar_piezas_numero_consecutivo,
	cuenta_interna
	where cuenta_interna.id_cuenta_interna = descontar_piezas_numero_consecutivo.id_cuenta_interna
	order by descontar_piezas_numero_consecutivo.id_descontar_piezas_numero_consecutivo
end