
ALTER TRIGGER [dbo].[TRG_STK_DISPONIBLE]
ON [dbo].[RL_DET_DOC_TRANS_POSICION]
AFTER UPDATE, INSERT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @RL_ID				NUMERIC(20,0)
	DECLARE @CAT_LOG_ID			VARCHAR(100)
	DECLARE @OLD_CAT_LOG		VARCHAR(100)
	DECLARE @DISPONIBLE			VARCHAR(100)
	DECLARE @NEW_CAT_LOG		VARCHAR(100)
	DECLARE @CAT_LOG_ID_FINAL	VARCHAR(100)
	DECLARE @STATUS				VARCHAR(100)
	DECLARE @DOC_TRANS_TR		NUMERIC(20,0)
	
	SELECT @RL_ID=RL_ID,@DOC_TRANS_TR=DOC_TRANS_ID_TR FROM INSERTED
	
	SELECT	DISTINCT @STATUS=D.STATUS
	FROM	DET_DOCUMENTO DD INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
			ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
			INNER JOIN RL_DET_DOC_TRANS_POSICION RL 
			ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
			INNER JOIN DOCUMENTO D 
			ON(DD.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	RL.RL_ID=@RL_ID

	IF (UPDATE(POSICION_ACTUAL) OR UPDATE(NAVE_ACTUAL))AND(@DOC_TRANS_TR IS NULL) BEGIN
		
		UPDATE RL_DET_DOC_TRANS_POSICION
		SET		CAT_LOG_ID=CAT_LOG_ID_FINAL,
				DISPONIBLE='1'
		FROM	RL_DET_DOC_TRANS_POSICION RL LEFT JOIN POSICION P ON(RL.POSICION_ACTUAL=P.POSICION_ID )
				LEFT JOIN NAVE N         ON(RL.NAVE_ACTUAL=N.NAVE_ID)
		WHERE	RL.RL_ID=@RL_ID
				AND ISNULL(P.intermedia,'0')='0'
				AND ISNULL(N.PRE_EGRESO,'0')='0' 
				AND ISNULL(N.PRE_INGRESO,'0')='0'
				AND isnull(RL.DISPONIBLE,'0')='0'
	END  

	IF UPDATE(CAT_LOG_ID) BEGIN

		SELECT @CAT_LOG_ID=CAT_LOG_ID,@DISPONIBLE=DISPONIBLE FROM DELETED
		SELECT @NEW_CAT_LOG=CAT_LOG_ID,@CAT_LOG_ID_FINAL=CAT_LOG_ID_FINAL FROM INSERTED
		
		IF @CAT_LOG_ID='TRAN_EGR' BEGIN

			UPDATE	RL_DET_DOC_TRANS_POSICION 
			SET		CAT_LOG_ID='TRAN_EGR',
					DISPONIBLE='0'
			WHERE	RL_ID=@RL_ID
			
		END
		
		IF @DISPONIBLE='1' AND @NEW_CAT_LOG=@CAT_LOG_ID_FINAL AND @STATUS<>'D40' BEGIN

			UPDATE	RL_DET_DOC_TRANS_POSICION 
			SET		CAT_LOG_ID=@CAT_LOG_ID
			WHERE	RL_ID=@RL_ID		

		END
	END
END

