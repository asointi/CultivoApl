USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_editar_comida_bouquet]    Script Date: 11/08/2014 10:05:03 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/11/08
-- Description:	Editar las comidas de los Bouquets en el Cultivo
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_editar_comida_bouquet] 

@accion nvarchar(255),
@nombre_comida nvarchar(255), 
@id_comida_bouquet int,
@id_version_bouquet int = null

as

declare @conteo int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from comida_bouquet
	where nombre_comida = @nombre_comida

	if(@conteo = 0)
	begin
		insert into comida_bouquet (nombre_comida)
		values (@nombre_comida)

		select scope_identity() as id_comida_bouquet
	end
	else
	begin
		select -1 as id_comida_bouquet
	end
end
else 
if(@accion = 'eliminar')
begin
	begin try
		delete from comida_bouquet
		where id_comida_bouquet = @id_comida_bouquet
		
		select 1 as resultado
	end try 
	begin catch
		select -1 as resultado
	end catch
end
else
if(@accion = 'consultar')
begin
	select id_comida_bouquet,
	nombre_comida
	from comida_bouquet
	where disponible = 1
	order by nombre_comida
end
else
if(@accion = 'alerta_comida')
begin
	select Comida_Bouquet.id_comida_bouquet into #comida_bouquet
	from Version_Bouquet,
	Detalle_Version_Bouquet,
	Comida_Bouquet
	where Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
	and Version_Bouquet.id_version_bouquet = @id_version_bouquet
	and Comida_Bouquet.id_comida_bouquet = Detalle_Version_Bouquet.id_comida_bouquet
	group by Comida_Bouquet.id_comida_bouquet

	select @conteo = count(*) 
	from #comida_bouquet

	if(@conteo = 1)
	begin
		declare @id_comida_bouquet_aux int

		select @id_comida_bouquet_aux = id_comida_bouquet
		from #comida_bouquet
		where id_comida_bouquet = @id_comida_bouquet

		if(@id_comida_bouquet_aux is null)
		begin
			set @conteo = 2
		end
	end
	
	select @conteo as alerta_comida

	drop table #comida_bouquet
end