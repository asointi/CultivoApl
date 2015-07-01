set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[siembra_generar_etiqueta_siembra_luna_nueva]

@idc_bloque nvarchar(255),
@numero_nave int

AS

select bloque.idc_bloque,
nave.numero_nave,
case
	when cama.numero_cama > = 10 then cama.numero_cama - 10
	when cama.numero_cama < 10 then cama.numero_cama
end as numero_cama,
case
	when cama.numero_cama > = 10 then 'N'
	when cama.numero_cama < 10 then 'S'
end as tabla,
variedad_flor.nombre_variedad_flor,
datepart(yyyy, sembrar_cama_bloque.fecha) as año_siembra,
datepart(wk, sembrar_cama_bloque.fecha) as semana_siembra,
sembrar_cama_bloque.cantidad_matas as plantas_sembradas,
sembrar_cama_bloque.fecha as fecha_siembra,
case
	when tipo_flor.idc_tipo_flor = 'CL' then dateadd(wk, 5, sembrar_cama_bloque.fecha)
	when tipo_flor.idc_tipo_flor = 'MI' then dateadd(wk, 4, sembrar_cama_bloque.fecha)
end as fecha_despunte,
dateadd(wk, 16, sembrar_cama_bloque.fecha) as fecha_desbotone,
dateadd(wk, 28, sembrar_cama_bloque.fecha) as fecha_pico,
dateadd(wk, 63, sembrar_cama_bloque.fecha) as fecha_erradicacion,
case
	when tipo_flor.idc_tipo_flor = 'CL' then 5
	when tipo_flor.idc_tipo_flor = 'MI' then 4
end as despunte_1,
case
	when tipo_flor.idc_tipo_flor = 'CL' then 7
	when tipo_flor.idc_tipo_flor = 'MI' then 6
end as despunte_2,
case
	when tipo_flor.idc_tipo_flor = 'CL' then 7
	when tipo_flor.idc_tipo_flor = 'MI' then 6
end as resiembra_1,
16 as desbotone_1,
18 as desbotone_2,
20 as desbotone_3,
22 as desbotone_4,
24 as desbotone_5,
26 as desbotone_6
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
cama,
tipo_flor,
variedad_flor,
nave
where bloque.id_bloque = cama_bloque.id_bloque
and nave.id_nave = cama_bloque.id_nave
and cama.id_cama = cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and not exists	
(
	select * 
	from erradicar_cama_bloque
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
)
and bloque.idc_bloque > = 
case
	when @idc_bloque is null then '     '
	else @idc_bloque
end
and bloque.idc_bloque < = 
case
	when @idc_bloque is null then 'ZZZZZ'
	else @idc_bloque
end
and nave.numero_nave > = 
case
	when @numero_nave = 0 then 0
	else @numero_nave
end
and nave.numero_nave < = 
case
	when @numero_nave = 0 then 100
	else @numero_nave
end
order by  bloque.idc_bloque,
nave.numero_nave,
case
	when cama.numero_cama > = 10 then 'N'
	when cama.numero_cama < 10 then 'S'
end,
case
	when cama.numero_cama > = 10 then cama.numero_cama - 10
	when cama.numero_cama < 10 then cama.numero_cama
end