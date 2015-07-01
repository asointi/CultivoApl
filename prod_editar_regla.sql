set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_regla]

@id_clasificadora int,
@nombre_regla nvarchar(255)

as

--insert into log_info (mensaje)
--select '@id_clasificadora: ' + isnull(convert(nvarchar,@id_clasificadora), '-1') + ', ' +
--'@nombre_regla: ' + isnull(@nombre_regla,'-1')

set @nombre_regla = replace(@nombre_regla, '"', '')
set @nombre_regla = ltrim(rtrim(@nombre_regla))


declare @id_item int

select @id_item = count(*)
from regla, clasificadora
where regla.id_clasificadora = clasificadora.id_clasificadora
and clasificadora.id_clasificadora = @id_clasificadora
and ltrim(rtrim(regla.nombre_regla)) = ltrim(rtrim(@nombre_regla))

if(@id_item = 0)
begin
	insert into regla (id_clasificadora, id_variedad_flor, nombre_regla)
	values (@id_clasificadora, null, @nombre_regla)
	set @id_item = scope_identity()
	
	insert into tiempo_ejecucion_regla (id_tipo_transaccion, id_regla, fecha_transaccion)
	select tipo_transaccion.id_tipo_transaccion, @id_item, getdate()
	from tipo_transaccion
	where tipo_transaccion.nombre_tipo_transaccion = 'inicio'

	select @id_item as id_regla
end
else 
begin
	select @id_item = regla.id_regla
	from regla, clasificadora
	where regla.id_clasificadora = clasificadora.id_clasificadora
	and clasificadora.id_clasificadora = @id_clasificadora
	and ltrim(rtrim(regla.nombre_regla)) = ltrim(rtrim(@nombre_regla))

	insert into tiempo_ejecucion_regla (id_tipo_transaccion, id_regla, fecha_transaccion)
	select tipo_transaccion.id_tipo_transaccion, @id_item, getdate()
	from tipo_transaccion
	where tipo_transaccion.nombre_tipo_transaccion = 'inicio'

	select @id_item as id_regla
end


