set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_direccion_pieza]

@idc_pieza nvarchar(255),
@direccion_pieza int

as

declare @id_pieza int

select @id_pieza = pieza.id_pieza
from pieza
where idc_pieza = @idc_pieza

update pieza
set direccion_pieza = @direccion_pieza
where id_pieza = @id_pieza

insert into direccion_pieza (id_pieza, idc_direccion_pieza)
select pieza.id_pieza,
pieza.direccion_pieza
from pieza
where id_pieza = @id_pieza