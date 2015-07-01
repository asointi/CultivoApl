select convert(nvarchar,convert(int,mesa.idc_mesa)) as idc_mesa,  
ltrim(rtrim(persona.nombre)) + space(1) +ltrim(rtrim(persona.apellido)) as nombre,  
count(ramo_despatado.id_ramo_despatado) as cantidad_ramos, 
(count(ramo_despatado.id_ramo_despatado) * 100) /  
( 
	select count(ramo_despatado.id_ramo_despatado)  
	from ramo_despatado 
	where convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) = convert(datetime,convert(nvarchar,getdate(),101)) 
	and ramo_despatado.id_persona = persona.id_persona 
) as porcentaje 
from ramo_despatado,  
ramo_devuelto,  
persona,  
mesa_trabajo_persona,  
mesa  
where ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado  
and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) = convert(datetime,convert(nvarchar,getdate(),101))  
and ramo_despatado.id_persona = mesa_trabajo_persona.id_persona  
and mesa.id_mesa = mesa_trabajo_persona.id_mesa  
and persona.id_persona = mesa_trabajo_persona.id_persona  
and isnumeric(mesa.idc_mesa) = 1  
group by convert(int,mesa.idc_mesa),  
ltrim(rtrim(persona.nombre)),  
ltrim(rtrim(persona.apellido)), 
persona.id_persona  

union 

select mesa.idc_mesa,  
ltrim(rtrim(persona.nombre)) + space(1) +ltrim(rtrim(persona.apellido)) as nombre,  
count(ramo_despatado.id_ramo_despatado) as cantidad_ramos, 
(count(ramo_despatado.id_ramo_despatado) * 100) /  
( 	
	select count(ramo_despatado.id_ramo_despatado)  	
	from ramo_despatado 	
	where convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) = convert(datetime,convert(nvarchar,getdate(),101)) 	
	and ramo_despatado.id_persona = persona.id_persona 
) as porcentaje 
from ramo_despatado,  
ramo_devuelto,  
persona,  
mesa_trabajo_persona,  
mesa  
where ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado  
and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) = convert(datetime,convert(nvarchar,getdate(),101))  
and ramo_despatado.id_persona = mesa_trabajo_persona.id_persona  
and mesa.id_mesa = mesa_trabajo_persona.id_mesa  
and persona.id_persona = mesa_trabajo_persona.id_persona  
and isnumeric(mesa.idc_mesa) = 0  
group by mesa.idc_mesa,  
ltrim(rtrim(persona.nombre)),  
ltrim(rtrim(persona.apellido)), 
persona.id_persona 
order by cantidad_ramos desc