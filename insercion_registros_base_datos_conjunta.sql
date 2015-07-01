/*borrado tablas*/
drop table temporada_cubo
go
drop table temporada_año
go
drop table temporada
go
drop table año
go
drop table detalle_item_factura
go
drop table pieza
go
drop table cargo
go
drop table detalle_credito
go
drop table item_factura
go
drop table credito
go
drop table factura
go
drop table credito_farm
go
drop table guia
/*********************/
/*creación tablas*/
Create table [Pieza]
(
	[id_pieza] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[idc_pieza] Nvarchar(255) NOT NULL,
	[id_tapa] Integer NOT NULL,
	[id_caja] Integer NOT NULL,
	[id_farm] Integer NOT NULL,
	[id_grado_flor] Integer NOT NULL,
	[id_guia] Integer NOT NULL,
	[id_estado_pieza] Integer NULL,
	[id_variedad_flor] Integer NOT NULL,
	[costo_por_unidad] Decimal(20,4) NOT NULL,
	[unidades_por_pieza] Integer NOT NULL,
	[marca] Nvarchar(255) NULL,
	[disponible] Bit Default 1 NULL,
	[tiene_marca] Bit Default 1 NOT NULL,
	[direccion_pieza] Integer NULL,
	[id_distribuidora_grado_flor] Integer NOT NULL,
	[id_distribuidora_variedad_flor] Integer NOT NULL,
	[id_distribuidora_tapa] Integer NOT NULL,
	[id_distribuidora_estado_pieza] Integer NOT NULL,
	[id_distribuidora_caja] Integer NOT NULL,
	[id_distribuidora_farm] Integer NOT NULL,
	[id_distribuidora_guia] Integer NOT NULL,
Constraint [pk_Pieza] Primary Key ([id_pieza],[id_distribuidora])
) 
go
Create table [Guia]
(
	[id_guia] Integer NOT NULL,
	[id_ciudad] Integer NULL,
	[id_aerolinea] Integer NOT NULL,
	[id_estado_guia] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[idc_guia] Nvarchar(255) NOT NULL,
	[fecha_guia] Datetime NOT NULL,
	[fecha_cambio_estado] Datetime NULL,
	[numero_vuelo] Nvarchar(255) NULL,
	[fecha_salida] Datetime NULL,
	[fecha_llegada] Datetime NULL,
	[fecha_llamada_terminal] Datetime NULL,
	[fecha_llamada_pq] Datetime NULL,
	[fecha_paso_pq] Datetime NULL,
	[nota_pq] Nvarchar(512) NULL,
	[vuelos_adelante_para_pq] Integer NULL,
	[fecha_transaccion] Datetime NULL,
	[valor_impuesto] Decimal(20,4) NOT NULL,
	[valor_flete] Decimal(20,4) NOT NULL,
	[id_distribuidora_aerolinea] Integer NOT NULL,
	[id_distribuidora_estado_guia] Integer NOT NULL,
	[id_distribuidora_ciudad] Integer NOT NULL,
Constraint [pk_Guia] Primary Key ([id_guia],[id_distribuidora])
) 
go
Create table [Factura]
(
	[id_factura] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[id_transportador] Integer NOT NULL,
	[id_tipo_factura] Integer NOT NULL,
	[id_vendedor] Integer NOT NULL,
	[id_cliente_despacho] Integer NOT NULL,
	[idc_llave_factura] Nvarchar(255) NOT NULL,
	[idc_numero_factura] Nvarchar(255) NOT NULL,
	[fecha_factura] Datetime NOT NULL,
	[ciudad_factura] Nvarchar(255) NOT NULL,
	[tipo_credito] Nvarchar(255) NULL,
	[factura_credito] Nvarchar(255) NULL,
	[direccion_factura] Nvarchar(255) NULL,
	[id_distribuidora_tipo_factura] Integer NOT NULL,
	[id_distribuidora_transportador] Integer NOT NULL,
	[id_distribuidora_vendedor] Integer NOT NULL,
	[id_distribuidora_cliente_despacho] Integer NOT NULL,
Constraint [pk_Factura] Primary Key ([id_factura],[id_distribuidora])
) 
go
Create table [Item_Factura]
(
	[id_item_factura] Integer NOT NULL,
	[id_factura] Integer NOT NULL,
	[idc_item_factura] Nvarchar(255) NOT NULL,
	[valor_unitario] Decimal(20,4) NOT NULL,
	[cargo_incluido] Bit Default 1 NOT NULL,
	[id_distribuidora_factura] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
Constraint [pk_Item_Factura] Primary Key ([id_item_factura],[id_distribuidora])
) 
go
Create table [Detalle_Credito]
(
	[id_detalle_credito] Integer NOT NULL,
	[id_tipo_detalle_credito] Integer NOT NULL,
	[id_guia] Integer NOT NULL,
	[id_credito] Integer NOT NULL,
	[id_item_factura] Integer NOT NULL,
	[valor_credito] Decimal(20,4) Default 0 NOT NULL,
	[cantidad_credito] Integer Default 0 NOT NULL,
	[id_distribuidora_guia] Integer NOT NULL,
	[id_distribuidora_item_factura] Integer NOT NULL,
	[id_distribuidora_tipo_detalle_credito] Integer NOT NULL,
	[id_distribuidora_credito] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
Constraint [pk_Detalle_Credito] Primary Key ([id_detalle_credito],[id_distribuidora])
) 
go
Create table [Credito]
(
	[id_credito] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[id_tipo_credito] Integer NOT NULL,
	[id_factura] Integer NOT NULL,
	[idc_numero_credito] Nvarchar(255) NOT NULL,
	[fecha_numero_credito] Datetime NOT NULL,
	[id_distribuidora_tipo_credito] Integer NOT NULL,
	[id_distribuidora_factura] Integer NOT NULL,
Constraint [pk_Credito] Primary Key ([id_credito],[id_distribuidora])
) 
go
Create table [Detalle_Item_Factura]
(
	[id_detalle_item_factura] Integer NOT NULL,
	[id_pieza] Integer NOT NULL,
	[id_item_factura] Integer NOT NULL,
	[id_distribuidora_pieza] Integer NOT NULL,
	[id_distribuidora_item_factura] Integer NOT NULL,
Constraint [pk_Detalle_Item_Factura] Primary Key ([id_pieza],[id_item_factura],[id_distribuidora_pieza],[id_distribuidora_item_factura])
) 
go
Create table [Credito_Farm]
(
	[id_credito_farm] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[id_farm] Integer NOT NULL,
	[id_guia] Integer NOT NULL,
	[idc_credito_farm] Nvarchar(255) NOT NULL,
	[fecha_credito_farm] Datetime NOT NULL,
	[valor_credito_farm] Decimal(20,4) NOT NULL,
	[id_distribuidora_farm] Integer NOT NULL,
	[id_distribuidora_guia] Integer NOT NULL,
Constraint [pk_Credito_Farm] Primary Key ([id_credito_farm],[id_distribuidora])
) 
go
Create table [Cargo]
(
	[id_cargo] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[id_item_factura] Integer NOT NULL,
	[id_tipo_cargo] Integer NOT NULL,
	[valor_cargo] Decimal(20,4) NOT NULL,
	[id_distribuidora_item_factura] Integer NOT NULL,
	[id_distribuidora_tipo_cargo] Integer NOT NULL,
Constraint [pk_Cargo] Primary Key ([id_cargo],[id_distribuidora])
) 
go
Create table [Año]
(
	[id_año] Integer NOT NULL,
	[nombre_año] Nvarchar(255) NOT NULL,
	[id_distribuidora] Integer NOT NULL,
Constraint [pk_Año] Primary Key ([id_año],[id_distribuidora])
) 
go

Create table [Temporada]
(
	[id_temporada] Integer NOT NULL,
	[nombre_temporada] Nvarchar(255) NOT NULL,
	[id_distribuidora] Integer NOT NULL,
Constraint [pk_Temporada] Primary Key ([id_temporada],[id_distribuidora])
) 
go

Create table [Temporada_Año]
(
	[id_temporada_año] Integer NOT NULL,
	[id_temporada] Integer NOT NULL,
	[id_año] Integer NOT NULL,
	[fecha_inicial] Datetime NOT NULL,
	[disponible] Bit Default 0 NOT NULL,
	[id_distribuidora_temporada] Integer NOT NULL,
	[id_distribuidora_año] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
Constraint [pk_Temporada_Año] Primary Key ([id_temporada_año],[id_distribuidora])
) 
go

Create table [Temporada_Cubo]
(
	[id_temporada_cubo] Integer NOT NULL,
	[id_distribuidora] Integer NOT NULL,
	[id_temporada] Integer NOT NULL,
	[id_año] Integer NOT NULL,
	[fecha_inicial] Datetime NOT NULL,
	[fecha_final] Datetime NOT NULL,
Constraint [pk_Temporada_Cubo] Primary Key ([id_temporada_cubo],[id_distribuidora])
) 
go
/****************************************************************/
/*creación de índices*/
Create Index [pieza_id_pieza_index] ON [Pieza] ([id_pieza] ) 
go
Create Index [pieza_id_guia_index] ON [Pieza] ([id_guia] ) 

