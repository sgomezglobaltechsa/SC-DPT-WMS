
GO

/*
Script created by Quest Change Director for SQL Server at 13/12/2012 12:44 p.m.
Please back up your database before running this script
*/

PRINT N'Synchronizing objects from V9 to CORAL'
GO

IF @@TRANCOUNT > 0 COMMIT TRANSACTION
GO

SET NUMERIC_ROUNDABORT OFF
SET ANSI_PADDING, ANSI_NULLS, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO

CREATE TABLE #tmpErrors (Error int)
GO

SET XACT_ABORT OFF
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO

BEGIN TRANSACTION
GO

ALTER TABLE [dbo].[DET_INVENTARIO]
DROP CONSTRAINT [fk_det_inventario_inventario]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_INVENTARIO_USUARIO]
DROP CONSTRAINT [fk_RL_INVENTARIO]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SeriePicking]
DROP CONSTRAINT [FK_SeriePicking_PICKING]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_DET_DOCUMENTO]
DROP CONSTRAINT [FK_PRODUCTO_SIDD]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_DET_DOCUMENTO]
DROP CONSTRAINT [FK_PRODUCTO_SIDD_MAXI]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_KIT]
DROP CONSTRAINT [fk_det_kit_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_PARTE_PRODUCCION]
DROP CONSTRAINT [FK_PRODUCTO_FINAL_SIPP]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_PARTE_PRODUCCION]
DROP CONSTRAINT [FK_PRODUCTO_INSUMO_SIPP]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[APF_BULTOS_POR_PALLET]
DROP CONSTRAINT [FK_PRODUCTO_APF]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_UNIDAD_CONTENEDORA]
DROP CONSTRAINT [FK_RLPUC_PRODUCTO]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_CONTENEDOR]
DROP CONSTRAINT [fk_producto_contenedor]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_CRITERIO_UBIC_PRODUCTO]
DROP CONSTRAINT [fk_rl_crit_ubic_prod_prod]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_DOCUMENTO]
DROP CONSTRAINT [FK_DET_DOCUMENTO_PRODUCTO]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_CATLOG]
DROP CONSTRAINT [fk_rl_prod_catlog#producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_TRATAMIENTO]
DROP CONSTRAINT [fk_rl_prod_trat#producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_CODIGOS]
DROP CONSTRAINT [FK_PRODUCTO_CODIGOS]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[PICKING]
DROP CONSTRAINT [FK_PRODUCTO#PICKING]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO_AJU]
DROP CONSTRAINT [fk_DET_INVENTARIO_AJU_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[HISTORICO_POSICION]
DROP CONSTRAINT [fk_hist_pos_prod]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_PICKING]
DROP CONSTRAINT [fk_rl_producto_picking]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_NAVEPOS_PICKING]
DROP CONSTRAINT [fk_rl_prod_navepos_picking]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[HISTORICO_PRODUCTO]
DROP CONSTRAINT [fk_hist_prod_prod]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO]
DROP CONSTRAINT [fk_det_inventario_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_CRITERIO_PRODUCTO]
DROP CONSTRAINT [fk_rl_criterio_prod_prod]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_CONTEO]
DROP CONSTRAINT [fk_det_cont_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[CRITERIO_ASIG_PICKING]
DROP CONSTRAINT [FK_PROD_CRITERIO_ASIG_PICKING]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[MANDATORIO_PRODUCTO]
DROP CONSTRAINT [fk_mandat_prod_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_CRITERIO_LOCATOR]
DROP CONSTRAINT [fk_locator_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_POSICION_PERMITIDA]
DROP CONSTRAINT [fk_rlppp_producto]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[HISTORICO_SALDO_PRODUCTO]
DROP CONSTRAINT [FK_HSP_PROD]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_1_11_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_1_2_3_40_24]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_1_2_3_5_40]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_1_24_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_1_4_3_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_1_42_5]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_11_10_17_16_25_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_11_10_4_5_14_15_17_16]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_11_17_16_25_15_14_10_4_5_6_8_12_7_13_40]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_11_17_16_25_15_14_4_5]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_11_6_5_8]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_14_11_10_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_14_15_17_16_25]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_14_2_24]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_15_11_10]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_15_2_24_3]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_16_11_10_14_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_17_11_10_14_15_16]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_17_15_1]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_17_15_14_24_3]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_2_17_15_14]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_2_25]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_2_3_24_17_14_15_42]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_2_3_43]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_2_40_24_1]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_1_2_4]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_17_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_2_43_3_42]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_3_2_1_4_6_25]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_3_2_14_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_3_43]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_24_5_1_40_2_3]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_25_11_10_14_15_17]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_25_4_3_2_6]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_25_42]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_25_6_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_3_17_15_14]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_3_17_24]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_3_24_1_4]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_3_40_24_1_5]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_4_3_2_6_1]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_4_5_11_17_16_25_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_4_6_1]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_4_6_25]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_40_24_1]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_42_17_15_14_24]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_42_24_2_3_14_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_42_43_24]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_42_5]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_43_24]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_5_1_40]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_6_1_11]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_6_1_24_25_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_6_1_25_4_3_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_6_2_3]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_6_2_3_1_24_25]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PICKING].[_dta_stat_1501964427_6_51_25]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PRODUCTO].[_dta_stat_1701581100_1_2_19_15_44]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PRODUCTO].[_dta_stat_1701581100_19_15_44_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PRODUCTO].[_dta_stat_1701581100_2_19_15]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

