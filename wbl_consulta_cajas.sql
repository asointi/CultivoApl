/****** Object:  StoredProcedure [dbo].[wbl_consulta_cajas]    Script Date: 10/06/2007 12:39:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_consulta_cajas]

@id_farm integer,
@id_tipo_flor integer,
@id_tapa integer,
@id_tipo_caja integer

AS
BEGIN

SELECT count(*) AS n_id_caja
FROM caja AS c, producto_farm AS p
WHERE p.id_farm=@id_farm AND
p.id_tipo_flor=@id_tipo_flor AND
p.id_tapa=@id_tapa AND
p.id_caja=c.id_caja AND
c.id_tipo_caja=@id_tipo_caja

END
