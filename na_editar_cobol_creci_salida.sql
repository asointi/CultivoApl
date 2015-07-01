set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_cobol_creci_salida]

@idc_pieza nvarchar(255),
@fecha nvarchar(255),
@hora nvarchar(255)

AS

declare @conteo int
select @conteo = count(*) from cobol_creci_salida
where idc_pieza = @idc_pieza

Begin try
	if(@conteo > 0)
	begin
		update cobol_creci_salida 
		set fecha_lectura = (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME))
		where idc_pieza = @idc_pieza
		select 1 AS COD_ERROR
	end 
	else
	if(@conteo = 0)
	begin
		insert into cobol_creci_salida (idc_pieza,fecha_lectura)
		values (@idc_pieza, (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)))
		select 1 as COD_ERROR
	end
End try
Begin catch
	select 0 as COD_ERROR
End catch
