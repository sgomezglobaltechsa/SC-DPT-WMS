
CREATE CLUSTERED INDEX [_dta_index_consumo_locator_egr_c_10_846626059__K11_K2] ON [dbo].[consumo_locator_egr]
(
	[procesado] ASC,
	[documento_id] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

