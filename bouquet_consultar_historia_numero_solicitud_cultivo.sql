USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_historia_numero_solicitud_cultivo]    Script Date: 06/01/2015 4:55:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[bouquet_consultar_historia_numero_solicitud_cultivo] 

@numero_sol int

as

create table #resultado
(
	tipo_orden nvarchar(25),
	nombre_usuario nvarchar(25),
	fecha_transaccion datetime,
	fecha_vuelo datetime,
	cantidad_piezas int,
	observacion nvarchar(1024)
)

insert into #resultado
(
	tipo_orden,
	nombre_usuario,
	fecha_transaccion,
	fecha_vuelo,
	cantidad_piezas,
	observacion
)
exec	bd_fresca.bd_fresca.dbo.bouquet_consultar_historia_numero_solicitud
		@numero_solicitud = @numero_sol

select tipo_orden as Tipo_transaccion,
nombre_usuario as Usuario,
fecha_transaccion as Fecha_transaccion,
fecha_vuelo as Fecha_vuelo,
cantidad_piezas as Piezas,
observacion as Observacion,
null as Pepr
from #resultado
union all
select 'Justificado',
Cuenta_Interna.nombre as nombre_cuenta,
Descontar_Piezas_Numero_Consecutivo.fecha_creacion,
null, 
sum(cantidad_piezas),
Descontar_Piezas_Numero_Consecutivo.observacion,
null as idc_pedido_pepr
from Descontar_Piezas_Numero_Consecutivo,
cuenta_interna
where Cuenta_Interna.id_cuenta_interna = Descontar_Piezas_Numero_Consecutivo.id_cuenta_interna
and Descontar_Piezas_Numero_Consecutivo.numero_consecutivo = @numero_sol
group by Cuenta_Interna.nombre,
Descontar_Piezas_Numero_Consecutivo.fecha_creacion,
Descontar_Piezas_Numero_Consecutivo.observacion

drop table #resultado