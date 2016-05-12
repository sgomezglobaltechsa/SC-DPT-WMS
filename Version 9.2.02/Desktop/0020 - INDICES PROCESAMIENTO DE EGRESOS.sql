CREATE NONCLUSTERED INDEX [_dta_index_SYS_INT_DET_DOCUMENTO_12_1460916276__K3_K1_K31_K2_K4_K11_K15_K24_5] ON [dbo].[SYS_INT_DET_DOCUMENTO] 
(
	[CLIENTE_ID] ASC,
	[DOC_EXT] ASC,
	[ESTADO_GT] ASC,
	[NRO_LINEA] ASC,
	[PRODUCTO_ID] ASC,
	[NRO_LOTE] ASC,
	[NRO_PARTIDA] ASC,
	[PROP3] ASC
)
INCLUDE ( [CANTIDAD_SOLICITADA]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_PRODUCTO_12_1701581100__K46_K1_K2_6_12] ON [dbo].[PRODUCTO] 
(
	[GRUPO_PRODUCTO] ASC,
	[CLIENTE_ID] ASC,
	[PRODUCTO_ID] ASC
)
INCLUDE ( [DESCRIPCION],
[UNIDAD_ID]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_PICKING_12_847446193__K1_7] ON [dbo].[PICKING] 
(
	[PICKING_ID] ASC
)
INCLUDE ( [TIPO_CAJA]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_SYS_INT_DOCUMENTO_12_1508916447__K25_K2_K1_K31_K18_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_19_20_21_22_30_32_33_34_35] ON [dbo].[SYS_INT_DOCUMENTO] 
(
	[ESTADO_GT] ASC,
	[TIPO_DOCUMENTO_ID] ASC,
	[CLIENTE_ID] ASC,
	[TRANSPORTE_ID] ASC,
	[CODIGO_VIAJE] ASC
)
INCLUDE ( [CPTE_PREFIJO],
[CPTE_NUMERO],
[FECHA_CPTE],
[FECHA_SOLICITUD_CPTE],
[AGENTE_ID],
[PESO_TOTAL],
[UNIDAD_PESO],
[VOLUMEN_TOTAL],
[UNIDAD_VOLUMEN],
[TOTAL_BULTOS],
[ORDEN_DE_COMPRA],
[OBSERVACIONES],
[NRO_REMITO],
[NRO_DESPACHO_IMPORTACION],
[DOC_EXT],
[INFO_ADICIONAL_1],
[INFO_ADICIONAL_2],
[INFO_ADICIONAL_3],
[TIPO_COMPROBANTE],
[CLASE_PEDIDO],
[IMPORTE_FLETE],
[INFO_ADICIONAL_4],
[INFO_ADICIONAL_5],
[INFO_ADICIONAL_6]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_SYS_INT_DOCUMENTO_12_1508916447__K17_K1_K2_K18_K7_K25] ON [dbo].[SYS_INT_DOCUMENTO] 
(
	[DOC_EXT] ASC,
	[CLIENTE_ID] ASC,
	[TIPO_DOCUMENTO_ID] ASC,
	[CODIGO_VIAJE] ASC,
	[AGENTE_ID] ASC,
	[ESTADO_GT] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_SYS_INT_DOCUMENTO_12_1508916447__K17_K18_1] ON [dbo].[SYS_INT_DOCUMENTO] 
(
	[DOC_EXT] ASC,
	[CODIGO_VIAJE] ASC
)
INCLUDE ( [CLIENTE_ID]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_SYS_INT_DOCUMENTO_12_1508916447__K25_K18] ON [dbo].[SYS_INT_DOCUMENTO] 
(
	[ESTADO_GT] ASC,
	[CODIGO_VIAJE] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_SUCURSAL_12_881438214__K1_2_3_4_5_7_8_9] ON [dbo].[SUCURSAL] 
(
	[CLIENTE_ID] ASC
)
INCLUDE ( [SUCURSAL_ID],
[NOMBRE],
[CALLE],
[NUMERO],
[LOCALIDAD],
[PROVINCIA_ID],
[PAIS_ID]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_DOCUMENTO_12_1108198998__K2_K29_K4_K24_K1] ON [dbo].[DOCUMENTO] 
(
	[CLIENTE_ID] ASC,
	[NRO_DESPACHO_IMPORTACION] ASC,
	[TIPO_OPERACION_ID] ASC,
	[NRO_REMITO] ASC,
	[DOCUMENTO_ID] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_PRIORIDAD_VIAJE_12_1485964370__K1_K2] ON [dbo].[PRIORIDAD_VIAJE] 
(
	[VIAJE_ID] ASC,
	[PRIORIDAD] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_docxviajesprocesados_12_1449108253__K2_K1_K3_K5_K6_K4] ON [dbo].[docxviajesprocesados] 
(
	[documento_id] ASC,
	[viaje_id] ASC,
	[status] ASC,
	[usuario] ASC,
	[terminal] ASC,
	[fecha] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go