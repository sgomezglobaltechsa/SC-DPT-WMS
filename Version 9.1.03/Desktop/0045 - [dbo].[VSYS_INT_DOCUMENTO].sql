IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VSYS_INT_DOCUMENTO]'))
DROP VIEW [dbo].[VSYS_INT_DOCUMENTO]
GO

CREATE  VIEW [dbo].[VSYS_INT_DOCUMENTO]
AS
SELECT * FROM SYS_INT_DOCUMENTO
UNION
SELECT * FROM SYS_INT_DOCUMENTO_HISTORICO

GO