*/***************************************************************/
/*creación de constraint*/
go
/*tabla año*/
Alter table [Año] add Constraint [pk_distribuidora_año] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
go
/*temporada*/
Alter table [Temporada] add Constraint [pk_distribuidora_temporada] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
go
/*tabla temporada_año*/
Alter table [Temporada_Año] add Constraint [pk_año_temporada_año] foreign key([id_año],[id_distribuidora_año]) references [Año] ([id_año],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Temporada_Año] add Constraint [pk_temporada_temporada_año] foreign key([id_temporada],[id_distribuidora_temporada]) references [Temporada] ([id_temporada],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Temporada_Año] add Constraint [pk_distribuidora_temporada_año] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
go
/*tabla temporada_cubo*/
Alter table [Temporada_Cubo] add Constraint [pk_distribuidora_temporada_cubo] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla guia*/
go
Alter table [Guia] add Constraint [fk_aerolinea_guia] foreign key([id_aerolinea],[id_distribuidora_aerolinea]) references [Aerolinea] ([id_aerolinea],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Guia] add Constraint [fk_ciudad_guia] foreign key([id_ciudad],[id_distribuidora_ciudad]) references [Ciudad] ([id_ciudad],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Guia] add Constraint [fk_estado_guia_guia] foreign key([id_estado_guia],[id_distribuidora_estado_guia]) references [Estado_Guia] ([id_estado_guia],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Guia] add Constraint [pk_distribuidora_guia] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla credito_farm*/
go
Alter table [Credito_Farm] add Constraint [fk_farm_credito_farm] foreign key([id_farm],[id_distribuidora_farm]) references [Farm] ([id_farm],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Credito_Farm] add Constraint [fk_guia_credito_farm] foreign key([id_guia],[id_distribuidora_guia]) references [Guia] ([id_guia],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Credito_Farm] add Constraint [pk_distribuidora_credito_farm] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla factura*/
go
Alter table [Factura] add Constraint [fk_tipo_factura_factura] foreign key([id_tipo_factura],[id_distribuidora_tipo_factura]) references [Tipo_Factura] ([id_tipo_factura],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Factura] add Constraint [fk_Transportador_Factura] foreign key([id_transportador],[id_distribuidora_transportador]) references [Transportador] ([id_transportador],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Factura] add Constraint [fk_vendedor_factura] foreign key([id_vendedor],[id_distribuidora_vendedor]) references [Vendedor] ([id_vendedor],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Factura] add Constraint [fk_cliente_despacho_factura] foreign key([id_cliente_despacho],[id_distribuidora_cliente_despacho]) references [Cliente_Despacho] ([id_cliente_despacho],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Factura] add Constraint [pk_distribuidora_factura] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla credito*/
go
Alter table [Credito] add Constraint [fk_factura_credito] foreign key([id_factura],[id_distribuidora_factura]) references [Factura] ([id_factura],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Credito] add Constraint [fk_tipo_credito_credito] foreign key([id_tipo_credito],[id_distribuidora_tipo_credito]) references [Tipo_Credito] ([id_tipo_credito],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Credito] add Constraint [pk_distribuidora_credito] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla item_factura*/
go
Alter table [Item_Factura] add Constraint [fk_factura_item_factura] foreign key([id_factura],[id_distribuidora_factura]) references [Factura] ([id_factura],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Item_Factura] add Constraint [pk_distribuidora_item_factura] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla detalle_credito*/
go
Alter table [Detalle_Credito] add Constraint [fk_guia_detalle_credito] foreign key([id_guia],[id_distribuidora_guia]) references [Guia] ([id_guia],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Detalle_Credito] add Constraint [fk_item_factura_detalle_credito] foreign key([id_item_factura],[id_distribuidora_item_factura]) references [Item_Factura] ([id_item_factura],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Detalle_Credito] add Constraint [fk_tipo_detalle_credito_detalle_credito] foreign key([id_tipo_detalle_credito],[id_distribuidora_tipo_detalle_credito]) references [Tipo_Detalle_Credito] ([id_tipo_detalle_credito],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Detalle_Credito] add Constraint [fk_credito_detalle_credito] foreign key([id_credito],[id_distribuidora_credito]) references [Credito] ([id_credito],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Detalle_Credito] add Constraint [pk_distribuidora_detalle_credito] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla cargo*/
go
Alter table [Cargo] add Constraint [fk_item_factura_cargo] foreign key([id_item_factura],[id_distribuidora_item_factura]) references [Item_Factura] ([id_item_factura],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Cargo] add Constraint [fk_tipo_cargo_cargo] foreign key([id_tipo_cargo],[id_distribuidora_tipo_cargo]) references [Tipo_Cargo] ([id_tipo_cargo],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Cargo] add Constraint [pk_distribuidora_cargo] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla pieza*/
go
Alter table [Pieza] add Constraint [fk_grado_flor_pieza] foreign key([id_grado_flor],[id_distribuidora_grado_flor]) references [Grado_Flor] ([id_grado_flor],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [fk_caja_pieza] foreign key([id_caja],[id_distribuidora_caja]) references [Caja] ([id_caja],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [fk_tapa_pieza] foreign key([id_tapa],[id_distribuidora_tapa]) references [Tapa] ([id_tapa],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [fk_farm_pieza] foreign key([id_farm],[id_distribuidora_farm]) references [Farm] ([id_farm],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [fk_variedad_flor_pieza] foreign key([id_variedad_flor],[id_distribuidora_variedad_flor]) references [Variedad_Flor] ([id_variedad_flor],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [fk_guia_pieza] foreign key([id_guia],[id_distribuidora_guia]) references [Guia] ([id_guia],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [fk_estado_pieza_pieza] foreign key([id_estado_pieza],[id_distribuidora_estado_pieza]) references [Estado_Pieza] ([id_estado_pieza],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Pieza] add Constraint [pk_distribuidora_pieza] foreign key([id_distribuidora]) references [Distribuidora] ([id_distribuidora])  on update no action on delete no action 
/*tabla detalle_item_factura*/
go
Alter table [Detalle_Item_Factura] add Constraint [pk_pieza_detalle_item_factura] foreign key([id_pieza],[id_distribuidora_pieza]) references [Pieza] ([id_pieza],[id_distribuidora])  on update no action on delete no action 
go
Alter table [Detalle_Item_Factura] add Constraint [pk_item_factura_detalle_item_factura] foreign key([id_item_factura],[id_distribuidora_item_factura]) references [Item_Factura] ([id_item_factura],[id_distribuidora])  on update no action on delete no action 
/***********************************************************************************************************************/

declare @fresca int, @natural int
set @fresca = 1
set @natural = 2

if(@fresca not in (select id_distribuidora from  distribuidora))
begin
	insert into distribuidora (id_distribuidora, nombre_distribuidora)
	values (1,'FRESCA')
end 
if(@natural not in (select id_distribuidora from  distribuidora))
begin
	insert into distribuidora (id_distribuidora, nombre_distribuidora)
	values (2,'NATURAL')
end

/*insercion registros tabla tipo_flor*/
insert into tipo_flor (id_distribuidora_tipo_flor,id_tipo_flor,idc_tipo_flor,nombre_tipo_flor,descripcion,disponible)
select @fresca as id_distribuidora_tipo_flor,id_tipo_flor, idc_tipo_flor, nombre_tipo_flor, descripcion,disponible 
from bd_fresca.dbo.tipo_flor
WHERE not EXISTS
(
SELECT * FROM tipo_flor 
WHERE bd_fresca.dbo.tipo_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.id_distribuidora_tipo_flor = @fresca
)
union
select @natural as id_distribuidora_tipo_flor, id_tipo_flor, idc_tipo_flor, nombre_tipo_flor, descripcion,disponible
FROM bd_nf_replicacion.dbo.tipo_flor 
WHERE not EXISTS
(
SELECT * FROM tipo_flor 
WHERE bd_nf_replicacion.dbo.tipo_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.id_distribuidora_tipo_flor = @natural
)

/*insercion registros tabla color*/
insert into color (id_distribuidora_color,id_color,idc_color,nombre_color,prioridad_color)
select @fresca as id_distribuidora_color,id_color,idc_color,nombre_color,prioridad_color
from bd_fresca.dbo.color
WHERE not EXISTS
(
SELECT * FROM color
WHERE bd_fresca.dbo.color.id_color = color.id_color
and color.id_distribuidora_color = @fresca
)
union
select @natural as id_distribuidora_color,id_color,idc_color,nombre_color,prioridad_color
FROM bd_nf_replicacion.dbo.color
WHERE not EXISTS
(
SELECT * FROM color
WHERE bd_nf_replicacion.dbo.color.id_color = color.id_color
and color.id_distribuidora_color = @natural
)

/*insercion registros tabla aerolinea*/
insert into aerolinea (id_distribuidora, idc_aerolinea, nombre_aerolinea)
select @fresca as id_distribuidora, idc_aerolinea, nombre_aerolinea
from bd_fresca.dbo.aerolinea
WHERE not EXISTS
(
SELECT * FROM aerolinea 
WHERE bd_fresca.dbo.aerolinea.id_aerolinea = aerolinea.id_aerolinea
and aerolinea.id_distribuidora = @fresca
)
union
select @natural as id_distribuidora, idc_aerolinea, nombre_aerolinea
FROM bd_nf_replicacion.dbo.aerolinea 
WHERE not EXISTS
(
SELECT * FROM aerolinea 
WHERE bd_nf_replicacion.dbo.aerolinea.id_aerolinea = aerolinea.id_aerolinea
and aerolinea.id_distribuidora = @natural
)


/*insercion registros tabla tipo_caja*/
insert into tipo_caja (id_tipo_caja, id_distribuidora, idc_tipo_caja, nombre_tipo_caja, nombre_abreviado_tipo_caja, factor_a_full, descripcion, disponible)
select id_tipo_caja, @fresca as id_distribuidora, idc_tipo_caja, nombre_tipo_caja, nombre_abreviado_tipo_caja, factor_a_full, descripcion, disponible
from bd_fresca.dbo.tipo_caja
WHERE not EXISTS
(
SELECT * FROM tipo_caja 
WHERE bd_fresca.dbo.tipo_caja.id_tipo_caja = tipo_caja.id_tipo_caja
and tipo_caja.id_distribuidora = @fresca
)
union
select id_tipo_caja, @natural as id_distribuidora, idc_tipo_caja, nombre_tipo_caja, nombre_abreviado_tipo_caja, factor_a_full, descripcion, disponible
FROM bd_nf_replicacion.dbo.tipo_caja
WHERE not EXISTS
(
SELECT * FROM tipo_caja 
WHERE bd_nf_replicacion.dbo.tipo_caja.id_tipo_caja = tipo_caja.id_tipo_caja
and tipo_caja.id_distribuidora = @natural
)


/*insercion registros tabla tipo_farm*/
insert into tipo_farm (id_tipo_farm, idc_tipo_farm, nombre_tipo_farm, id_distribuidora)
select id_tipo_farm, idc_tipo_farm, nombre_tipo_farm, @fresca as id_distribuidora
from bd_fresca.dbo.tipo_farm
WHERE not EXISTS
(
SELECT * FROM tipo_farm 
WHERE bd_fresca.dbo.tipo_farm.id_tipo_farm = tipo_farm.id_tipo_farm
and tipo_farm.id_distribuidora = @fresca
)
union
select id_tipo_farm, idc_tipo_farm, nombre_tipo_farm, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tipo_farm
WHERE not EXISTS
(
SELECT * FROM tipo_farm 
WHERE bd_nf_replicacion.dbo.tipo_farm.id_tipo_farm = tipo_farm.id_tipo_farm
and tipo_farm.id_distribuidora = @natural
)

/*insercion registros tabla tipo_factura*/
insert into tipo_factura (id_tipo_factura, idc_tipo_factura, nombre_tipo_factura, descripcion_tipo_factura,orden_fija,disponible,id_distribuidora)
select id_tipo_factura, idc_tipo_factura, nombre_tipo_factura, descripcion_tipo_factura,orden_fija,disponible,@fresca as id_distribuidora
from bd_fresca.dbo.tipo_factura
WHERE not EXISTS
(
SELECT * FROM tipo_factura
WHERE bd_fresca.dbo.tipo_factura.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.id_distribuidora = @fresca
)
union
select id_tipo_factura, idc_tipo_factura, nombre_tipo_factura, descripcion_tipo_factura,orden_fija,disponible,@natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tipo_factura
WHERE not EXISTS
(
SELECT * FROM tipo_factura
WHERE bd_nf_replicacion.dbo.tipo_factura.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.id_distribuidora = @natural
)

/*insercion registros tabla tipo_vendedor*/
insert into tipo_vendedor (id_tipo_vendedor, nombre_tipo_vendedor, id_distribuidora)
select id_tipo_vendedor, nombre_tipo_vendedor, @fresca as id_distribuidora
from bd_fresca.dbo.tipo_vendedor
WHERE not EXISTS
(
SELECT * FROM tipo_vendedor
WHERE bd_fresca.dbo.tipo_vendedor.id_tipo_vendedor = tipo_vendedor.id_tipo_vendedor
and tipo_vendedor.id_distribuidora = @fresca
)
union
select id_tipo_vendedor, nombre_tipo_vendedor, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tipo_vendedor
WHERE not EXISTS
(
SELECT * FROM tipo_vendedor
WHERE bd_nf_replicacion.dbo.tipo_vendedor.id_tipo_vendedor = tipo_vendedor.id_tipo_vendedor
and tipo_vendedor.id_distribuidora = @natural
)

/*insercion registros tabla transportador*/
insert into transportador (id_transportador, idc_transportador, nombre_transportador, direccion_transportador, cuenta_transportador, id_distribuidora)
select id_transportador, idc_transportador, nombre_transportador, direccion_transportador, cuenta_transportador, @fresca as id_distribuidora
from bd_fresca.dbo.transportador
WHERE not EXISTS
(
SELECT * FROM transportador
WHERE bd_fresca.dbo.transportador.id_transportador = transportador.id_transportador
and transportador.id_distribuidora = @fresca
)
union
select id_transportador, idc_transportador, nombre_transportador, direccion_transportador, cuenta_transportador, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.transportador
WHERE not EXISTS
(
SELECT * FROM transportador
WHERE bd_nf_replicacion.dbo.transportador.id_transportador = transportador.id_transportador
and transportador.id_distribuidora = @natural
)

/*insercion registros tabla tapa*/
insert into tapa (id_tapa, idc_tapa, nombre_tapa, disponible, id_distribuidora)
select id_tapa, idc_tapa, nombre_tapa, disponible, @fresca as id_distribuidora
from bd_fresca.dbo.tapa
WHERE not EXISTS
(
SELECT * FROM tapa
WHERE bd_fresca.dbo.tapa.id_tapa = tapa.id_tapa
and tapa.id_distribuidora = @fresca
)
union
select id_tapa, idc_tapa, nombre_tapa, disponible, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tapa
WHERE not EXISTS
(
SELECT * FROM tapa
WHERE bd_nf_replicacion.dbo.tapa.id_tapa = tapa.id_tapa
and tapa.id_distribuidora = @natural
)


/*insercion registros tabla estado_pieza*/
insert into estado_pieza (id_estado_pieza, idc_estado_pieza, nombre_estado_pieza, descripcion_estado_pieza, id_distribuidora)
select id_estado_pieza, idc_estado_pieza, nombre_estado_pieza, descripcion_estado_pieza, @fresca as id_distribuidora
from bd_fresca.dbo.estado_pieza
WHERE not EXISTS
(
SELECT * FROM estado_pieza
WHERE bd_fresca.dbo.estado_pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and estado_pieza.id_distribuidora = @fresca
)
union
select id_estado_pieza, idc_estado_pieza, nombre_estado_pieza, descripcion_estado_pieza, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.estado_pieza
WHERE not EXISTS
(
SELECT * FROM estado_pieza
WHERE bd_nf_replicacion.dbo.estado_pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and estado_pieza.id_distribuidora = @natural
)

/*insercion registros tabla estado_guia*/
insert into estado_guia (id_estado_guia, idc_estado_guia, nombre_estado_guia, id_distribuidora)
select id_estado_guia, idc_estado_guia, nombre_estado_guia, @fresca as id_distribuidora
from bd_fresca.dbo.estado_guia
WHERE not EXISTS
(
SELECT * FROM estado_guia
WHERE bd_fresca.dbo.estado_guia.id_estado_guia = estado_guia.id_estado_guia
and estado_guia.id_distribuidora = @fresca
)
union
select id_estado_guia, idc_estado_guia, nombre_estado_guia, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.estado_guia
WHERE not EXISTS
(
SELECT * FROM estado_guia
WHERE bd_nf_replicacion.dbo.estado_guia.id_estado_guia = estado_guia.id_estado_guia
and estado_guia.id_distribuidora = @natural
)

/*insercion registros tabla ciudad*/
insert into ciudad (id_ciudad, idc_ciudad, codigo_aeropuerto, nombre_ciudad, disponible, id_distribuidora)
select id_ciudad, idc_ciudad, codigo_aeropuerto, nombre_ciudad, disponible, @fresca as id_distribuidora
from bd_fresca.dbo.ciudad
WHERE not EXISTS
(
SELECT * FROM ciudad
WHERE bd_fresca.dbo.ciudad.id_ciudad = ciudad.id_ciudad
and ciudad.id_distribuidora = @fresca
)
union
select id_ciudad, idc_ciudad, codigo_aeropuerto, nombre_ciudad, disponible, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.ciudad
WHERE not EXISTS
(
SELECT * FROM ciudad
WHERE bd_nf_replicacion.dbo.ciudad.id_ciudad = ciudad.id_ciudad
and ciudad.id_distribuidora = @natural
)


/*insercion registros tabla tipo_cargo*/
insert into tipo_cargo (id_tipo_cargo, idc_tipo_cargo, nombre_tipo_cargo, id_distribuidora)
select id_tipo_cargo, idc_tipo_cargo, nombre_tipo_cargo, @fresca as id_distribuidora
from bd_fresca.dbo.tipo_cargo
WHERE not EXISTS
(
SELECT * FROM tipo_cargo
WHERE bd_fresca.dbo.tipo_cargo.id_tipo_cargo = tipo_cargo.id_tipo_cargo
and tipo_cargo.id_distribuidora = @fresca
)
union
select id_tipo_cargo, idc_tipo_cargo, nombre_tipo_cargo, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tipo_cargo
WHERE not EXISTS
(
SELECT * FROM tipo_cargo
WHERE bd_nf_replicacion.dbo.tipo_cargo.id_tipo_cargo = tipo_cargo.id_tipo_cargo
and tipo_cargo.id_distribuidora = @natural
)

/*insercion registros tabla tipo_credito*/
insert into tipo_credito (id_tipo_credito, idc_tipo_credito, nombre_tipo_credito, disponible, id_distribuidora)
select id_tipo_credito, idc_tipo_credito, nombre_tipo_credito, disponible, @fresca as id_distribuidora
from bd_fresca.dbo.tipo_credito
WHERE not EXISTS
(
SELECT * FROM tipo_credito
WHERE bd_fresca.dbo.tipo_credito.id_tipo_credito = tipo_credito.id_tipo_credito
and tipo_credito.id_distribuidora = @fresca
)
union
select id_tipo_credito, idc_tipo_credito, nombre_tipo_credito, disponible, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tipo_credito
WHERE not EXISTS
(
SELECT * FROM tipo_credito
WHERE bd_nf_replicacion.dbo.tipo_credito.id_tipo_credito = tipo_credito.id_tipo_credito
and tipo_credito.id_distribuidora = @natural
)

/*insercion registros tabla año*/
insert into año (id_año, nombre_año, id_distribuidora)
select id_año, nombre_año, @fresca as id_distribuidora
from bd_fresca.dbo.año
WHERE not EXISTS
(
SELECT * FROM año
WHERE bd_fresca.dbo.año.id_año = año.id_año
and año.id_distribuidora = @fresca
)
union
select id_año, nombre_año, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.año
WHERE not EXISTS
(
SELECT * FROM año
WHERE bd_nf_replicacion.dbo.año.id_año = año.id_año
and año.id_distribuidora = @natural
)

/*insercion registros tabla temporada*/
insert into temporada (id_temporada, nombre_temporada, id_distribuidora)
select id_temporada, nombre_temporada, @fresca as id_distribuidora
from bd_fresca.dbo.temporada
WHERE not EXISTS
(
SELECT * FROM temporada
WHERE bd_fresca.dbo.temporada.id_temporada = temporada.id_temporada
and temporada.id_distribuidora = @fresca
)
union
select id_temporada, nombre_temporada, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.temporada
WHERE not EXISTS
(
SELECT * FROM temporada
WHERE bd_nf_replicacion.dbo.temporada.id_temporada = temporada.id_temporada
and temporada.id_distribuidora = @natural
)

/*insercion registros tabla tipo_detalle_credito*/
insert into tipo_detalle_credito (id_tipo_detalle_credito, idc_tipo_detalle_credito, nombre_tipo_detalle_credito, id_distribuidora)
select id_tipo_detalle_credito, idc_tipo_detalle_credito, nombre_tipo_detalle_credito, @fresca as id_distribuidora
from bd_fresca.dbo.tipo_detalle_credito
WHERE not EXISTS
(
SELECT * FROM tipo_detalle_credito
WHERE bd_fresca.dbo.tipo_detalle_credito.id_tipo_detalle_credito = tipo_detalle_credito.id_tipo_detalle_credito
and tipo_detalle_credito.id_distribuidora = @fresca
)
union
select id_tipo_detalle_credito, idc_tipo_detalle_credito, nombre_tipo_detalle_credito, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.tipo_detalle_credito
WHERE not EXISTS
(
SELECT * FROM tipo_detalle_credito
WHERE bd_nf_replicacion.dbo.tipo_detalle_credito.id_tipo_detalle_credito = tipo_detalle_credito.id_tipo_detalle_credito
and tipo_detalle_credito.id_distribuidora = @natural
)

/*insercion registros tabla temporada_año*/
insert into temporada_año (id_temporada_año, id_temporada, id_año, fecha_inicial, disponible, id_distribuidora_temporada, id_distribuidora_año,id_distribuidora)
select id_temporada_año, id_temporada, id_año, fecha_inicial, disponible, @fresca as id_distribuidora_temporada, @fresca as id_distribuidora_año, @fresca as id_distribuidora
from bd_fresca.dbo.temporada_año
WHERE not EXISTS
(
SELECT * FROM temporada_año
WHERE bd_fresca.dbo.temporada_año.id_temporada_año = temporada_año.id_temporada_año
and temporada_año.id_distribuidora = @fresca
)
union
select id_temporada_año, id_temporada, id_año, fecha_inicial, disponible, @natural as id_distribuidora_temporada, @natural as id_distribuidora_año, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.temporada_año
WHERE not EXISTS
(
SELECT * FROM temporada_año
WHERE bd_nf_replicacion.dbo.temporada_año.id_temporada_año = temporada_año.id_temporada_año
and temporada_año.id_distribuidora = @natural
)

/*insercion registros tabla temporada_cubo*/
insert into temporada_cubo (id_temporada_cubo, id_distribuidora, id_temporada, id_año, fecha_inicial, fecha_final)
select id_temporada_cubo, @fresca as id_distribuidora, id_temporada, id_año, fecha_inicial, fecha_final
from bd_fresca.dbo.temporada_cubo
WHERE not EXISTS
(
SELECT * FROM temporada_cubo
WHERE bd_fresca.dbo.temporada_cubo.id_temporada_cubo = temporada_cubo.id_temporada_cubo
and temporada_cubo.id_distribuidora = @fresca
)
union
select id_temporada_cubo, @natural as id_distribuidora, id_temporada, id_año, fecha_inicial, fecha_final
FROM bd_nf_replicacion.dbo.temporada_cubo
WHERE not EXISTS
(
SELECT * FROM temporada_cubo
WHERE bd_nf_replicacion.dbo.temporada_cubo.id_temporada_cubo = temporada_cubo.id_temporada_cubo
and temporada_cubo.id_distribuidora = @natural
)

/*insercion registros tabla caja*/
insert into caja (id_caja, id_distribuidora, id_tipo_caja, id_distribuidora_tipo_caja, idc_caja, nombre_caja, medida, disponible, medida_largo, medida_ancho, medida_alto)
select id_caja, @fresca as id_distribuidora, id_tipo_caja, @fresca as id_distribuidora_tipo_caja, idc_caja, nombre_caja, medida, disponible, medida_largo, medida_ancho, medida_alto
from bd_fresca.dbo.caja
WHERE not EXISTS
(
SELECT * FROM caja
WHERE bd_fresca.dbo.caja.id_caja = caja.id_caja
and caja.id_distribuidora = @fresca
)
union
select id_caja, @natural as id_distribuidora, id_tipo_caja, @natural as id_distribuidora_tipo_caja, idc_caja, nombre_caja, medida, disponible, medida_largo, medida_ancho, medida_alto
FROM bd_nf_replicacion.dbo.caja
WHERE not EXISTS
(
SELECT * FROM caja
WHERE bd_nf_replicacion.dbo.caja.id_caja = caja.id_caja
and caja.id_distribuidora = @natural
)

/*insercion registros tabla vendedor*/
insert into vendedor (id_vendedor, id_distribuidora, id_tipo_vendedor, id_distribuidora_tipo_vendedor, idc_vendedor, nombre, correo, telefono)
select id_vendedor, @fresca as id_distribuidora, id_tipo_vendedor, @fresca as id_distribuidora_tipo_vendedor, idc_vendedor, nombre, correo, telefono
from bd_fresca.dbo.vendedor
WHERE not EXISTS
(
SELECT * FROM vendedor
WHERE bd_fresca.dbo.vendedor.id_vendedor = vendedor.id_vendedor
and vendedor.id_distribuidora = @fresca
)
union
select id_vendedor, @natural as id_distribuidora, id_tipo_vendedor, @natural as id_distribuidora_tipo_vendedor, idc_vendedor, nombre, correo, telefono
FROM bd_nf_replicacion.dbo.vendedor
WHERE not EXISTS
(
SELECT * FROM vendedor
WHERE bd_nf_replicacion.dbo.vendedor.id_vendedor = vendedor.id_vendedor
and vendedor.id_distribuidora = @natural
)

/*insercion registros tabla farm*/
insert into farm (id_farm, id_tipo_farm, id_ciudad, idc_farm, nombre_farm, comision_farm, tiene_variedad_flor_exclusiva, observacion, disponible, dias_restados_despacho_distribuidora, id_distribuidora_tipo_farm, id_distribuidora_ciudad, id_distribuidora)
select id_farm, id_tipo_farm, id_ciudad, idc_farm, nombre_farm, comision_farm, tiene_variedad_flor_exclusiva, observacion, disponible, dias_restados_despacho_distribuidora, @fresca as id_distribuidora_tipo_farm, @fresca as id_distribuidora_ciudad, @fresca as id_distribuidora
from bd_fresca.dbo.farm
WHERE not EXISTS
(
SELECT * FROM farm
WHERE bd_fresca.dbo.farm.id_farm = farm.id_farm
and farm.id_distribuidora = @fresca
)
union
select id_farm, id_tipo_farm, id_ciudad, idc_farm, nombre_farm, comision_farm, tiene_variedad_flor_exclusiva, observacion, disponible, dias_restados_despacho_distribuidora, @natural as id_distribuidora_tipo_farm, @natural as id_distribuidora_ciudad, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.farm
WHERE not EXISTS
(
SELECT * FROM farm
WHERE bd_nf_replicacion.dbo.farm.idc_farm = farm.idc_farm
and bd_nf_replicacion.dbo.farm.id_ciudad = farm.id_ciudad
and farm.id_distribuidora = @natural
)
/*insercion registros tabla cliente_factura*/
insert into cliente_factura (id_cliente_factura, id_vendedor, idc_cliente_factura, visualizar_cargos, disponible, pago_con_tarjeta, id_distribuidora, id_distribuidora_vendedor)
select id_cliente_factura, id_vendedor, idc_cliente_factura, visualizar_cargos, disponible, pago_con_tarjeta, @fresca as id_distribuidora, @fresca as id_distribuidora_vendedor
from bd_fresca.dbo.cliente_factura
WHERE not EXISTS
(
SELECT * FROM cliente_factura
WHERE bd_fresca.dbo.cliente_factura.id_cliente_factura = cliente_factura.id_cliente_factura
and cliente_factura.id_distribuidora = @fresca
)
union
select id_cliente_factura, id_vendedor, idc_cliente_factura, visualizar_cargos, disponible, pago_con_tarjeta, @natural as id_distribuidora, @natural as id_distribuidora_vendedor
FROM bd_nf_replicacion.dbo.cliente_factura
WHERE not EXISTS
(
SELECT * FROM cliente_factura
WHERE bd_nf_replicacion.dbo.cliente_factura.id_cliente_factura = cliente_factura.id_cliente_factura
and cliente_factura.id_distribuidora = @natural
)

/*insercion registros tabla cliente_despacho*/
insert into cliente_despacho (id_cliente_despacho, id_distribuidora, id_cliente_factura, idc_cliente_despacho, contacto, direccion, ciudad, estado, telefono, fax, id_distribuidora_cliente_factura)
select id_despacho, @fresca as id_distribuidora, id_cliente_factura, idc_cliente_despacho, contacto, direccion, ciudad, estado, telefono, fax, @fresca as id_distribuidora_cliente_factura
from bd_fresca.dbo.cliente_despacho
WHERE not EXISTS
(
SELECT * FROM cliente_despacho
WHERE bd_fresca.dbo.cliente_despacho.id_despacho = cliente_despacho.id_cliente_despacho
and cliente_despacho.id_distribuidora = @fresca
)
union
select id_despacho, @natural as id_distribuidora, id_cliente_factura, idc_cliente_despacho, contacto, direccion, ciudad, estado, telefono, fax, @natural as id_distribuidora_cliente_factura
FROM bd_nf_replicacion.dbo.cliente_despacho
WHERE not EXISTS
(
SELECT * FROM cliente_despacho
WHERE bd_nf_replicacion.dbo.cliente_despacho.id_despacho = cliente_despacho.id_cliente_despacho
and cliente_despacho.id_distribuidora = @natural
)

/*insercion registros tabla variedad_flor*/
insert into variedad_flor (id_distribuidora,id_distribuidora_color,id_distribuidora_tipo_flor, id_variedad_flor,id_tipo_flor,id_color,idc_variedad_flor,nombre_variedad_flor,descripcion,disponible)
SELECT @fresca as id_distribuidora, @fresca as id_distribuidora_color,@fresca as id_distribuidora_tipo_flor, id_variedad_flor,id_tipo_flor,id_color,idc_variedad_flor,nombre_variedad_flor,descripcion,disponible 
FROM bd_fresca.dbo.variedad_flor 
WHERE not EXISTS
(
SELECT * FROM variedad_flor 
WHERE bd_fresca.dbo.variedad_flor.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_distribuidora = @fresca
)
union
SELECT @natural as id_distribuidora, @natural as id_distribuidora_color, @natural as id_distribuidora_tipo_flor, id_variedad_flor,id_tipo_flor,id_color,idc_variedad_flor,nombre_variedad_flor,descripcion,disponible 
FROM bd_nf_replicacion.dbo.variedad_flor 
WHERE not EXISTS
(
SELECT * FROM variedad_flor 
WHERE bd_nf_replicacion.dbo.variedad_flor.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_distribuidora = @natural
)

/*insercion registros tabla grado_flor*/
insert into grado_flor (id_distribuidora,id_distribuidora_tipo_flor, id_grado_flor,id_tipo_flor,idc_grado_flor,nombre_grado_flor,descripcion,disponible,medidas)
select @fresca as id_distribuidora,@fresca as id_distribuidora_tipo_flor, id_grado_flor,id_tipo_flor,idc_grado_flor,nombre_grado_flor,descripcion,disponible,medidas
from bd_fresca.dbo.grado_flor
WHERE not EXISTS
(
SELECT * FROM grado_flor 
WHERE bd_fresca.dbo.grado_flor.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_distribuidora = @fresca
)
union
select @natural as id_distribuidora,@natural as id_distribuidora_tipo_flor, id_grado_flor,id_tipo_flor,idc_grado_flor,nombre_grado_flor,descripcion,disponible,medidas
FROM bd_nf_replicacion.dbo.grado_flor 
WHERE not EXISTS
(
SELECT * FROM grado_flor 
WHERE bd_nf_replicacion.dbo.grado_flor.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_distribuidora = @natural
)

/*insercion registros tabla configuracion_bd*/
insert into configuracion_bd (fecha_corte_guias, impuesto_carga, cantidad_dias_despacho_finca, cantidad_dias_despacho_finca_preventa, cantidad_dias_atras_inventario, inv_porcentaje_maximo_inventario, inv_cantidad_piezas_maximas, inv_cantidad_piezas_intermedia, inv_porcentaje_minimo_inventario, inv_cantidad_fija_piezas, id_vendedor_global, fecha_actualizacion_cubo_prebooks, corrimiento_preventa_activo, id_temporada_año, inv_tope_maximo_inventario, id_distribuidora)
select fecha_corte_guias, impuesto_carga, cantidad_dias_despacho_finca, cantidad_dias_despacho_finca_preventa, cantidad_dias_atras_inventario, inv_porcentaje_maximo_inventario, inv_cantidad_piezas_maximas, inv_cantidad_piezas_intermedia, inv_porcentaje_minimo_inventario, inv_cantidad_fija_piezas, id_vendedor_global, fecha_actualizacion_cubo_prebooks, corrimiento_preventa_activo, id_temporada_año, inv_tope_maximo_inventario, @fresca as id_distribuidora
from bd_fresca.dbo.configuracion_bd
WHERE not EXISTS
(
SELECT * FROM configuracion_bd
WHERE configuracion_bd.id_distribuidora = @fresca
)
union
select fecha_corte_guias, impuesto_carga, cantidad_dias_despacho_finca, cantidad_dias_despacho_finca_preventa, cantidad_dias_atras_inventario, inv_porcentaje_maximo_inventario, inv_cantidad_piezas_maximas, inv_cantidad_piezas_intermedia, inv_porcentaje_minimo_inventario, inv_cantidad_fija_piezas, id_vendedor_global, fecha_actualizacion_cubo_prebooks, corrimiento_preventa_activo, id_temporada_año, inv_tope_maximo_inventario, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.configuracion_bd
WHERE not EXISTS
(
SELECT * FROM configuracion_bd
WHERE configuracion_bd.id_distribuidora = @natural
)

/*insercion registros tabla orden_pedido*/
insert into orden_pedido (id_orden_pedido, id_orden_pedido_padre, id_variedad_flor, id_grado_flor, id_farm, id_tapa, id_transportador, id_tipo_factura, id_tipo_caja, id_vendedor, id_cliente_despacho, idc_orden_pedido, fecha_inicial, fecha_final, fecha_creacion_orden, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, disponible, comentario, comida, upc, fecha_vencimiento_flor, fecha_para_aprobar, id_distribuidora_variedad_flor, id_distribuidora_grado_flor, id_distribuidora_tipo_caja, id_distribuidora_tipo_factura, id_distribuidora_transportador, id_distribuidora_tapa, id_distribuidora_vendedor, id_distribuidora_farm, id_distribuidora_cliente_despacho, id_distribuidora_orden_pedido, id_distribuidora)
select id_orden_pedido, id_orden_pedido_padre, id_variedad_flor, id_grado_flor, id_farm, id_tapa, id_transportador, id_tipo_factura, id_tipo_caja, id_vendedor, id_despacho, idc_orden_pedido, fecha_inicial, fecha_final, fecha_creacion_orden, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, disponible, comentario, comida, upc, fecha_vencimiento_flor, fecha_para_aprobar, @fresca as id_distribuidora_variedad_flor, @fresca as id_distribuidora_grado_flor, @fresca as id_distribuidora_tipo_caja, @fresca as id_distribuidora_tipo_factura, @fresca as id_distribuidora_transportador, @fresca as id_distribuidora_tapa, @fresca as id_distribuidora_vendedor, @fresca as id_distribuidora_farm, @fresca as id_distribuidora_cliente_despacho, @fresca as id_distribuidora_orden_pedido, @fresca as id_distribuidora
from bd_fresca.dbo.orden_pedido
WHERE not EXISTS
(
SELECT * FROM orden_pedido
WHERE bd_fresca.dbo.orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_distribuidora = @fresca
)
union
select id_orden_pedido, id_orden_pedido_padre, id_variedad_flor, id_grado_flor, id_farm, id_tapa, id_transportador, id_tipo_factura, id_tipo_caja, id_vendedor, id_despacho, idc_orden_pedido, fecha_inicial, fecha_final, fecha_creacion_orden, marca, unidades_por_pieza, cantidad_piezas, valor_unitario, disponible, comentario, comida, upc, fecha_vencimiento_flor, fecha_para_aprobar, @natural as id_distribuidora_variedad_flor, @natural as id_distribuidora_grado_flor, @natural as id_distribuidora_tipo_caja, @natural as id_distribuidora_tipo_factura, @natural as id_distribuidora_transportador, @natural as id_distribuidora_tapa, @natural as id_distribuidora_vendedor, @natural as id_distribuidora_farm, @natural as id_distribuidora_cliente_despacho, @natural as id_distribuidora_orden_pedido, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.orden_pedido
WHERE not EXISTS
(
SELECT * FROM orden_pedido
WHERE bd_nf_replicacion.dbo.orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_distribuidora = @natural
)


/*insercion registros tabla guia*/
insert into guia (id_guia, id_ciudad, id_aerolinea, id_estado_guia, id_distribuidora, idc_guia, fecha_guia, fecha_cambio_estado, numero_vuelo, fecha_salida, fecha_llegada, fecha_llamada_terminal, fecha_llamada_pq, fecha_paso_pq, nota_pq, vuelos_adelante_para_pq, fecha_transaccion, valor_impuesto, valor_flete, id_distribuidora_aerolinea, id_distribuidora_estado_guia, id_distribuidora_ciudad)
select id_guia, isnull(id_ciudad,3) as id_ciudad, id_aerolinea, id_estado_guia, @fresca as id_distribuidora, idc_guia, fecha_guia, fecha_cambio_estado, numero_vuelo, fecha_salida, fecha_llegada, fecha_llamada_terminal, fecha_llamada_pq, fecha_paso_pq, nota_pq, vuelos_adelante_para_pq, fecha_transaccion, valor_impuesto, valor_flete, @fresca as id_distribuidora_aerolinea, @fresca as id_distribuidora_estado_guia, @fresca as id_distribuidora_ciudad
from bd_fresca.dbo.guia
union
select id_guia, isnull(id_ciudad,7) as id_ciudad, id_aerolinea, id_estado_guia, @natural as id_distribuidora, idc_guia, fecha_guia, fecha_cambio_estado, numero_vuelo, fecha_salida, fecha_llegada, fecha_llamada_terminal, fecha_llamada_pq, fecha_paso_pq, nota_pq, vuelos_adelante_para_pq, fecha_transaccion, valor_impuesto, valor_flete, @natural as id_distribuidora_aerolinea, @natural as id_dsitribuidora_estado_guia, @natural as id_distribuidora_ciudad
FROM bd_nf_replicacion.dbo.guia

/*insercion registros tabla credito_farm*/
insert into credito_farm (id_credito_farm, id_distribuidora, id_farm, id_guia, idc_credito_farm, fecha_credito_farm, valor_credito_farm, id_distribuidora_farm, id_distribuidora_guia)
select id_credito_farm, @fresca as id_distribuidora, id_farm, id_guia, idc_credito_farm, fecha_credito_farm, valor_credito_farm, @fresca as id_distribuidora_farm, @fresca as id_distribuidora_guia
from bd_fresca.dbo.credito_farm
union
select id_credito_farm, @natural as id_distribuidora, id_farm, id_guia, idc_credito_farm, fecha_credito_farm, valor_credito_farm, @natural as id_distribuidora_farm, @natural as id_distribuidora_guia
FROM bd_nf_replicacion.dbo.credito_farm

/*insercion registros tabla factura*/
insert into factura (id_factura, id_distribuidora, id_transportador, id_tipo_factura, id_vendedor, id_cliente_despacho, idc_llave_factura, idc_numero_factura, fecha_factura, ciudad_factura, tipo_credito, factura_credito, direccion_factura, id_distribuidora_tipo_factura, id_distribuidora_transportador, id_distribuidora_vendedor, id_distribuidora_cliente_despacho)
select id_factura, @fresca as id_distribuidora, id_transportador, id_tipo_factura, id_vendedor, id_despacho, idc_llave_factura, idc_numero_factura, fecha_factura, ciudad_factura, tipo_credito, factura_credito, direccion_factura, @fresca as id_distribuidora_tipo_factura, @fresca as id_distribuidora_transportador, @fresca as id_distribuidora_vendedor, @fresca as id_distribuidora_cliente_despacho
from bd_fresca.dbo.factura
union
select id_factura, @natural as id_distribuidora, id_transportador, id_tipo_factura, id_vendedor, id_despacho, idc_llave_factura, idc_numero_factura, fecha_factura, ciudad_factura, tipo_credito, factura_credito, direccion_factura, @natural as id_distribuidora_tipo_factura, @natural as id_distribuidora_transportador, @natural as id_distribuidora_vendedor, @natural as id_distribuidora_cliente_despacho
FROM bd_nf_replicacion.dbo.factura

/*insercion registros tabla credito*/
insert into credito (id_credito, id_distribuidora, id_tipo_credito, id_factura, idc_numero_credito, fecha_numero_credito, id_distribuidora_tipo_credito, id_distribuidora_factura)
select id_credito, @fresca as id_distribuidora, id_tipo_credito, id_factura, idc_numero_credito, fecha_numero_credito, @fresca as id_distribuidora_tipo_credito, @fresca as id_distribuidora_factura
from bd_fresca.dbo.credito
union
select id_credito, @natural as id_distribuidora, id_tipo_credito, id_factura, idc_numero_credito, fecha_numero_credito, @natural as id_distribuidora_tipo_credito, @natural as id_distribuidora_factura
FROM bd_nf_replicacion.dbo.credito

/*insercion registros tabla item_factura*/
insert into item_factura (id_item_factura, id_factura, idc_item_factura, valor_unitario, cargo_incluido, id_distribuidora_factura, id_distribuidora)
select id_item_factura, id_factura, idc_item_factura, valor_unitario, cargo_incluido, @fresca as id_distribuidora_factura, @fresca as id_distribuidora
from bd_fresca.dbo.item_factura
union
select id_item_factura, id_factura, idc_item_factura, valor_unitario, cargo_incluido, @natural as id_distribuidora_factura, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.item_factura

/*insercion registros tabla detalle_credito*/
insert into detalle_credito (id_detalle_credito, id_tipo_detalle_credito, id_guia, id_credito, id_item_factura, valor_credito, cantidad_credito, id_distribuidora_guia, id_distribuidora_item_factura, id_distribuidora_tipo_detalle_credito, id_distribuidora_credito, id_distribuidora)
select id_detalle_credito, id_tipo_detalle_credito, id_guia, id_credito, id_item_factura, valor_credito, cantidad_credito, @fresca as id_distribuidora_guia, @fresca as id_distribuidora_item_factura, @fresca as id_distribuidora_tipo_detalle_credito, @fresca as id_distribuidora_credito, @fresca as id_distribuidora
from bd_fresca.dbo.detalle_credito
union
select id_detalle_credito, id_tipo_detalle_credito, id_guia, id_credito, id_item_factura, valor_credito, cantidad_credito, @natural as id_distribuidora_guia, @natural as id_distribuidora_item_factura, @natural as id_distribuidora_tipo_detalle_credito, @natural as id_distribuidora_credito, @natural as id_distribuidora
FROM bd_nf_replicacion.dbo.detalle_credito

/*insercion registros tabla cargo*/
insert into cargo (id_cargo, id_distribuidora, id_item_factura, id_tipo_cargo, valor_cargo, id_distribuidora_item_factura, id_distribuidora_tipo_cargo)
select id_cargo, @fresca as id_distribuidora, id_item_factura, id_tipo_cargo, valor_cargo, @fresca as id_distribuidora_item_factura, @fresca as id_distribuidora_tipo_cargo
from bd_fresca.dbo.cargo
union
select id_cargo, @natural as id_distribuidora, id_item_factura, id_tipo_cargo, valor_cargo, @natural as id_distribuidora_item_factura, @natural as id_distribuidora_tipo_cargo
FROM bd_nf_replicacion.dbo.cargo

/*insercion registros tabla pieza*/
insert into pieza (id_pieza, id_distribuidora, idc_pieza, id_tapa, id_caja, id_farm, id_grado_flor, id_guia, id_estado_pieza, id_variedad_flor, costo_por_unidad, unidades_por_pieza, marca, disponible, tiene_marca, direccion_pieza, id_distribuidora_grado_flor, id_distribuidora_variedad_flor, id_distribuidora_tapa, id_distribuidora_estado_pieza, id_distribuidora_caja, id_distribuidora_farm, id_distribuidora_guia)
select id_pieza, @fresca as id_distribuidora, idc_pieza, id_tapa, id_caja, id_farm, id_grado_flor, id_guia, id_estado_pieza, id_variedad_flor, costo_por_unidad, unidades_por_pieza, marca, disponible, tiene_marca, direccion_pieza, @fresca as id_distribuidora_grado_flor, @fresca as id_distribuidora_variedad_flor, @fresca as id_distribuidora_tapa, @fresca as id_distribuidora_estado_pieza, @fresca as id_distribuidora_caja, @fresca as id_distribuidora_farm, @fresca as id_distribuidora_guia
from bd_fresca.dbo.pieza
union
select id_pieza, @natural as id_distribuidora, idc_pieza, id_tapa, id_caja, id_farm, id_grado_flor, id_guia, id_estado_pieza, id_variedad_flor, costo_por_unidad, unidades_por_pieza, marca, disponible, tiene_marca, direccion_pieza, @natural as id_distribuidora_grado_flor, @natural as id_distribuidora_variedad_flor, @natural as id_distribuidora_tapa, @natural as id_distribuidora_estado_pieza, @natural as id_distribuidora_caja, @natural as id_distribuidora_farm, @natural as id_distribuidora_guia
FROM bd_nf_replicacion.dbo.pieza

/*insercion registros tabla detalle_item_factura*/
insert into detalle_item_factura (id_detalle_item_factura, id_pieza, id_item_factura, id_distribuidora_pieza, id_distribuidora_item_factura)
select id_detalle_item_factura, id_pieza, id_item_factura, @fresca as id_distribuidora_pieza, @fresca as id_distribuidora_item_factura
from bd_fresca.dbo.detalle_item_factura
union
select id_detalle_item_factura, id_pieza, id_item_factura, @natural as id_distribuidora_pieza, @natural as id_distribuidora_item_factura
FROM bd_nf_replicacion.dbo.detalle_item_factura

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/
/******************actualización de tablas que no son borradas del modelo de BD************************/
/******************************************************************************************************/
/******************************************************************************************************/

/*tabla configuracion_bd*/
update configuracion_bd
set fecha_corte_guias = cbd.fecha_corte_guias,
impuesto_carga = cbd.impuesto_carga,
cantidad_dias_despacho_finca = cbd.cantidad_dias_despacho_finca,
cantidad_dias_despacho_finca_preventa = cbd.cantidad_dias_despacho_finca_preventa,
cantidad_dias_atras_inventario = cbd.cantidad_dias_atras_inventario,
inv_porcentaje_maximo_inventario = cbd.inv_porcentaje_maximo_inventario,
inv_cantidad_piezas_maximas = cbd.inv_cantidad_piezas_maximas,
inv_cantidad_piezas_intermedia = cbd.inv_cantidad_piezas_intermedia,
inv_porcentaje_minimo_inventario = cbd.inv_porcentaje_minimo_inventario,
inv_cantidad_fija_piezas = cbd.inv_cantidad_fija_piezas,
id_vendedor_global = cbd.id_vendedor_global,
fecha_actualizacion_cubo_prebooks = cbd.fecha_actualizacion_cubo_prebooks,
corrimiento_preventa_activo = cbd.corrimiento_preventa_activo,
id_temporada_año = cbd.id_temporada_año,
inv_tope_maximo_inventario = cbd.inv_tope_maximo_inventario
from bd_fresca.dbo.configuracion_bd as cbd, bd_distribuidora.dbo.configuracion_bd
where bd_distribuidora.dbo.configuracion_bd.id_distribuidora = @fresca

update configuracion_bd
set fecha_corte_guias = cbd.fecha_corte_guias,
impuesto_carga = cbd.impuesto_carga,
cantidad_dias_despacho_finca = cbd.cantidad_dias_despacho_finca,
cantidad_dias_despacho_finca_preventa = cbd.cantidad_dias_despacho_finca_preventa,
cantidad_dias_atras_inventario = cbd.cantidad_dias_atras_inventario,
inv_porcentaje_maximo_inventario = cbd.inv_porcentaje_maximo_inventario,
inv_cantidad_piezas_maximas = cbd.inv_cantidad_piezas_maximas,
inv_cantidad_piezas_intermedia = cbd.inv_cantidad_piezas_intermedia,
inv_porcentaje_minimo_inventario = cbd.inv_porcentaje_minimo_inventario,
inv_cantidad_fija_piezas = cbd.inv_cantidad_fija_piezas,
id_vendedor_global = cbd.id_vendedor_global,
fecha_actualizacion_cubo_prebooks = cbd.fecha_actualizacion_cubo_prebooks,
corrimiento_preventa_activo = cbd.corrimiento_preventa_activo,
id_temporada_año = cbd.id_temporada_año,
inv_tope_maximo_inventario = cbd.inv_tope_maximo_inventario
from bd_nf_replicacion.dbo.configuracion_bd as cbd, bd_distribuidora.dbo.configuracion_bd
where bd_distribuidora.dbo.configuracion_bd.id_distribuidora = @natural
/*****************************************************************************/
/*tabla tapa*/
update tapa
set nombre_tapa = tp.nombre_tapa,
disponible = tp.disponible
from bd_fresca.dbo.tapa as tp, bd_distribuidora.dbo.tapa
where bd_distribuidora.dbo.tapa.id_distribuidora = @fresca
and bd_distribuidora.dbo.tapa.id_tapa = tp.id_tapa

update tapa
set nombre_tapa = tp.nombre_tapa,
disponible = tp.disponible
from bd_nf_replicacion.dbo.tapa as tp, bd_distribuidora.dbo.tapa
where bd_distribuidora.dbo.tapa.id_distribuidora = @natural
and bd_distribuidora.dbo.tapa.id_tapa = tp.id_tapa
/*****************************************************************************/
/*tabla tipo_flor*/
update tipo_flor
set nombre_tipo_flor = tf.nombre_tipo_flor,
descripcion = tf.descripcion,
disponible = tf.disponible
from bd_fresca.dbo.tipo_flor as tf, bd_distribuidora.dbo.tipo_flor
where bd_distribuidora.dbo.tipo_flor.id_distribuidora_tipo_flor = @fresca
and bd_distribuidora.dbo.tipo_flor.id_tipo_flor = tf.id_tipo_flor

update tipo_flor
set nombre_tipo_flor = tf.nombre_tipo_flor,
descripcion = tf.descripcion,
disponible = tf.disponible
from bd_nf_replicacion.dbo.tipo_flor as tf, bd_distribuidora.dbo.tipo_flor
where bd_distribuidora.dbo.tipo_flor.id_distribuidora_tipo_flor = @natural
and bd_distribuidora.dbo.tipo_flor.id_tipo_flor = tf.id_tipo_flor
/*****************************************************************************/
/*tabla tipo_farm*/
update tipo_farm
set nombre_tipo_farm = tf.nombre_tipo_farm
from bd_fresca.dbo.tipo_farm as tf, bd_distribuidora.dbo.tipo_farm
where bd_distribuidora.dbo.tipo_farm.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_farm.id_tipo_farm = tf.id_tipo_farm

update tipo_farm
set nombre_tipo_farm = tf.nombre_tipo_farm
from bd_nf_replicacion.dbo.tipo_farm as tf, bd_distribuidora.dbo.tipo_farm
where bd_distribuidora.dbo.tipo_farm.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_farm.id_tipo_farm = tf.id_tipo_farm
/*****************************************************************************/
/*tabla tipo_factura*/
update tipo_factura
set nombre_tipo_factura = tf.nombre_tipo_factura,
descripcion_tipo_factura = tf.descripcion_tipo_factura,
orden_fija = tf.orden_fija,
disponible = tf.disponible
from bd_fresca.dbo.tipo_factura as tf, 
bd_distribuidora.dbo.tipo_factura
where bd_distribuidora.dbo.tipo_factura.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_factura.id_tipo_factura = tf.id_tipo_factura

update tipo_factura
set nombre_tipo_factura = tf.nombre_tipo_factura,
descripcion_tipo_factura = tf.descripcion_tipo_factura,
orden_fija = tf.orden_fija,
disponible = tf.disponible
from bd_nf_replicacion.dbo.tipo_factura as tf, 
bd_distribuidora.dbo.tipo_factura
where bd_distribuidora.dbo.tipo_factura.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_factura.id_tipo_factura = tf.id_tipo_factura
/*****************************************************************************/
/*tabla tipo_vendedor*/
update tipo_vendedor
set nombre_tipo_vendedor = tv.nombre_tipo_vendedor
from bd_fresca.dbo.tipo_vendedor as tv, 
bd_distribuidora.dbo.tipo_vendedor
where bd_distribuidora.dbo.tipo_vendedor.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_vendedor.id_tipo_vendedor = tv.id_tipo_vendedor

update tipo_vendedor
set nombre_tipo_vendedor = tv.nombre_tipo_vendedor
from bd_nf_replicacion.dbo.tipo_vendedor as tv, 
bd_distribuidora.dbo.tipo_vendedor
where bd_distribuidora.dbo.tipo_vendedor.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_vendedor.id_tipo_vendedor = tv.id_tipo_vendedor
/*****************************************************************************/
/*tabla vendedor*/
update vendedor
set id_tipo_vendedor = v.id_tipo_vendedor,
nombre = v.nombre,
correo = v.correo,
telefono = v.telefono
from bd_fresca.dbo.vendedor as v, 
bd_distribuidora.dbo.vendedor
where bd_distribuidora.dbo.vendedor.id_distribuidora = @fresca
and bd_distribuidora.dbo.vendedor.id_vendedor = v.id_vendedor

update vendedor
set id_tipo_vendedor = v.id_tipo_vendedor,
nombre = v.nombre,
correo = v.correo,
telefono = v.telefono
from bd_nf_replicacion.dbo.vendedor as v, 
bd_distribuidora.dbo.vendedor
where bd_distribuidora.dbo.vendedor.id_distribuidora = @natural
and bd_distribuidora.dbo.vendedor.id_vendedor = v.id_vendedor
/*****************************************************************************/
/*tabla tipo_detalle_credito*/
update tipo_detalle_credito
set nombre_tipo_detalle_credito = tdc.nombre_tipo_detalle_credito
from bd_fresca.dbo.tipo_detalle_credito as tdc, 
bd_distribuidora.dbo.tipo_detalle_credito
where bd_distribuidora.dbo.tipo_detalle_credito.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_detalle_credito.id_tipo_detalle_credito = tdc.id_tipo_detalle_credito

update tipo_detalle_credito
set nombre_tipo_detalle_credito = tdc.nombre_tipo_detalle_credito
from bd_nf_replicacion.dbo.tipo_detalle_credito as tdc, 
bd_distribuidora.dbo.tipo_detalle_credito
where bd_distribuidora.dbo.tipo_detalle_credito.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_detalle_credito.id_tipo_detalle_credito = tdc.id_tipo_detalle_credito
/*****************************************************************************/
/*tabla tipo_cargo*/
update tipo_cargo
set nombre_tipo_cargo = tc.nombre_tipo_cargo
from bd_fresca.dbo.tipo_cargo as tc, 
bd_distribuidora.dbo.tipo_cargo
where bd_distribuidora.dbo.tipo_cargo.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_cargo.id_tipo_cargo = tc.id_tipo_cargo

update tipo_cargo
set nombre_tipo_cargo = tc.nombre_tipo_cargo
from bd_nf_replicacion.dbo.tipo_cargo as tc, 
bd_distribuidora.dbo.tipo_cargo
where bd_distribuidora.dbo.tipo_cargo.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_cargo.id_tipo_cargo = tc.id_tipo_cargo
/*****************************************************************************/
/*tabla tipo_credito*/
update tipo_credito
set nombre_tipo_credito = tc.nombre_tipo_credito,
disponible = tc.disponible
from bd_fresca.dbo.tipo_credito as tc, 
bd_distribuidora.dbo.tipo_credito
where bd_distribuidora.dbo.tipo_credito.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_credito.id_tipo_credito = tc.id_tipo_credito

update tipo_credito
set nombre_tipo_credito = tc.nombre_tipo_credito,
disponible = tc.disponible
from bd_nf_replicacion.dbo.tipo_credito as tc, 
bd_distribuidora.dbo.tipo_credito
where bd_distribuidora.dbo.tipo_credito.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_credito.id_tipo_credito = tc.id_tipo_credito
/*****************************************************************************/
/*tabla tipo_caja*/
update tipo_caja
set nombre_tipo_caja = tc.nombre_tipo_caja,
nombre_abreviado_tipo_caja = tc.nombre_abreviado_tipo_caja,
factor_a_full = tc.factor_a_full,
descripcion = tc.descripcion,
disponible = tc.disponible
from bd_fresca.dbo.tipo_caja as tc, 
bd_distribuidora.dbo.tipo_caja
where bd_distribuidora.dbo.tipo_caja.id_distribuidora = @fresca
and bd_distribuidora.dbo.tipo_caja.id_tipo_caja = tc.id_tipo_caja

update tipo_caja
set nombre_tipo_caja = tc.nombre_tipo_caja,
nombre_abreviado_tipo_caja = tc.nombre_abreviado_tipo_caja,
factor_a_full = tc.factor_a_full,
descripcion = tc.descripcion,
disponible = tc.disponible
from bd_nf_replicacion.dbo.tipo_caja as tc, 
bd_distribuidora.dbo.tipo_caja
where bd_distribuidora.dbo.tipo_caja.id_distribuidora = @natural
and bd_distribuidora.dbo.tipo_caja.id_tipo_caja = tc.id_tipo_caja
/*****************************************************************************/
/*estado_guia*/
update estado_guia
set nombre_estado_guia = eg.nombre_estado_guia
from bd_fresca.dbo.estado_guia as eg, 
bd_distribuidora.dbo.estado_guia
where bd_distribuidora.dbo.estado_guia.id_distribuidora = @fresca
and bd_distribuidora.dbo.estado_guia.id_estado_guia = eg.id_estado_guia

update estado_guia
set nombre_estado_guia = eg.nombre_estado_guia
from bd_nf_replicacion.dbo.estado_guia as eg, 
bd_distribuidora.dbo.estado_guia
where bd_distribuidora.dbo.estado_guia.id_distribuidora = @natural
and bd_distribuidora.dbo.estado_guia.id_estado_guia = eg.id_estado_guia
/*****************************************************************************/
/*tabla estado_pieza*/
update estado_pieza
set nombre_estado_pieza = ep.nombre_estado_pieza,
descripcion_estado_pieza = ep.descripcion_estado_pieza
from bd_fresca.dbo.estado_pieza as ep, 
bd_distribuidora.dbo.estado_pieza
where bd_distribuidora.dbo.estado_pieza.id_distribuidora = @fresca
and bd_distribuidora.dbo.estado_pieza.id_estado_pieza = ep.id_estado_pieza

update estado_pieza
set nombre_estado_pieza = ep.nombre_estado_pieza,
descripcion_estado_pieza = ep.descripcion_estado_pieza
from bd_nf_replicacion.dbo.estado_pieza as ep, 
bd_distribuidora.dbo.estado_pieza
where bd_distribuidora.dbo.estado_pieza.id_distribuidora = @natural
and bd_distribuidora.dbo.estado_pieza.id_estado_pieza = ep.id_estado_pieza
/*****************************************************************************/
/*tabla aerolinea*/
update aerolinea
set nombre_aerolinea = a.nombre_aerolinea
from bd_fresca.dbo.aerolinea as a, 
bd_distribuidora.dbo.aerolinea
where bd_distribuidora.dbo.aerolinea.id_distribuidora = @fresca
and bd_distribuidora.dbo.aerolinea.id_aerolinea = a.id_aerolinea

update aerolinea
set nombre_aerolinea = a.nombre_aerolinea
from bd_nf_replicacion.dbo.aerolinea as a, 
bd_distribuidora.dbo.aerolinea
where bd_distribuidora.dbo.aerolinea.id_distribuidora = @natural
and bd_distribuidora.dbo.aerolinea.id_aerolinea = a.id_aerolinea
/*****************************************************************************/
/*tabla color*/
update color
set nombre_color = c.nombre_color,
prioridad_color = c.prioridad_color
from bd_fresca.dbo.color as c, 
bd_distribuidora.dbo.color
where bd_distribuidora.dbo.color.id_distribuidora_color = @fresca
and bd_distribuidora.dbo.color.id_color = c.id_color

update color
set nombre_color = c.nombre_color,
prioridad_color = c.prioridad_color
from bd_nf_replicacion.dbo.color as c, 
bd_distribuidora.dbo.color
where bd_distribuidora.dbo.color.id_distribuidora_color = @natural
and bd_distribuidora.dbo.color.id_color = c.id_color
/*****************************************************************************/
/*tabla ciudad*/
update ciudad
set codigo_aeropuerto = c.codigo_aeropuerto,
nombre_ciudad = c.nombre_ciudad,
impuesto_por_caja = c.impuesto_por_caja, 
disponible = c.disponible
from bd_fresca.dbo.ciudad as c, 
bd_distribuidora.dbo.ciudad
where bd_distribuidora.dbo.ciudad.id_distribuidora = @fresca
and bd_distribuidora.dbo.ciudad.id_ciudad = c.id_ciudad

update ciudad
set codigo_aeropuerto = c.codigo_aeropuerto,
nombre_ciudad = c.nombre_ciudad,
impuesto_por_caja = c.impuesto_por_caja, 
disponible = c.disponible
from bd_nf_replicacion.dbo.ciudad as c, 
bd_distribuidora.dbo.ciudad
where bd_distribuidora.dbo.ciudad.id_distribuidora = @natural
and bd_distribuidora.dbo.ciudad.id_ciudad = c.id_ciudad
/*****************************************************************************/
/*tabla caja*/
update caja
set id_tipo_caja = c.id_tipo_caja,
nombre_caja = c.nombre_caja,
medida = c.medida,
disponible = c.disponible,
medida_largo = c.medida_largo,
medida_ancho = c.medida_ancho,
medida_alto = c.medida_alto
from bd_fresca.dbo.caja as c, 
bd_distribuidora.dbo.caja
where bd_distribuidora.dbo.caja.id_distribuidora = @fresca
and bd_distribuidora.dbo.caja.id_caja = c.id_caja

update caja
set id_tipo_caja = c.id_tipo_caja,
nombre_caja = c.nombre_caja,
medida = c.medida,
disponible = c.disponible,
medida_largo = c.medida_largo,
medida_ancho = c.medida_ancho,
medida_alto = c.medida_alto
from bd_nf_replicacion.dbo.caja as c, 
bd_distribuidora.dbo.caja
where bd_distribuidora.dbo.caja.id_distribuidora = @natural
and bd_distribuidora.dbo.caja.id_caja = c.id_caja
/*****************************************************************************/
/*tabla farm*/
update farm
set id_tipo_farm = f.id_tipo_farm,
id_ciudad = f.id_ciudad,
nombre_farm = f.nombre_farm,
comision_farm = f.comision_farm,
tiene_variedad_flor_exclusiva = f.tiene_variedad_flor_exclusiva,
observacion = f.observacion,
disponible = f.disponible,
dias_restados_despacho_distribuidora = f.dias_restados_despacho_distribuidora
from bd_fresca.dbo.farm as f, 
bd_distribuidora.dbo.farm
where bd_distribuidora.dbo.farm.id_distribuidora = @fresca
and bd_distribuidora.dbo.farm.id_farm = f.id_farm

update farm
set id_tipo_farm = f.id_tipo_farm,
id_ciudad = f.id_ciudad,
nombre_farm = f.nombre_farm,
comision_farm = f.comision_farm,
tiene_variedad_flor_exclusiva = f.tiene_variedad_flor_exclusiva,
observacion = f.observacion,
disponible = f.disponible,
dias_restados_despacho_distribuidora = f.dias_restados_despacho_distribuidora
from bd_nf_replicacion.dbo.farm as f, 
bd_distribuidora.dbo.farm
where bd_distribuidora.dbo.farm.id_distribuidora = @natural
and bd_distribuidora.dbo.farm.id_farm = f.id_farm
/*****************************************************************************/
/*tabla transportador*/
update transportador
set nombre_transportador = t.nombre_transportador,
direccion_transportador = t.direccion_transportador,
cuenta_transportador = t.cuenta_transportador
from bd_fresca.dbo.transportador as t, 
bd_distribuidora.dbo.transportador
where bd_distribuidora.dbo.transportador.id_distribuidora = @fresca
and bd_distribuidora.dbo.transportador.id_transportador = t.id_transportador

update transportador
set nombre_transportador = t.nombre_transportador,
direccion_transportador = t.direccion_transportador,
cuenta_transportador = t.cuenta_transportador
from bd_nf_replicacion.dbo.transportador as t, 
bd_distribuidora.dbo.transportador
where bd_distribuidora.dbo.transportador.id_distribuidora = @natural
and bd_distribuidora.dbo.transportador.id_transportador = t.id_transportador
/*****************************************************************************/
/*tabla grado_flor*/
update grado_flor
set id_tipo_flor = gf.id_tipo_flor,
nombre_grado_flor = gf.nombre_grado_flor,
descripcion = gf.descripcion,
disponible = gf.disponible,
medidas = gf.medidas
from bd_fresca.dbo.grado_flor as gf, 
bd_distribuidora.dbo.grado_flor
where bd_distribuidora.dbo.grado_flor.id_distribuidora = @fresca
and bd_distribuidora.dbo.grado_flor.id_grado_flor = gf.id_grado_flor

update grado_flor
set id_tipo_flor = gf.id_tipo_flor,
nombre_grado_flor = gf.nombre_grado_flor,
descripcion = gf.descripcion,
disponible = gf.disponible,
medidas = gf.medidas
from bd_nf_replicacion.dbo.grado_flor as gf, 
bd_distribuidora.dbo.grado_flor
where bd_distribuidora.dbo.grado_flor.id_distribuidora = @natural
and bd_distribuidora.dbo.grado_flor.id_grado_flor = gf.id_grado_flor
/*****************************************************************************/
/*tabla variedad_flor*/
update variedad_flor
set id_tipo_flor = vf.id_tipo_flor,
id_color = vf.id_color,
nombre_variedad_flor = vf.nombre_variedad_flor,
descripcion = vf.descripcion,
disponible = vf.disponible
from bd_fresca.dbo.variedad_flor as vf, 
bd_distribuidora.dbo.variedad_flor
where bd_distribuidora.dbo.variedad_flor.id_distribuidora = @fresca
and bd_distribuidora.dbo.variedad_flor.id_variedad_flor = vf.id_variedad_flor

update variedad_flor
set id_tipo_flor = vf.id_tipo_flor,
id_color = vf.id_color,
nombre_variedad_flor = vf.nombre_variedad_flor,
descripcion = vf.descripcion,
disponible = vf.disponible
from bd_nf_replicacion.dbo.variedad_flor as vf, 
bd_distribuidora.dbo.variedad_flor
where bd_distribuidora.dbo.variedad_flor.id_distribuidora = @natural
and bd_distribuidora.dbo.variedad_flor.id_variedad_flor = vf.id_variedad_flor
/*****************************************************************************/
/*tabla orden_pedido*/
/*borrado de registros que han sido eliminados de las distribuidoras*/
delete from orden_pedido where id_orden_pedido not in 
(
select id_orden_pedido from bd_fresca.dbo.orden_pedido
)
and id_distribuidora = @fresca
delete from orden_pedido where id_orden_pedido not in 
(
select id_orden_pedido from bd_nf_replicacion.dbo.orden_pedido
)
and id_distribuidora = @natural
/*actualizacion de datos*/
update orden_pedido
set id_orden_pedido_padre = op.id_orden_pedido_padre,
id_variedad_flor = op.id_variedad_flor,
id_grado_flor = op.id_grado_flor,
id_farm = op.id_farm,
id_tapa = op.id_tapa,
id_transportador = op.id_transportador,
id_tipo_factura = op.id_tipo_factura,
id_tipo_caja = op.id_tipo_caja,
id_vendedor = op.id_vendedor,
id_cliente_despacho = op.id_despacho,
fecha_inicial = op.fecha_inicial,
fecha_final = op.fecha_final,
fecha_creacion_orden = op.fecha_creacion_orden, 
marca = op.marca,
unidades_por_pieza = op.unidades_por_pieza,
cantidad_piezas = op.cantidad_piezas,
valor_unitario = op.valor_unitario,
disponible = op.disponible,
comentario = op.comentario,
comida = op.comida,
upc = op.upc,
fecha_vencimiento_flor = op.fecha_vencimiento_flor,
fecha_para_aprobar = op.fecha_para_aprobar
from bd_fresca.dbo.orden_pedido as op, 
bd_distribuidora.dbo.orden_pedido
where bd_distribuidora.dbo.orden_pedido.id_distribuidora = @fresca
and bd_distribuidora.dbo.orden_pedido.id_orden_pedido = op.id_orden_pedido

update orden_pedido
set id_orden_pedido_padre = op.id_orden_pedido_padre,
id_variedad_flor = op.id_variedad_flor,
id_grado_flor = op.id_grado_flor,
id_farm = op.id_farm,
id_tapa = op.id_tapa,
id_transportador = op.id_transportador,
id_tipo_factura = op.id_tipo_factura,
id_tipo_caja = op.id_tipo_caja,
id_vendedor = op.id_vendedor,
id_cliente_despacho = op.id_despacho,
fecha_inicial = op.fecha_inicial,
fecha_final = op.fecha_final,
fecha_creacion_orden = op.fecha_creacion_orden, 
marca = op.marca,
unidades_por_pieza = op.unidades_por_pieza,
cantidad_piezas = op.cantidad_piezas,
valor_unitario = op.valor_unitario,
disponible = op.disponible,
comentario = op.comentario,
comida = op.comida,
upc = op.upc,
fecha_vencimiento_flor = op.fecha_vencimiento_flor,
fecha_para_aprobar = op.fecha_para_aprobar
from bd_nf_replicacion.dbo.orden_pedido as op, 
bd_distribuidora.dbo.orden_pedido
where bd_distribuidora.dbo.orden_pedido.id_distribuidora = @natural
and bd_distribuidora.dbo.orden_pedido.id_orden_pedido = op.id_orden_pedido
/*****************************************************************************/
/*tabla cliente_factura*/
update cliente_factura
set id_vendedor = cf.id_vendedor,
visualizar_cargos = cf.visualizar_cargos,
disponible = cf.disponible,
pago_con_tarjeta = cf.pago_con_tarjeta
from bd_fresca.dbo.cliente_factura as cf, 
bd_distribuidora.dbo.cliente_factura
where bd_distribuidora.dbo.cliente_factura.id_distribuidora = @fresca
and bd_distribuidora.dbo.cliente_factura.id_cliente_factura = cf.id_cliente_factura

update cliente_factura
set id_vendedor = cf.id_vendedor,
visualizar_cargos = cf.visualizar_cargos,
disponible = cf.disponible,
pago_con_tarjeta = cf.pago_con_tarjeta
from bd_nf_replicacion.dbo.cliente_factura as cf, 
bd_distribuidora.dbo.cliente_factura
where bd_distribuidora.dbo.cliente_factura.id_distribuidora = @natural
and bd_distribuidora.dbo.cliente_factura.id_cliente_factura = cf.id_cliente_factura
/*****************************************************************************/
/*tabla cliente_despacho*/
update cliente_despacho
set id_cliente_factura = cd.id_cliente_factura,
contacto = cd.contacto,
direccion = cd.direccion,
ciudad = cd.ciudad,
estado = cd.estado,
telefono = cd.telefono,
fax = cd.fax
from bd_fresca.dbo.cliente_despacho as cd, 
bd_distribuidora.dbo.cliente_despacho
where bd_distribuidora.dbo.cliente_despacho.id_distribuidora = @fresca
and bd_distribuidora.dbo.cliente_despacho.id_cliente_despacho = cd.id_despacho

update cliente_despacho
set id_cliente_factura = cd.id_cliente_factura,
contacto = cd.contacto,
direccion = cd.direccion,
ciudad = cd.ciudad,
estado = cd.estado,
telefono = cd.telefono,
fax = cd.fax
from bd_nf_replicacion.dbo.cliente_despacho as cd, 
bd_distribuidora.dbo.cliente_despacho
where bd_distribuidora.dbo.cliente_despacho.id_distribuidora = @natural
and bd_distribuidora.dbo.cliente_despacho.id_cliente_despacho = cd.id_despacho
/*****************************************************************************/