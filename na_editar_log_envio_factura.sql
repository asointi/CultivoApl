set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_log_envio_factura]

@numero_factura nvarchar(255),
@usuario_cobol nvarchar(255),
@programa_cobol nvarchar(255),
@fecha nvarchar(255),
@hora nvarchar(255)

as

declare @fecha_envio datetime,
@id_log_envio_factura int

set @fecha_envio = (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME))

insert into log_envio_factura (usuario_cobol, programa_cobol, fecha_envio, id_factura)
select @usuario_cobol, @programa_cobol, @fecha_envio, factura.id_factura
from factura
where factura.idc_llave_factura+factura.idc_numero_factura = @numero_factura

set @id_log_envio_factura = scope_identity()

select @id_log_envio_factura as id_log_envio_factura
