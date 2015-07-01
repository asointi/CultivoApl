SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[na_consultar_comida_bouquet]

AS

select id_comida_bouquet,
nombre_comida as nombre_comida_bouquet
from comida_bouquet
where disponible = 1
order by nombre_comida_bouquet