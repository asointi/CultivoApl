/****** Object:  StoredProcedure [dbo].[wbl_crear_etiqueta]    Script Date: 10/06/2007 12:30:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_crear_etiqueta] 

@cod NVARCHAR(255),
@farm NVARCHAR(2),
@tipo NVARCHAR(2),
@variedad NVARCHAR(2),
@grado NVARCHAR(2),
@tapa NVARCHAR(2),
@tipo_caja NVARCHAR(2),
@marca NVARCHAR(5),
@unidades_caja INT,
@usuario  NVARCHAR(50),
@fecha DATETIME,
@fecha_digita DATETIME

AS
	
declare @id_etiqueta nvarchar(25),
@id_farm_cobol nvarchar(5),
@codnueva nvarchar(25),
@body1 varchar(200),
@subject1 varchar(200)

select @id_farm_cobol = id_farm_cobol from Globales_Sql
select @id_etiqueta = max(id_etiqueta) + 1 from Etiqueta

if(@id_etiqueta is null)
begin
	set @codnueva = @id_farm_cobol + '00000001'
end
else 
begin
	while(len(@id_etiqueta) <> 8)
	begin
		set @id_etiqueta = '0' + @id_etiqueta
	end

	set @codnueva = @id_farm_cobol + @id_etiqueta
end

INSERT INTO ETIQUETA 
(
	codigo, 
	farm, 
	tipo, 
	variedad, 
	grado, 
	tapa, 
	tipo_caja, 
	marca, 
	unidades_por_caja, 
	usuario, 
	fecha, 
	fecha_digita
)
VALUES 
(
	@codnueva, 
	@farm, 
	@tipo, 
	@variedad, 
	@grado, 
	@tapa, 
	@tipo_caja, 
	@marca, 
	@unidades_caja, 
	@usuario, 
	@fecha, 
	@fecha_digita
)

declare @id_etiqueta_aux int

set @id_etiqueta_aux = scope_identity()

insert into etiqueta_impresa (id_etiqueta, id_usuario)
select @id_etiqueta_aux,
usuarios.id_usuarios
from usuarios
where usuarios.usuario = @usuario

select @id_etiqueta_aux as id_etiqueta