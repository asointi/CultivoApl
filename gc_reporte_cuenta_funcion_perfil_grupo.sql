/****** Object:  StoredProcedure [dbo].[gc_reporte_cuenta_funcion_perfil_grupo]    Script Date: 10/06/2007 11:39:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_reporte_cuenta_funcion_perfil_grupo]

AS

select c.nombre,a.nombre_ap, 
f.nombre_funcion, 
'Perfil: ' + p.nombre_perfil as perfil_grupo,
c.esta_activo
from cuenta_interna as c, 
aplicacion as a, 
funcion as f, 
perfil as p, 
cuenta_interna_perfil as cp, 
permiso_perfil as pp
where c.id_cuenta_interna = cp.id_cuenta_interna 
and cp.id_perfil = p.id_perfil
and p.id_perfil = pp.id_perfil
and pp.id_funcion = f.id_funcion
and f.id_ap = a.id_ap

UNION ALL

select c.nombre,a.nombre_ap, 
f.nombre_funcion,
'Grupo : ' +  g.nombre_grupo,
c.esta_activo
from cuenta_interna as c, 
aplicacion as a, 
funcion as f, 
grupo as g, 
cuenta_interna_grupo as cg, 
permiso_grupo as pg
where c.id_cuenta_interna = cg.id_cuenta_interna
and cg.id_grupo = g.id_grupo
and g.id_grupo = pg.id_grupo
and pg.id_funcion = f.id_funcion
and f.id_ap = a.id_ap
order by nombre,nombre_ap,nombre_funcion
