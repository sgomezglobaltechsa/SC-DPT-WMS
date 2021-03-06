
ALTER          PROCEDURE [dbo].[SYS_DEV]
@documento_id AS NUMERIC(20,0) output,
@estado	as numeric(2,0) output
AS
DECLARE @doc_Ext AS varchar(100)
DECLARE @td AS varchar(20)
DECLARE @qty AS numeric(3,0)
DECLARE @nro_lin AS numeric(20,0)
DECLARE @tc AS varchar(15)
DECLARE @status AS varchar(5)
DECLARE @qty_doc_ext AS numeric(3,0)
DECLARE @tiene_cont AS numeric(3,0)
BEGIN
	select @doc_ext=nro_despacho_importacion,@tc=tipo_comprobante_id,@status=status from documento where documento_id=@documento_id
	select @qty=count(*) from sys_dev_documento where doc_ext=@doc_ext
	select @td=tipo_documento_id from sys_int_documento where doc_ext=@doc_ext
	select @nro_lin=max(nro_linea) from sys_dev_det_documento where doc_ext=@doc_ext
	
	select @qty_doc_ext=count(distinct prop2)from	documento d inner join det_documento dd
	on(d.documento_id=dd.documento_id)
	where	d.documento_id=@documento_id	
	
	select @tiene_cont=count(NRO_BULTO) from det_documento where documento_id = @documento_id	
	
IF (@qty_doc_ext>1 and @status='D40')
	BEGIN
		exec SYS_DEV_BULTOS @documento_id, @estado
		return
	END

 IF (@tiene_cont>0 and @status='D40')
	BEGIN
		exec SYS_DEV_BULTOS @documento_id, @estado
		return
	END	

IF (@doc_ext <> '' and @doc_ext is not null and @status='D40')
BEGIN
	
	IF (@td='I01' and @estado=1 and @tc='DO')
	BEGIN
	     exec sys_dev_I01
		 @doc_ext=@doc_ext
		,@estado=1 
                ,@documento_id=@documento_id
	END --IF

	IF (@td='I01' and @estado=3 and @tc='DO')
	BEGIN
	     	 exec sys_dev_I03
		 @doc_ext=@doc_ext
		,@estado=1 
                ,@documento_id=@documento_id
	END --IF

	IF (@td='I04' and @estado=1 and @tc='PP')
	BEGIN
	     	 exec sys_dev_I04
		 @doc_ext=@doc_ext
		,@estado=1 
                ,@documento_id=@documento_id
	END --IF

	IF (@td is null and @estado=1 and @tc='DE')
	BEGIN
	     	 exec    sys_dev_I08
					 @doc_ext=@doc_ext
					,@estado=@estado 
			        ,@documento_id=@documento_id
	END --IF
	
	IF (@td='I01' and @estado=1 and @tc='DE')
	BEGIN
	     	exec    sys_dev_I08
					@doc_ext=@doc_ext
					,@estado=@estado 
					,@documento_id=@documento_id
	END --IF
				
	IF (@td='E04' and @estado=1 and @tc='DE')
	BEGIN
	     	 exec    sys_dev_I08
					 @doc_ext=@doc_ext
					,@estado=@estado 
			        ,@documento_id=@documento_id
	END --IF
	
	SELECT @TD AS [TD]
	SELECT @ESTADO AS [ESTADO]
	SELECT @TC AS [TC]

	IF (@td is null and @estado=1 and @tc='IM')
	BEGIN
	     	 exec sys_dev_I07
		 @doc_ext=@doc_ext
		,@estado=@estado 
                ,@documento_id=@documento_id
	END --IF

END --IF

	IF (@td is null and @estado=1 and @tc='DE')
		BEGIN
	     	exec    sys_dev_I08
					@doc_ext=@doc_ext
					,@estado=@estado 
					,@documento_id=@documento_id
	END --IF


	IF (@td='I04' and @estado=2 and @tc='PP' and @status='D30')
	--Anula el pallet y genera un I06
    BEGIN
	     exec sys_dev_I04_D
		 @doc_ext=@doc_ext
		,@estado=2 
        ,@documento_id=@documento_id
	END --IF

END --PROCEDURE
