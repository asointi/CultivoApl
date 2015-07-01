/*Visualiza los peores 8 rendimientos en la fabricación de ramos*/
select top 8 ROW_NUMBER() over(order by (sum(tallos_por_ramo)/25) desc) as id, 
ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')' as nombre, 
(sum(tallos_por_ramo)/25) as cantidad_ramos 
from ramo_despatado, 
persona, 
mesa, 
mesa_trabajo_persona 
where persona.id_persona = mesa_trabajo_persona.id_persona 
and mesa.id_mesa = mesa_trabajo_persona.id_mesa 
and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona 
and ramo_despatado.fecha_lectura > = dateadd(mi, -60, getdate()) 
and ramo_despatado.id_ramo_despatado > 
(	
	select id_ramo_despatado 	
	from configuracion_bd
) 	
group by persona.id_persona, 	
persona.idc_persona, 	
persona.identificacion, 
ltrim(rtrim(persona.nombre)),
ltrim(rtrim(persona.apellido)),
mesa.idc_mesa,
mesa.idc_mesa, 
mesa.id_mesa 
order by id desc