CREATE TABLE [dbo].[ETIQUETA_CRECI](
	[etiqueta] [nvarchar](255) NOT NULL,
	[creci] [varchar](10) NOT NULL,
	[fecha] [datetime] NOT NULL CONSTRAINT [DF_ETIQUETA_CRECI_fecha]  DEFAULT (getdate()),
 CONSTRAINT [PK_ETIQUETA_CRECI] PRIMARY KEY CLUSTERED 
(
	[etiqueta] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ETIQUETA_CRECI]  WITH CHECK ADD  CONSTRAINT [FK_ETIQUETA_CRECI_ETIQUETA] FOREIGN KEY([etiqueta])
REFERENCES [dbo].[ETIQUETA] ([codigo])
GO
ALTER TABLE [dbo].[ETIQUETA_CRECI] CHECK CONSTRAINT [FK_ETIQUETA_CRECI_ETIQUETA]
GO
CREATE TABLE [dbo].[Etiqueta_Receiving](
	[Etiqueta] [nvarchar](255) NULL,
	[Creci] [varchar](10) NULL,
	[Fecha] [datetime] NULL
) ON [PRIMARY]

INSERT INTO cuenta_interna
	VALUES ('sa','Super Administrador',getdate(),'clave_hash',
		'aleatorio',1,'webmaster@natuflora.net',null,'Usuario por defecto de la aplicación')

INSERT INTO aplicacion
	VALUES(1,'Gestión de Cuentas','~/Aplicaciones/GCuentas/GCuentas.aspx','Aplicación para la gestión de cuentas y control de acceso a las funciones de las aplicaciones.')
INSERT INTO aplicacion
	VALUES(2,'Wishlist','~/Aplicaciones/Wishlist/Wishlist.aspx','Application to performe the creation, request and confimation of wishlists.')
INSERT INTO aplicacion
	VALUES(3,'Bancos','~/Aplicaciones/Bancos/Bancos.aspx','Aplicación para la gestion de cuentas bancarias.')
INSERT INTO aplicacion
	VALUES(4,'General','~/Aplicaciones/General/General.aspx','Aplicación para la gestion de información general a todas las aplicaciones del sistema.')
INSERT INTO aplicacion
	VALUES(5,'Sensorsoft','~/Aplicaciones/Sensorsoft/Sensorsoft.aspx','Aplicación para la gestion de sensores del cultivo.')
INSERT INTO aplicacion
	VALUES(6,'Invoicing','~/Aplicaciones/Invoicing/Invoicing.aspx','Application to performe all about invoicing.')
INSERT INTO aplicacion
	VALUES(7,'FloraStats','~/Aplicaciones/FloraStats/FloraStats.aspx','Application to configure and generate the Flora Stats Report.')
INSERT INTO aplicacion
	VALUES(8,'Produccion','~/Aplicaciones/Produccion/Produccion.aspx','Aplicacion que gestiona los productos disponibles en la empresa.')
INSERT INTO aplicacion
	VALUES(9,'Gestion Cuentas Externas','~/Aplicaciones/GCuentasExternas/GCuentasExternas.aspx','Aplicacion que gestiona las cuentas de clientes y fincas en la extranet.')
INSERT INTO aplicacion
	VALUES(10,'Prebooks','~/Aplicaciones/Preventa/Preventa.aspx','All about prebooks.')
INSERT INTO aplicacion
	VALUES(11,'Farms Fixed Orders & Prebooks','~/Aplicaciones/FarmsFixedOrdersAndPrebooks/FarmsFixedOrdersAndPrebooks.aspx','Farms Fixed Orders and Prebooks')
INSERT INTO aplicacion
	VALUES(12,'Bouquetera','~/Aplicaciones/Bouquetera/Bouquetera.aspx','Bouquetera')
INSERT INTO aplicacion
	VALUES(13,'Proveedores','~/Aplicaciones/Proveedores/Proveedores.aspx','Proveedores')
INSERT INTO aplicacion
	VALUES(14,'Inventory','~/Aplicaciones/Inventario/Inventario.aspx','Inventory')
INSERT INTO aplicacion
	VALUES(15,'Fixed Orders and Prebooks','~/Aplicaciones/FixedOrdersAndPrebooks/FixedOrdersAndPrebooks.aspx','FixedOrdersAndPrebooks')
INSERT INTO aplicacion
	VALUES(16,'Sales','~/Aplicaciones/Ventas/Ventas.aspx','Sales')
INSERT INTO aplicacion
	VALUES(17,'Weblabels','~/Aplicaciones/Weblabels/Weblabels.aspx','Weblabels')
INSERT INTO aplicacion
	VALUES(18,'Application','~/Aplicaciones/Application/Application.aspx','Application control')
INSERT INTO aplicacion
	VALUES(19,'Ordenes','~/Aplicaciones/Ordenes/Ordenes.aspx','Edicion de Preventas y Ordenes fijas')
INSERT INTO aplicacion
	VALUES(20,'Pagina Web','~/Aplicaciones/PaginaWeb/PaginaWeb.aspx','Configurar y editar contenidos pagina web')
INSERT INTO aplicacion
	VALUES(21,'Distribuidora','~/Aplicaciones/Distribuidora/Distribuidora.aspx','Reportes de distribuidoras')
INSERT INTO aplicacion
	VALUES(22,'Autorización Horas Extras','~/Aplicaciones/AutorizacionHorasExtras/AutorizacionHorasExtras.aspx','Autorización Horas Extras')
INSERT INTO aplicacion
	VALUES(23,'Siembras','~/Aplicaciones/Siembras/Siembras.aspx','Siembras')
INSERT INTO aplicacion
	VALUES(24,'Estimados','~/Aplicaciones/Estimados/Estimados.aspx','Siembras')
INSERT INTO aplicacion
	VALUES(25,'Pantallas TV','~/Aplicaciones/Pantalla_TV/Pantalla_TV.aspx','Pantallas TV')
INSERT INTO aplicacion
	VALUES(26,'MaxiPuntos','~/Aplicaciones/MaxiPuntos/MaxiPuntos.aspx','MaxiPuntos')
INSERT INTO aplicacion
	VALUES(27,'Aprobación de Ordenes','~/Aplicaciones/Aprobar_Ordenes/Aprobar_Ordenes.aspx','Aprobación de Ordenes')

INSERT INTO funcion
	VALUES(1,1,1,'Consultar Cuentas','~/Aplicaciones/GCuentas/Consulta/ConsultarCuentas.aspx','Permite ver todas las cuentas del sistemas')
INSERT INTO funcion
	VALUES(2,1,2,'Consultar Perfiles','~/Aplicaciones/GCuentas/Consulta/ConsultarPerfiles.aspx','Permite ver todos los Perfiles sistemas')
INSERT INTO funcion
	VALUES(3,1,3,'Consultar Grupos','~/Aplicaciones/GCuentas/Consulta/ConsultarGrupos.aspx','Permite ver todos los Grupos sistemas')
INSERT INTO funcion
	VALUES(4,1,4,'Editar Cuentas','~/Aplicaciones/GCuentas/Formulario/EditarCuentas.aspx','Permite Ingresar, Modificar y Eliminar Cuentas del sistema')
INSERT INTO funcion
	VALUES(5,1,5,'Editar Perfiles','~/Aplicaciones/GCuentas/Formulario/EditarPerfiles.aspx','Permite Ingresar, Modificar y Eliminar Perfiles del sistema')
INSERT INTO funcion
	VALUES(6,1,6,'Editar Grupos','~/Aplicaciones/GCuentas/Formulario/EditarGrupos.aspx','Permite Ingresar, Modificar y Eliminar Grupos del sistema')
INSERT INTO funcion
	VALUES(7,1,7,'Editar Permisos de Cuenta','~/Aplicaciones/GCuentas/Formulario/EditarPermisosCuenta.aspx','Permite Ingresar, Modificar y Eliminar Perfiles y Grupos de una Cuenta del Sistema')
INSERT INTO funcion
	VALUES(43,1,8,'Editar Permisos de Función','~/Aplicaciones/GCuentas/Formulario/EditarPermisosFuncion.aspx','Permite Adicionar y Eliminar Funciones a Perfiles y Grupos.')
INSERT INTO funcion
	VALUES(19,1,9,'Editar Cuentas de Perfil','~/Aplicaciones/GCuentas/Formulario/EditarCuentasDePerfil.aspx','Permite Agregar o Remover Cuentas de un Perfil.')
INSERT INTO funcion
	VALUES(20,1,10,'Editar Cuentas de Grupo','~/Aplicaciones/GCuentas/Formulario/EditarCuentasDeGrupo.aspx','Permite Agregar o Remover Cuentas de un Grupo.')
INSERT INTO funcion
	VALUES(8,1,11,'Editar Funciones de Perfil','~/Aplicaciones/GCuentas/Formulario/EditarFuncionesPerfil.aspx','Permite Ingresar, Modificar y Eliminar Funciones de un Perfil del Sistema')
INSERT INTO funcion
	VALUES(9,1,12,'Editar Funciones de Grupo','~/Aplicaciones/GCuentas/Formulario/EditarFuncionesGrupo.aspx','Permite Ingresar, Modificar y Eliminar Funciones de un Grupo del Sistema')
INSERT INTO funcion
	VALUES(21,1,13,'Generar Reportes de Cuentas','~/Aplicaciones/GCuentas/Reporte/ReportesGcuentas.aspx','Genera Reportes de la aplicación de Cuentas.')

INSERT INTO funcion
	VALUES(10,2,1,'Create and Modify Wishlists','~/Aplicaciones/Wishlist/Formulario/EditarWishlist.aspx','Allow you to create and modify a Wishlist')
INSERT INTO funcion
	VALUES(11,2,2,'Request Wishlist Items','~/Aplicaciones/Wishlist/Formulario/EditarSolicitudes.aspx','Allow you to create and modify Wishlist Requests')
INSERT INTO funcion
	VALUES(12,2,3,'Confirm Request of Wishlist Items','~/Aplicaciones/Wishlist/Formulario/EditarConfirmaciones.aspx','Confirm the Requests of each Wishlist Items')

INSERT INTO funcion
	VALUES(13,3,1,'Editar Bancos','~/Aplicaciones/Bancos/Formulario/EditarBancos.aspx','Permite Ingresar y modificar la información de los Bancos.')
INSERT INTO funcion
	VALUES(14,3,2,'Editar Cuentas Bancarias','~/Aplicaciones/Bancos/Formulario/EditarCuentaBancaria.aspx','Permite Ingresar y modificar la información de las Cuentas Bancarias.')
INSERT INTO funcion
	VALUES(15,3,3,'Editar Transacciones Bancarias','~/Aplicaciones/Bancos/Formulario/EditarTransaccionesBancarias.aspx','Permite Consultar, Ingresar y editar transacciones Bancarias.')

INSERT INTO funcion
	VALUES(16,4,1,'Editar Personas','~/Aplicaciones/General/Formulario/EditarPersonas.aspx','Permite Ingresar y modifirar la información de las Personas.')
INSERT INTO funcion
	VALUES(17,4,2,'Editar Disponibles del Sistema','~/Aplicaciones/General/Formulario/EditarDisponiblesDelSistema.aspx','Permite modificar los disponibles del sistema')
INSERT INTO funcion
	VALUES(64,4,3,'Editar Disponibles de Procurement','~/Aplicaciones/General/Formulario/EditarDisponiblesDeProcurement.aspx','Permite modificar la disponibilidad de los items')
INSERT INTO funcion
	VALUES(18,4,4,'Editar Variedades de Flor de Farm','~/Aplicaciones/General/Formulario/EditarVariedadesDeFlorDeFarm.aspx','Permite Agregar o Remover Variedades de Flor de una Finca.')
INSERT INTO funcion
	VALUES(22,4,5,'Edit Weblabels Users','~/Aplicaciones/General/Formulario/EditarUsuariosWeblabels.aspx','Allow to modify weblabels user data, like name, and printer.')
INSERT INTO funcion
	VALUES(34,4,6,'Free Form UPC','~/Aplicaciones/General/Formulario/EditarEtiquetaUPC.aspx','UPC')
INSERT INTO funcion
	VALUES(49,4,7,'General Reports','~/Aplicaciones/General/Reporte/ReportesGeneral.aspx','General Reports')
INSERT INTO funcion
	VALUES(56,4,8,'UPC Check Digit Calculation','~/Aplicaciones/General/Formulario/UPCCheckDigitCalculation.aspx','Calculates the UPC check digit')
INSERT INTO funcion
	VALUES(61,4,9,'Editar Temporadas','~/Aplicaciones/General/Formulario/EditarTemporadas.aspx','Editar Temporadas')
INSERT INTO funcion
	VALUES(70,4,10,'Editar Listas','~/Aplicaciones/General/Formulario/EditarListas.aspx','Editar Listas')
INSERT INTO funcion
	VALUES(74,4,11,'Editar Días No Laborales','~/Aplicaciones/General/Formulario/EditarDiasNoLaborales.aspx','Editar Días No Laborales')
INSERT INTO funcion
	VALUES(80,4,12,'Editar Minutos','~/Aplicaciones/General/Formulario/EditarMinutosGracia.aspx','Editar Minutos')
INSERT INTO funcion
	VALUES(88,4,13,'Editar Composición Grados','~/Aplicaciones/General/Formulario/EditarComposicionGrado.aspx','Permite editar la composición de los grados para un Tipo de Flor')
INSERT INTO funcion
	VALUES(94,4,14,'Editar Bloque','~/Aplicaciones/General/Formulario/EditarSupervisorBloque.aspx','Permite realizar la edición de características relacionadas al bloque.')
INSERT INTO funcion
	VALUES(100,4,15,'Customer List for Cobol User','~/Aplicaciones/General/Formulario/EditarCustomerListCobol.aspx','Customer List for Cobol User.')
INSERT INTO funcion
	VALUES(101,4,16,'Editar Hibridador','~/Aplicaciones/General/Formulario/EditarHibridador.aspx','Edita hibridador.')
INSERT INTO funcion
	VALUES(102,4,17,'Edit Sales Person','~/Aplicaciones/General/Formulario/EditarVendedores.aspx','Edit Sales Person.')
INSERT INTO funcion
	VALUES(114,4,18,'Editar Rendimiento','~/Aplicaciones/General/Formulario/EditarRendimientos.aspx','Edita Parametro de Rendimiento.')
INSERT INTO funcion
	VALUES(124,4,19,'Cargar Archivo Ubicación de Personal','~/Aplicaciones/General/Formulario/Cargar_Ubicacion_Personal.aspx','Carga el archivo de ubicación de personal.')
INSERT INTO funcion
	VALUES(125,4,20,'Credit Types','~/Aplicaciones/General/Formulario/Credit_Types.aspx','Carga tipos de credito.')

INSERT INTO funcion
	VALUES(23,5,1,'Editar Items de Sensorsoft','~/Aplicaciones/Sensorsoft/Formulario/EditarSensorsoftItems.aspx','Permite configurar cada sensor en las aplicaciones Web.')
INSERT INTO funcion
	VALUES(24,5,2,'Editar Estado de Cuartos Frios','~/Aplicaciones/Sensorsoft/Formulario/EditarEstadoCuartosFrios.aspx','Permite prender y apagar cuartos frios en el sistema.')

INSERT INTO funcion
	VALUES(26,7,1,'Edit Flora Stats Report','~/Aplicaciones/FloraStats/Formulario/EditarReporteFloraStats.aspx','Edit each Flora Stats item and the equivalent in the local system.')
INSERT INTO funcion
	VALUES(69,7,2,'Flora Stats Reports','~/Aplicaciones/FloraStats/Reporte/ReportesFloraStats.aspx','Flora Stats Reports')

INSERT INTO funcion
	VALUES(27,8,1,'Consultar Produccion Postcosecha (Entradas)','~/Aplicaciones/Produccion/Consulta/ConsultarInventarioPostcosecha.aspx','Permite ver la cantidad de flor en postcosecha de los ultimos 7 dias segun variedad de flor.')
INSERT INTO funcion
	VALUES(33,8,2,'Reporte Rendimiento de Corte','~/Aplicaciones/Produccion/Reporte/RendimientoDeCorte.aspx','Reporte que detalla los tallos por hora de cada trabajador.')
INSERT INTO funcion
	VALUES(55,8,3,'Reportes Produccion','~/Aplicaciones/Produccion/Reporte/ReportesProduccion.aspx','')
INSERT INTO funcion
	VALUES(82,8,5,'Solicitar Producción Rusia','~/Aplicaciones/Produccion/Formulario/ProduccionSolicitada.aspx','Permite realizar solicitudes de flor para Rusia en fechas definidas')
INSERT INTO funcion
	VALUES(91,8,6,'Trasladar Programación','~/Aplicaciones/Produccion/Formulario/TrasladarProgramacion.aspx','Permite realizar el traslado de la programación de Rusia.')
INSERT INTO funcion
	VALUES(92,8,7,'Copiar Programación','~/Aplicaciones/Produccion/Formulario/CopiarProgramacion.aspx','Permite realizar la copiar de la programación de Rusia.')
INSERT INTO funcion
	VALUES(87,8,8,'Eliminar Producción Solicitada Rusia','~/Aplicaciones/Produccion/Formulario/ProduccionEliminada.aspx','Permite eliminar solicitudes de flor para Rusia en fechas definidas')
INSERT INTO funcion
	VALUES(86,8,9,'Perdonar Producción Solicitada Rusia','~/Aplicaciones/Produccion/Formulario/PerdonarSaldosProduccion.aspx','Permite perdonar los saldos de las solicitudes de flor para Rusia')
INSERT INTO funcion
	VALUES(83,8,10,'Reporte Producción Solicitada Rusia','~/Aplicaciones/Produccion/Reporte/ReporteProduccionSolicitada.aspx','Permite realizar reporte de flor para Rusia.')
INSERT INTO funcion
	VALUES(84,8,11,'Parámetros Producción Clasificadora Rosematic','~/Aplicaciones/Produccion/Formulario/ProduccionClasificadora.aspx','Permite realizar la asignación del Tipo Flor y Grado para la clasificadora.')
INSERT INTO funcion
	VALUES(85,8,12,'Reportes Clasificadora','~/Aplicaciones/Produccion/Reporte/ReporteClasificadoraRosa.aspx','Permite realizar reportes de la clasificadora.')
INSERT INTO funcion
	VALUES(93,8,13,'Reporte Consolidados Clasificación','~/Aplicaciones/Produccion/Reporte/ReporteConsolidadosClasificadora.aspx','Permite realizar reportes consolidados de la clasificadora.')
INSERT INTO funcion
	VALUES(105,8,14,'Reporte Rendimiento Clasificación Rosa','~/Aplicaciones/Produccion/Consulta/Pantalla_Rendimiento_Clasificacion_Rosa.aspx','Genera el reporte del Rendimiento en la Clasificación de la Rosa.')
INSERT INTO funcion
	VALUES(113,8,15,'Reporte Rendimiento de Bonchado','~/Aplicaciones/Produccion/Reporte/RendimientoDeBonchado.aspx','Reporte para el Rendimiento de la Clasificación de Rosa')

INSERT INTO funcion
	VALUES(28,9,1,'Editar Cuentas Externas','~/Aplicaciones/GCuentasExternas/Formulario/EditarCuentasExternas.aspx','Permite activar y editar informacion de las cuentas de la extranet.')
INSERT INTO funcion
	VALUES(29,9,2,'Editar Clientes de Cuentas Externas','~/Aplicaciones/GCuentasExternas/Formulario/EditarClientesCuentaExterna.aspx','Permite adicionar y remover clientes de cuentas externas.')
INSERT INTO funcion
	VALUES(30,9,3,'Editar Farms de Cuentas Externas','~/Aplicaciones/GCuentasExternas/Formulario/EditarFarmsCuentaExterna.aspx','Permite adicionar y remover y editar impresoras de farms de cuentas externas.')

INSERT INTO funcion
	VALUES(31,10,1,'Load Prebooks from file.','~/Aplicaciones/Preventa/Formulario/CargarPreventasDesdeArchivo.aspx','Allow you to load prebooks from a *.csv file.')
INSERT INTO funcion
	VALUES(32,10,2,'Prebooks inventory by Farm.','~/Aplicaciones/Preventa/Formulario/InventarioPreventa.aspx','Manage supplies by farm.')
INSERT INTO funcion
	VALUES(58,10,3,'Edit prebooks inventory','~/Aplicaciones/Preventa/Formulario/EditarInventarioPreventa.aspx','Edit prebooks inventory')
INSERT INTO funcion
	VALUES(57,10,4,'Edit control inventory of items','~/Aplicaciones/Preventa/Formulario/EditarInventarioPreventa.aspx','')
INSERT INTO funcion
	VALUES(59,10,5,'Edit control inventory of items with pager','~/Aplicaciones/Preventa/Formulario/EditarInventarioPreventaPaging.aspx','')
INSERT INTO funcion
	VALUES(62,10,12,'Copy Inventory of Prebooks by Season','~/Aplicaciones/Preventa/Formulario/CopiarInventarioPreventas.aspx','Copy Inventory of Prebooks by Season')
INSERT INTO funcion
	VALUES(68,10,13,'Prebooks Reports','~/Aplicaciones/Preventa/Reporte/ReportesPreventa.aspx','Prebooks Reports')

INSERT INTO funcion
	VALUES(35,11,1,'Review changes to orders','~/Aplicaciones/FarmsFixedOrdersAndPrebooks/Formulario/CambiosOrdenPedido.aspx','Allow to reports changes to farm about fixed orders.')
INSERT INTO funcion
	VALUES(36,11,2,'Orders reports','~/Aplicaciones/FarmsFixedOrdersAndPrebooks/Reporte/ReportesOrdenPedido.aspx','Orders reports')
INSERT INTO funcion
	VALUES(37,11,2,'Edit action on ship day by City','~/Aplicaciones/FarmsFixedOrdersAndPrebooks/Formulario/EditarConsolidados.aspx','Allow you to set an action on shipping day by city.')
INSERT INTO funcion
	VALUES(51,11,4,'Edit Orders','~/Aplicaciones/FarmsFixedOrdersAndPrebooks/Formulario/EditarOrdenPedido.aspx','Edit Orders')

--INSERT INTO funcion
--	VALUES(38,11,2,'Review changes to Prebooks','~/Aplicaciones/FarmsFixedOrdersAndPrebooks/Formulario/CambiosPrebooks.aspx','Allow to reports changes to farm about prebooks.')
--

INSERT INTO funcion
	VALUES(44,12,1,'Consultar Orden Pedido','~/Aplicaciones/Bouquetera/Consulta/ConsultarOrdenPedido.aspx','Permite consultar las ordenes de pedido ingresadas en cobol')
INSERT INTO funcion
	VALUES(39,12,2,'Editar Ordenes','~/Aplicaciones/Bouquetera/Formulario/EditarOrdenes.aspx','Permite crear, modificar y eliminar ordenes para bouquetera.')
INSERT INTO funcion
	VALUES(40,12,2,'Confirmar Ordenes','~/Aplicaciones/Bouquetera/Formulario/ConfirmarOrdenes.aspx','Permite confirmar o rechazar ordenes de bouquetera.')

INSERT INTO funcion
	VALUES(41,13,1,'Editar Precios Oferta','~/Aplicaciones/Proveedores/Formulario/EditarPrecioOfertaPorProveedor.aspx','Permite ingresar el precio de compra por proveedor de cada variedad.')
INSERT INTO funcion
	VALUES(42,13,1,'Consultar Precios Oferta','~/Aplicaciones/Proveedores/Consulta/ConsultarPrecioOferta.aspx','Permite consultar el precio de compra por proveedor o tipo de flor.')

INSERT INTO funcion
	VALUES(48,14,1,'Configurar reportes de inventario','~/Aplicaciones/Inventario/Formulario/ConfigurarReportesInventario.aspx','Configurar Reportes')
INSERT INTO funcion
	VALUES(45,14,2,'Inventory Reports','~/Aplicaciones/Inventario/Reporte/ReportesInventario.aspx','Inventory Reports')

INSERT INTO funcion
	VALUES(46,15,1,'Fixed Orders and Prebooks Reports','~/Aplicaciones/FixedOrdersAndPrebooks/Reporte/ReportesFixedOrdersAndPrebooks.aspx','Fixed Orders And Prebooks Reports')
INSERT INTO funcion
	VALUES(123,15,2,'Not Sent to Farm','~/Aplicaciones/FixedOrdersAndPrebooks/Formulario/Not_Sent_to_Farm.aspx','Not Sent to Farm')
INSERT INTO funcion
	VALUES(124,15,3,'Orders Email Addresses','~/Aplicaciones/FixedOrdersAndPrebooks/Formulario/Orders_Email_Addresses.aspx','Orders Email Addresses')

INSERT INTO funcion
	VALUES(47,16,1,'Editar Lineas Descuento','~/Aplicaciones/Ventas/Formulario/EditarLineasDescuento.aspx','Editar Lineas Descuento')
INSERT INTO funcion
	VALUES(52,16,2,'Sales Reports','~/Aplicaciones/Ventas/Reporte/ReportesVentas.aspx','Sales Reports')
INSERT INTO funcion
	VALUES(71,16,3,'Gross Profit Reports','~/Aplicaciones/Ventas/Reporte/ReportesGrossProfit.aspx','Gross Profit Reports')
INSERT INTO funcion
	VALUES(67,16,4,'Natuflora Shipped Bunches','~/Aplicaciones/Ventas/Consulta/ConsultarRamosDespachados.aspx','Natuflora Shipped Bunches')
INSERT INTO funcion
	VALUES(89,16,5,'Current Salesperson Report','~/Aplicaciones/Ventas/Reporte/ReportesSalesPerson.aspx','Current Salesperson Report')
INSERT INTO funcion
	VALUES(90,16,6,'Client Report','~/Aplicaciones/Ventas/Reporte/ReportesClient.aspx','Client Report.')

INSERT INTO funcion
	VALUES(50,17,1,'Edit Weblabels','~/Aplicaciones/Weblabels/Formulario/EditarWeblabels.aspx','Edit Weblabels')
INSERT INTO funcion
	VALUES(53,17,2,'Edit no printed Weblabels','~/Aplicaciones/Weblabels/Formulario/EditarSinImprimir.aspx','Allow you to edit weblabels before print it.')

INSERT INTO funcion
	VALUES(54,18,1,'Session Monitor','~/Aplicaciones/Application/Formulario/MonitorSesion.aspx','Monitoring sessions')

INSERT INTO funcion
	VALUES(60,19,1,'Cargar ordenes desde archivo','~/Aplicaciones/Ordenes/Formulario/CargarOrdenesDesdeArchivo.aspx','Cargar ordenes desde archivo')
INSERT INTO funcion
	VALUES(63,19,2,'Editar Mapeos','~/Aplicaciones/Ordenes/Formulario/EditarMapeos.aspx','Editar Mapeos')
INSERT INTO funcion
	VALUES(115,19,3,'Load File','~/Aplicaciones/Ordenes/Formulario/CargarArchivoNFlowers.aspx','Load File Natural Flowers')


INSERT INTO funcion
	VALUES(65,20,1,'Editar Productos','~/Aplicaciones/PaginaWeb/Formulario/EditarProductos.aspx','Editar Productos')
INSERT INTO funcion
	VALUES(66,20,2,'Editar Novedades','~/Aplicaciones/PaginaWeb/Formulario/EditarNovedades.aspx','Editar Novedades')

INSERT INTO funcion
	VALUES(72,21,1,'Natuflora not S.O. by flower','~/Aplicaciones/Distribuidora/Reporte/ReportesporFlor.aspx','Natuflora not S.O. by flower - Distribuidora')
INSERT INTO funcion
	VALUES(73,21,2,'Natuflora net Sales by date','~/Aplicaciones/Distribuidora/Reporte/ReporteporVentaNeta.aspx','Natuflora net Sales by date - Distribuidora')

INSERT INTO funcion
	VALUES(75,22,1,'Horario de Salida General','~/Aplicaciones/AutorizacionHorasExtras/Formulario/HorarioSalidaGeneral.aspx','Horario de Salida General')
INSERT INTO funcion
	VALUES(76,22,2,'Procesamiento Información de Salida','~/Aplicaciones/AutorizacionHorasExtras/Formulario/ProcesoAutorizacionHorasExtras.aspx','Procesamiento Información de Salida')
INSERT INTO funcion
	VALUES(77,22,3,'Editar Hora de Salida','~/Aplicaciones/AutorizacionHorasExtras/Formulario/EditarHoraSalida.aspx','Editar Hora de Salida')
INSERT INTO funcion
	VALUES(78,22,4,'Reportes','~/Aplicaciones/AutorizacionHorasExtras/Formulario/Reportes.aspx','Reportes')
INSERT INTO funcion
	VALUES(79,22,5,'Autorización Horas Específicas por Empleado','~/Aplicaciones/AutorizacionHorasExtras/Formulario/HoraEspecificaporEmpleado.aspx','Autorización Horas Especificas por Empleado')

INSERT INTO funcion
	VALUES(95,23,1,'Crear Cama','~/Aplicaciones/Siembras/Formulario/CreacionCamasBloque.aspx','Permite crear las camas por bloque.')
INSERT INTO funcion
	VALUES(96,23,2,'Sembrar Cama','~/Aplicaciones/Siembras/Formulario/SembrarCama.aspx','Permite asignar las siembras por cama.')
INSERT INTO funcion
	VALUES(97,23,3,'Erradicar Cama','~/Aplicaciones/Siembras/Formulario/ErradicarCama.aspx','Permite erradicar las siembras por cama.')
INSERT INTO funcion
	VALUES(98,23,4,'Destruir Cama','~/Aplicaciones/Siembras/Formulario/DestruirCama.aspx','Permite destruir las camas.')
INSERT INTO funcion
	VALUES(99,23,5,'Reportes de Siembra','~/Aplicaciones/Siembras/Reporte/ReportesPlanoCamaBloque.aspx','Permite generar reportes de siembra.')
INSERT INTO funcion
	VALUES(103,23,6,'Asignar Operario','~/Aplicaciones/Siembras/Formulario/AsignarOperario.aspx','Permite asignar los operarios a las camas.')
INSERT INTO funcion
	VALUES(104,23,7,'Reportes Dinámicos','~/Aplicaciones/Siembras/Reporte/Reportes_Dinamicos.aspx','Realiza los reportes dinámicos.')
INSERT INTO funcion
	VALUES(106,23,8,'Programar Labor','~/Aplicaciones/Siembras/Formulario/ProgramarLabor.aspx','Programa las labores del personal.')

INSERT INTO funcion
	VALUES(81,24,1,'Ingresar Estimados','~/Aplicaciones/Estimados/Formulario/EditarCalculoEstimados.aspx','Permite ingresar los estimados por bloque, variedad y fecha')
INSERT INTO funcion
	VALUES(107,24,2,'Ingresar Conteo','~/Aplicaciones/Estimados/Formulario/Ingresar_Conteo.aspx','Permite ingresar conteo de flor')

INSERT INTO funcion
	VALUES(108,25,1,'Pantalla Uno','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Uno.aspx','Reporte para Pantalla_TV Uno')
INSERT INTO funcion
	VALUES(109,25,2,'Pantalla Dos','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Dos.aspx','Reporte para Pantalla_TV Dos')
INSERT INTO funcion
	VALUES(110,25,3,'Pantalla Tres','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Tres.aspx','Reporte para Pantalla_TV Tres')
INSERT INTO funcion
	VALUES(111,25,4,'Pantalla Cuatro','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Cuatro.aspx','Reporte para Pantalla_TV Cuatro')
INSERT INTO funcion
	VALUES(112,25,7,'Pantalla Siete','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Siete.aspx','Reporte para Pantalla_TV Siete')
INSERT INTO funcion
	VALUES(116,25,8,'Pantalla Ocho','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Ocho.aspx','Reporte Rendimiento Clasificación Rosa Rendimiento Ultima Hora')
INSERT INTO funcion
	VALUES(117,25,9,'Pantalla Nueve','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Nueve.aspx','Reporte Rendimiento Clasificación Rosa Rendimiento Diario Superior')
INSERT INTO funcion
	VALUES(118,25,10,'Pantalla Diez','~/Aplicaciones/Pantalla_TV/Pantallas/Pantalla_Diez.aspx','Reporte Rendimiento Clasificación Rosa Rendimiento Diario Inferior')

INSERT INTO funcion
	VALUES(119,26,1,'Grabar','~/Aplicaciones/MaxiPuntos/Formulario/Grabar_MaxiPuntos.aspx','Aprobación/Grabación de MaxiPuntos')
INSERT INTO funcion
	VALUES(120,26,2,'Reportes','~/Aplicaciones/MaxiPuntos/Reportes/Reportes_Maxipuntos.aspx','Generación de Reportes para MaxiPuntos')

INSERT INTO funcion
	VALUES(121,27,1,'Solicitud de Confirmación','~/Aplicaciones/Aprobar_Ordenes/Formulario/Confirma_Solicitud.aspx','Solicitud de confirmación.')
INSERT INTO funcion
	VALUES(122,27,2,'Confirmación','~/Aplicaciones/Aprobar_Ordenes/Formulario/Confirmación.aspx','Confirma las ordenes.')

INSERT INTO funcion
values(103,4,9,'Edit Credit Types Description','~/Aplicaciones/General/Formulario/Credit_Types.aspx','Allow modify credit type descriptions')

INSERT INTO funcion
values(139,23,7,'Generar Etiquetas','~/Aplicaciones/Siembras/Formulario/GenerarEtiquetasSiembra/GenerarEtiquetasSiembra.aspx','Permite imprimir las etiquetas de siembra de Flores Luna Nueva')

insert into funcion (id_funcion, id_ap, numero_funcion, nombre_funcion, url_funcion, descripcion)
values(158,	12,	3,	'Ingresar cotizaciones de Bouquets', '~/Aplicaciones/Bouquetera/Formulario/CotizarBouquet.aspx', 'Permite ingresar las cotizaciones de flores para bouquets')

select * from aplicacion
select * from funcion
where id_ap = 23
--El último indice grabado para continuar adicionando fue el 125 (se debe sumar uno para el siguinte no olvide actualizar este comentario)

INSERT INTO perfil
	VALUES(1,'Administrador de Gestión de Cuentas','')

INSERT INTO permiso_perfil
	VALUES(1,1)
INSERT INTO permiso_perfil
	VALUES(1,2)
INSERT INTO permiso_perfil
	VALUES(1,3)
INSERT INTO permiso_perfil
	VALUES(1,4)
INSERT INTO permiso_perfil
	VALUES(1,5)
INSERT INTO permiso_perfil
	VALUES(1,6)
INSERT INTO permiso_perfil
	VALUES(1,7)
INSERT INTO permiso_perfil
	VALUES(1,8)
INSERT INTO permiso_perfil
	VALUES(1,9)
INSERT INTO permiso_perfil
	VALUES(1,19)
INSERT INTO permiso_perfil
	VALUES(1,20)
INSERT INTO permiso_perfil
	VALUES(1,21)

INSERT INTO cuenta_interna_perfil
	VALUES ('1',1)
	
EXECUTE gc_log_cuenta_interna '1','Creacion de la base de datos BD_Cuentas'


