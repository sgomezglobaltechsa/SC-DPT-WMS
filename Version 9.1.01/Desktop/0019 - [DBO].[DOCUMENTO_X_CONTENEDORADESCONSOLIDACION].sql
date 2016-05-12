CREATE TABLE [DBO].[DOCUMENTO_X_CONTENEDORADESCONSOLIDACION](
	[ID_DESCONSOLIDACION] [INT] IDENTITY(1,1) NOT NULL,
	[DOCUMENTO_ID] [VARCHAR](30) NULL,
	[NROUCDESCONSOLIDACION] [VARCHAR](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_DESCONSOLIDACION] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
