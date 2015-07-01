set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[fls_asignar_numero_tracking]

@numero_tracking bigint, 
@idc_pieza nvarchar(255),
@accion nvarchar(255)

AS

if(@accion = 'asignar_numero_tracking')
begin
	begin try
		insert into pieza_item_orden_floralship (id_pieza, id_item_orden_floralship)
		select pieza.id_pieza, item_orden_floralship.id_item_orden_floralship
		from pieza, item_orden_floralship
		where pieza.idc_pieza = @idc_pieza
		and item_orden_floralship.numero_tracking = @numero_tracking

		select 1 as asignacion
	end try
	begin catch
		select -1 as asignacion
	end catch
end