set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[editar_periferico_asignado] 

@id_asignacion int,
@id_periferico int,
@id_oficina int,
@id_grupo int,
@placa int,
@fecha_desasignado datetime,
@accion nvarchar(50)

AS
declare @contador int
if (@accion = 'insertar')
begin
	select @contador = count(*)
	from Periferico_Asignado
	where id_periferico = @id_periferico
	and estado = 1

	if(@contador = 0)
	begin
		insert into Periferico_Asignado (fecha_asignacion, id_periferico, id_oficina, id_grupo, estado)
		values (GetDate(), @id_periferico, @id_oficina, @id_grupo, 1)
		--Actualizar estado de periferico
		update Periferico set id_estado = 1
		where id_periferico = @id_periferico
		select 1 as ins
	end
	else
	begin
		select -1 as asignado
	end
end

if(@accion = 'eliminar')
begin
	--Actualizar estado de periferico
	update Periferico set id_estado = 2
	where id_periferico = (select id_periferico from Periferico_Asignado where id_asignacion = @id_asignacion)
	
	update Periferico_Asignado set estado = 0
	where id_asignacion = @id_asignacion 
	select 2 as del
--	delete from Periferico_Asignado
--	where id_asignacion = @id_asignacion
--	select 2 as del
end

if(@accion = 'consultar')
begin
	select pa.fecha_asignacion, pa.fecha_desasignado, pa.estado, p.placa, p.serial, m.marca, mo.nombre_modelo, tp.tipo,
	(ar.nombre + ' - ' + per.nombres) as oficina
	from Periferico_Asignado as pa, Periferico as p, Marca_Periferico as m, Modelo as mo, Tipo_Periferico as tp,
	Oficina as ofi, Area as ar, Persona as per
	where pa.id_periferico = p.id_periferico
	and pa.id_oficina = ofi.id_oficina
	and p.id_marca = m.id_marca
	and p.id_modelo = mo.id_modelo
	and p.id_tipo = tp.id_tipo	
	and ofi.id_area = ar.id_area
	and ofi.id_persona = per.id_persona
	and p.placa = case when convert(int, @placa) = 0 then p.placa else @placa end
	order by p.placa
end