CREATE NONCLUSTERED INDEX IDX_RL_DOC_TR ON DBO.RL_DET_DOC_TRANS_POSICION(DOC_TRANS_ID);
CREATE NONCLUSTERED INDEX IDX_POS_POSVACIA ON DBO.POSICION(POS_VACIA)INCLUDE(POSICION_ID);