DROP STATISTICS [dbo].[PRODUCTO].[_dta_stat_1701581100_48_1_2]
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[CONFIGURACION_CONTENEDORAS]
 ADD [NRO_LOTE] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_PARTIDA] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO]
 ADD [NRO_LOTE] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_PARTIDA] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO_AJU]
 ADD [PROCESADO2] varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO_AJU]
ALTER COLUMN [OBS_AJU] varchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[INGRESO_OC]
 ADD [NRO_LOTE] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_PARTIDA] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOC_EXT] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[INVENTARIO]
 ADD [AJU_REALIZADO_2] varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FECHA_AJU_2] datetime NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[PICKING]
 ADD [NRO_LOTE] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_PARTIDA] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_SERIE] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[PRODUCTO]
 ADD [ingLoteProveedor] varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ingPartida] varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[TMP_EMPAQUE_CONTENEDORA]
 ADD [NRO_LOTE] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_PARTIDA] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NRO_SERIE] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO]
 ADD CONSTRAINT [fk_det_inventario_inventario] FOREIGN KEY ([INVENTARIO_ID]) REFERENCES [dbo].[INVENTARIO] ([INVENTARIO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_INVENTARIO_USUARIO]
 ADD CONSTRAINT [fk_RL_INVENTARIO] FOREIGN KEY ([INVENTARIO_ID]) REFERENCES [dbo].[INVENTARIO] ([INVENTARIO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SeriePicking]
 ADD CONSTRAINT [FK_SeriePicking_PICKING] FOREIGN KEY ([PICKING_ID]) REFERENCES [dbo].[PICKING] ([PICKING_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_DET_DOCUMENTO]
 ADD CONSTRAINT [FK_PRODUCTO_SIDD] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_DET_DOCUMENTO]
 ADD CONSTRAINT [FK_PRODUCTO_SIDD_MAXI] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_KIT]
 ADD CONSTRAINT [fk_det_kit_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_PARTE_PRODUCCION]
 ADD CONSTRAINT [FK_PRODUCTO_FINAL_SIPP] FOREIGN KEY ([CLIENTE_ID], [PROD_FINAL_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_INT_PARTE_PRODUCCION]
 ADD CONSTRAINT [FK_PRODUCTO_INSUMO_SIPP] FOREIGN KEY ([CLIENTE_ID], [PROD_INSUMO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[APF_BULTOS_POR_PALLET]
 ADD CONSTRAINT [FK_PRODUCTO_APF] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_UNIDAD_CONTENEDORA]
 ADD CONSTRAINT [FK_RLPUC_PRODUCTO] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_CONTENEDOR]
 ADD CONSTRAINT [fk_producto_contenedor] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_CRITERIO_UBIC_PRODUCTO]
 ADD CONSTRAINT [fk_rl_crit_ubic_prod_prod] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_DOCUMENTO]
 ADD CONSTRAINT [FK_DET_DOCUMENTO_PRODUCTO] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_CATLOG]
 ADD CONSTRAINT [fk_rl_prod_catlog#producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_TRATAMIENTO]
 ADD CONSTRAINT [fk_rl_prod_trat#producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_CODIGOS]
 ADD CONSTRAINT [FK_PRODUCTO_CODIGOS] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[PICKING]
 ADD CONSTRAINT [FK_PRODUCTO#PICKING] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO_AJU]
 ADD CONSTRAINT [fk_DET_INVENTARIO_AJU_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[HISTORICO_POSICION]
 ADD CONSTRAINT [fk_hist_pos_prod] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_PICKING]
 ADD CONSTRAINT [fk_rl_producto_picking] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_NAVEPOS_PICKING]
 ADD CONSTRAINT [fk_rl_prod_navepos_picking] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[HISTORICO_PRODUCTO]
 ADD CONSTRAINT [fk_hist_prod_prod] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_INVENTARIO]
 ADD CONSTRAINT [fk_det_inventario_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_CRITERIO_PRODUCTO]
 ADD CONSTRAINT [fk_rl_criterio_prod_prod] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[DET_CONTEO]
 ADD CONSTRAINT [fk_det_cont_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[CRITERIO_ASIG_PICKING]
 ADD CONSTRAINT [FK_PROD_CRITERIO_ASIG_PICKING] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[MANDATORIO_PRODUCTO]
 ADD CONSTRAINT [fk_mandat_prod_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[SYS_CRITERIO_LOCATOR]
 ADD CONSTRAINT [fk_locator_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[RL_PRODUCTO_POSICION_PERMITIDA]
 ADD CONSTRAINT [fk_rlppp_producto] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

ALTER TABLE [dbo].[HISTORICO_SALDO_PRODUCTO]
 ADD CONSTRAINT [FK_HSP_PROD] FOREIGN KEY ([CLIENTE_ID], [PRODUCTO_ID]) REFERENCES [dbo].[PRODUCTO] ([CLIENTE_ID], [PRODUCTO_ID]) 
GO

IF @@ERROR <> 0
BEGIN
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   INSERT INTO #tmpErrors (Error) SELECT 1
   BEGIN TRANSACTION
END
GO

IF @@TRANCOUNT > 0
BEGIN
   IF EXISTS (SELECT * FROM #tmpErrors)
       ROLLBACK TRANSACTION
   ELSE
       COMMIT TRANSACTION
END
GO

DROP TABLE #tmpErrors
GO