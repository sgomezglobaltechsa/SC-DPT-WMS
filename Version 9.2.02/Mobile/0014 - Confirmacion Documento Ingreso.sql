CREATE NONCLUSTERED INDEX [_dta_index_DET_DOCUMENTO_7_2004202190__K4_K3_K1_K2_K9_5] ON [dbo].[DET_DOCUMENTO] 
(
	[PRODUCTO_ID] ASC,
	[CLIENTE_ID] ASC,
	[DOCUMENTO_ID] ASC,
	[NRO_LINEA] ASC,
	[CAT_LOG_ID] ASC
)
INCLUDE ( [CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_DET_DOCUMENTO_7_2004202190__K3_K4_K1_K2_5] ON [dbo].[DET_DOCUMENTO] 
(
	[CLIENTE_ID] ASC,
	[PRODUCTO_ID] ASC,
	[DOCUMENTO_ID] ASC,
	[NRO_LINEA] ASC
)
INCLUDE ( [CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_DET_DOCUMENTO_7_2004202190__K3_K4_1_2_5] ON [dbo].[DET_DOCUMENTO] 
(
	[CLIENTE_ID] ASC,
	[PRODUCTO_ID] ASC
)
INCLUDE ( [DOCUMENTO_ID],
[NRO_LINEA],
[CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_DET_DOCUMENTO_7_2004202190__K4_K3_K1_K2] ON [dbo].[DET_DOCUMENTO] 
(
	[PRODUCTO_ID] ASC,
	[CLIENTE_ID] ASC,
	[DOCUMENTO_ID] ASC,
	[NRO_LINEA] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_DET_DOCUMENTO_7_2004202190__K4_K3_K2_K1] ON [dbo].[DET_DOCUMENTO] 
(
	[PRODUCTO_ID] ASC,
	[CLIENTE_ID] ASC,
	[NRO_LINEA] ASC,
	[DOCUMENTO_ID] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_2004202190_3_9] ON [dbo].[DET_DOCUMENTO]([CLIENTE_ID], [CAT_LOG_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_1_4] ON [dbo].[DET_DOCUMENTO]([DOCUMENTO_ID], [PRODUCTO_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_9_4] ON [dbo].[DET_DOCUMENTO]([CAT_LOG_ID], [PRODUCTO_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_3_2] ON [dbo].[DET_DOCUMENTO]([CLIENTE_ID], [NRO_LINEA])
go

CREATE STATISTICS [_dta_stat_2004202190_1_9_3] ON [dbo].[DET_DOCUMENTO]([DOCUMENTO_ID], [CAT_LOG_ID], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_2_4_3] ON [dbo].[DET_DOCUMENTO]([NRO_LINEA], [PRODUCTO_ID], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_1_2_3] ON [dbo].[DET_DOCUMENTO]([DOCUMENTO_ID], [NRO_LINEA], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_1_2_4] ON [dbo].[DET_DOCUMENTO]([DOCUMENTO_ID], [NRO_LINEA], [PRODUCTO_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_4_3_9] ON [dbo].[DET_DOCUMENTO]([PRODUCTO_ID], [CLIENTE_ID], [CAT_LOG_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_1_9_2_3] ON [dbo].[DET_DOCUMENTO]([DOCUMENTO_ID], [CAT_LOG_ID], [NRO_LINEA], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_2004202190_3_4_1_9_2] ON [dbo].[DET_DOCUMENTO]([CLIENTE_ID], [PRODUCTO_ID], [DOCUMENTO_ID], [CAT_LOG_ID], [NRO_LINEA])
go

CREATE STATISTICS [_dta_stat_2004202190_1_3_4_6_8_9_10_12_13_14_15_16_17_18_19_20] ON [dbo].[DET_DOCUMENTO]([DOCUMENTO_ID], [CLIENTE_ID], [PRODUCTO_ID], [NRO_SERIE], [EST_MERC_ID], [CAT_LOG_ID], [NRO_BULTO], [NRO_LOTE], [FECHA_VENCIMIENTO], [NRO_DESPACHO], [NRO_PARTIDA], [UNIDAD_ID], [PESO], [UNIDAD_PESO], [VOLUMEN], [UNIDAD_VOLUMEN])
go

CREATE STATISTICS [_dta_stat_2004202190_3_4_6_8_9_10_12_13_14_15_16_17_18_19_20_21] ON [dbo].[DET_DOCUMENTO]([CLIENTE_ID], [PRODUCTO_ID], [NRO_SERIE], [EST_MERC_ID], [CAT_LOG_ID], [NRO_BULTO], [NRO_LOTE], [FECHA_VENCIMIENTO], [NRO_DESPACHO], [NRO_PARTIDA], [UNIDAD_ID], [PESO], [UNIDAD_PESO], [VOLUMEN], [UNIDAD_VOLUMEN], [BUSC_INDIVIDUAL])
go

CREATE NONCLUSTERED INDEX [_dta_index_RL_DET_DOC_TRANS_POSICION_7_457768688__K19_K20_K12_K13_K2_K3_6] ON [dbo].[RL_DET_DOC_TRANS_POSICION] 
(
	[CLIENTE_ID] ASC,
	[CAT_LOG_ID] ASC,
	[DOCUMENTO_ID] ASC,
	[NRO_LINEA] ASC,
	[DOC_TRANS_ID] ASC,
	[NRO_LINEA_TRANS] ASC
)
INCLUDE ( [CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_RL_DET_DOC_TRANS_POSICION_7_457768688__K19_K20_K15_K16_K22_6] ON [dbo].[RL_DET_DOC_TRANS_POSICION] 
(
	[CLIENTE_ID] ASC,
	[CAT_LOG_ID] ASC,
	[DOC_TRANS_ID_EGR] ASC,
	[NRO_LINEA_TRANS_EGR] ASC,
	[EST_MERC_ID] ASC
)
INCLUDE ( [CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_RL_DET_DOC_TRANS_POSICION_7_457768688__K15_K16_K19_K20_K22_6] ON [dbo].[RL_DET_DOC_TRANS_POSICION] 
(
	[DOC_TRANS_ID_EGR] ASC,
	[NRO_LINEA_TRANS_EGR] ASC,
	[CLIENTE_ID] ASC,
	[CAT_LOG_ID] ASC,
	[EST_MERC_ID] ASC
)
INCLUDE ( [CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_RL_DET_DOC_TRANS_POSICION_7_457768688__K12_K13_K19_K20_6] ON [dbo].[RL_DET_DOC_TRANS_POSICION] 
(
	[DOCUMENTO_ID] ASC,
	[NRO_LINEA] ASC,
	[CLIENTE_ID] ASC,
	[CAT_LOG_ID] ASC
)
INCLUDE ( [CANTIDAD]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_RL_DET_DOC_TRANS_POSICION_7_457768688__K20_K19_K15_K16] ON [dbo].[RL_DET_DOC_TRANS_POSICION] 
(
	[CAT_LOG_ID] ASC,
	[CLIENTE_ID] ASC,
	[DOC_TRANS_ID_EGR] ASC,
	[NRO_LINEA_TRANS_EGR] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_RL_DET_DOC_TRANS_POSICION_7_457768688__K15_K16_K19_K20] ON [dbo].[RL_DET_DOC_TRANS_POSICION] 
(
	[DOC_TRANS_ID_EGR] ASC,
	[NRO_LINEA_TRANS_EGR] ASC,
	[CLIENTE_ID] ASC,
	[CAT_LOG_ID] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_457768688_6_2_3] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([CANTIDAD], [DOC_TRANS_ID], [NRO_LINEA_TRANS])
go

CREATE STATISTICS [_dta_stat_457768688_15_16_20] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([DOC_TRANS_ID_EGR], [NRO_LINEA_TRANS_EGR], [CAT_LOG_ID])
go

CREATE STATISTICS [_dta_stat_457768688_2_3_19] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([DOC_TRANS_ID], [NRO_LINEA_TRANS], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_457768688_19_20_1_3] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([CLIENTE_ID], [CAT_LOG_ID], [RL_ID], [NRO_LINEA_TRANS])
go

CREATE STATISTICS [_dta_stat_457768688_19_15_16_20] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([CLIENTE_ID], [DOC_TRANS_ID_EGR], [NRO_LINEA_TRANS_EGR], [CAT_LOG_ID])
go

CREATE STATISTICS [_dta_stat_457768688_19_20_2_3] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([CLIENTE_ID], [CAT_LOG_ID], [DOC_TRANS_ID], [NRO_LINEA_TRANS])
go

CREATE STATISTICS [_dta_stat_457768688_3_2_1_19_20] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([NRO_LINEA_TRANS], [DOC_TRANS_ID], [RL_ID], [CLIENTE_ID], [CAT_LOG_ID])
go

CREATE STATISTICS [_dta_stat_457768688_11_19_20_21_12] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([NAVE_ACTUAL], [CLIENTE_ID], [CAT_LOG_ID], [CAT_LOG_ID_FINAL], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_457768688_2_3_12_13_19] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([DOC_TRANS_ID], [NRO_LINEA_TRANS], [DOCUMENTO_ID], [NRO_LINEA], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_457768688_12_13_19_20_3_2] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([DOCUMENTO_ID], [NRO_LINEA], [CLIENTE_ID], [CAT_LOG_ID], [NRO_LINEA_TRANS], [DOC_TRANS_ID])
go

CREATE STATISTICS [_dta_stat_457768688_1_3_2_12_13_19] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([RL_ID], [NRO_LINEA_TRANS], [DOC_TRANS_ID], [DOCUMENTO_ID], [NRO_LINEA], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_457768688_19_20_21_12_13_11] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([CLIENTE_ID], [CAT_LOG_ID], [CAT_LOG_ID_FINAL], [DOCUMENTO_ID], [NRO_LINEA], [NAVE_ACTUAL])
go

CREATE STATISTICS [_dta_stat_457768688_1_19_20_12_13_3_2] ON [dbo].[RL_DET_DOC_TRANS_POSICION]([RL_ID], [CLIENTE_ID], [CAT_LOG_ID], [DOCUMENTO_ID], [NRO_LINEA], [NRO_LINEA_TRANS], [DOC_TRANS_ID])
go

CREATE NONCLUSTERED INDEX [_dta_index_DOCUMENTO_7_980198542__K1_K23] ON [dbo].[DOCUMENTO] 
(
	[DOCUMENTO_ID] ASC,
	[STATUS] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_DOCUMENTO_7_980198542__K23] ON [dbo].[DOCUMENTO] 
(
	[STATUS] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_980198542_23_1] ON [dbo].[DOCUMENTO]([STATUS], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_980198542_1_2] ON [dbo].[DOCUMENTO]([DOCUMENTO_ID], [CLIENTE_ID])
go

CREATE STATISTICS [_dta_stat_980198542_1_4] ON [dbo].[DOCUMENTO]([DOCUMENTO_ID], [TIPO_OPERACION_ID])
go

CREATE STATISTICS [_dta_stat_980198542_4_3_1] ON [dbo].[DOCUMENTO]([TIPO_OPERACION_ID], [TIPO_COMPROBANTE_ID], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_1351675863_22_1_2] ON [dbo].[PRODUCTO]([NO_AGRUPA_ITEMS], [CLIENTE_ID], [PRODUCTO_ID])
go

CREATE STATISTICS [_dta_stat_1351675863_33_1_2] ON [dbo].[PRODUCTO]([INGRESO], [CLIENTE_ID], [PRODUCTO_ID])
go

CREATE STATISTICS [_dta_stat_1312723729_12_13_5_10] ON [dbo].[HISTORICO_PRODUCTO]([CLIENTE_ID], [PRODUCTO_ID], [TIPO_OPERACION_ID], [USUARIO_ID])
go

CREATE STATISTICS [_dta_stat_1003150619_1_4] ON [dbo].[DOCUMENTO_TRANSACCION]([DOC_TRANS_ID], [TRANSACCION_ID])
go

CREATE STATISTICS [_dta_stat_1003150619_6_1] ON [dbo].[DOCUMENTO_TRANSACCION]([STATUS], [DOC_TRANS_ID])
go

CREATE STATISTICS [_dta_stat_1003150619_13_1_4] ON [dbo].[DOCUMENTO_TRANSACCION]([TR_ACTIVO], [DOC_TRANS_ID], [TRANSACCION_ID])
go

CREATE STATISTICS [_dta_stat_1003150619_13_1_6] ON [dbo].[DOCUMENTO_TRANSACCION]([TR_ACTIVO], [DOC_TRANS_ID], [STATUS])
go

CREATE STATISTICS [_dta_stat_1003150619_5_11_4_14] ON [dbo].[DOCUMENTO_TRANSACCION]([ESTACION_ACTUAL], [TIPO_OPERACION_ID], [TRANSACCION_ID], [USUARIO_ID])
go

CREATE STATISTICS [_dta_stat_1088722931_10_11_12_3_9] ON [dbo].[HISTORICO_POSICION]([NAVE_ID], [CLIENTE_ID], [PRODUCTO_ID], [TIPO_OPERACION_ID], [USUARIO_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_4_1_2] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([NRO_LINEA_DOC], [DOC_TRANS_ID], [NRO_LINEA_TRANS])
go

CREATE STATISTICS [_dta_stat_1728725211_1_7_3] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([DOC_TRANS_ID], [CLIENTE_ID], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_7_3_4_1] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([CLIENTE_ID], [DOCUMENTO_ID], [NRO_LINEA_DOC], [DOC_TRANS_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_7_1_2_3] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([CLIENTE_ID], [DOC_TRANS_ID], [NRO_LINEA_TRANS], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_1_7_8_3] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([DOC_TRANS_ID], [CLIENTE_ID], [CAT_LOG_ID], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_8_1_2_3] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([CAT_LOG_ID], [DOC_TRANS_ID], [NRO_LINEA_TRANS], [DOCUMENTO_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_1_2_3_4_8] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([DOC_TRANS_ID], [NRO_LINEA_TRANS], [DOCUMENTO_ID], [NRO_LINEA_DOC], [CAT_LOG_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_7_8_3_4_1] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([CLIENTE_ID], [CAT_LOG_ID], [DOCUMENTO_ID], [NRO_LINEA_DOC], [DOC_TRANS_ID])
go

CREATE STATISTICS [_dta_stat_1728725211_3_4_1_2_7_8] ON [dbo].[DET_DOCUMENTO_TRANSACCION]([DOCUMENTO_ID], [NRO_LINEA_DOC], [DOC_TRANS_ID], [NRO_LINEA_TRANS], [CLIENTE_ID], [CAT_LOG_ID])
go

