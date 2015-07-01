set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/09
-- Description:	consulta las fincas en el cultivo
-- =============================================

create PROCEDURE [dbo].[bouquet_editar_capuchon_cultivo] 

@accion nvarchar(255),
@nombre_capuchon nvarchar(255), 
@ancho_superior decimal(20,4), 
@ancho_inferior decimal(20,4), 
@alto decimal(20,4), 
@decorado bit,
@id_capuchon_cultivo int

as

declare @conteo int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from capuchon_cultivo 
	where descripcion = @nombre_capuchon

	if(@conteo = 0)
	begin
		insert into capuchon_cultivo (descripcion, ancho_superior, ancho_inferior, alto, decorado)
		values (@nombre_capuchon, @ancho_superior, @ancho_inferior, @alto, @decorado)

		select scope_identity() as id_capuchon_cultivo
	end
	else
	begin
		select -1 as id_capuchon_cultivo
	end
end
else 
if(@accion = 'eliminar')
begin
	begin try
		delete from capuchon_cultivo
		where id_capuchon_cultivo = @id_capuchon_cultivo
		
		select 1 as resultado
	end try 
	begin catch
		select -1 as resultado
	end catch
end
else
if(@accion = 'consultar')
begin
	select id_capuchon_cultivo,
	descripcion as nombre_capuchon,
	ancho_superior,
	ancho_inferior,
	alto,
	decorado
	from capuchon_cultivo
	where disponible = 1
	order by nombre_capuchon
end