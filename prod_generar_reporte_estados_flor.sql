SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[prod_generar_reporte_estados_flor]

@fecha datetime,
@id_variedad_flor int,
@id_item int

as

declare @conteo int,
@conteo_semana_entrante bigint,
@conteo_ocho_semanas bigint,
@produccion_total bigint

create table #temp
(
	id int identity(1,1),
	fecha_inicial datetime,
	fecha_final datetime,
	titulos nvarchar(255)
)

set @conteo = 1

while(@conteo < = 12)
begin
	insert into #temp (fecha_inicial, fecha_final, titulos)
	select @fecha, @fecha + 6, convert(nvarchar, @fecha, 107) + ' - ' + convert(nvarchar, @fecha + 80, 107)
	set @fecha = @fecha - 7

	set @conteo = @conteo  + 1
end

select #temp.id,
#temp.fecha_inicial,
#temp.fecha_final,
#temp.titulos,
sum(pieza_postcosecha.unidades_por_pieza) as unidades_por_pieza into #resultado
from pieza_postcosecha,
variedad_flor,
#temp
where variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor = 0 then 1
	else @id_variedad_flor
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor = 0 then 9999999
	else @id_variedad_flor
end
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
and #temp.id = @id_item
group by #temp.fecha_inicial,
#temp.fecha_final,
#temp.id,
#temp.titulos

insert into #resultado (id, fecha_inicial, fecha_final, titulos, unidades_por_pieza)
select id, fecha_inicial, fecha_final, titulos, 0
from #temp
where not exists
(
	select * 
	from #resultado
	where #resultado.id = #temp.id
)
and #temp.id = @id_item

select @conteo_ocho_semanas = sum(unidades_estimadas)
from conteo_propietario_cama,
detalle_conteo_propietario_cama,
variedad_flor
where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
and conteo_propietario_cama.id_conteo_propietario_cama = 146
and variedad_flor.id_variedad_flor =  detalle_conteo_propietario_cama.id_variedad_flor
and variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor = 0 then 1
	else @id_variedad_flor
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor = 0 then 9999999
	else @id_variedad_flor
end

select @conteo_semana_entrante = sum(unidades_estimadas)
from conteo_propietario_cama,
detalle_conteo_propietario_cama,
variedad_flor
where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
and conteo_propietario_cama.id_conteo_propietario_cama = 145
and variedad_flor.id_variedad_flor =  detalle_conteo_propietario_cama.id_variedad_flor
and variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor = 0 then 1
	else @id_variedad_flor
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor = 0 then 9999999
	else @id_variedad_flor
end

select @produccion_total = sum(pieza_postcosecha.unidades_por_pieza)
from pieza_postcosecha,
variedad_flor,
#temp
where variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor = 0 then 1
	else @id_variedad_flor
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor = 0 then 9999999
	else @id_variedad_flor
end
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
and #temp.id > = 4
and #temp.id < = 11

select *,
case
	when (#resultado.id > = 4 and #resultado.id < = 10) then  (convert(bigint,(isnull(@conteo_ocho_semanas, 0) - isnull(@conteo_semana_entrante, 0)) * unidades_por_pieza)) / @produccion_total
	when #resultado.id = 11 then @conteo_semana_entrante
	else 0
end as conteo
from #resultado
order by id

drop table #temp
drop table #resultado