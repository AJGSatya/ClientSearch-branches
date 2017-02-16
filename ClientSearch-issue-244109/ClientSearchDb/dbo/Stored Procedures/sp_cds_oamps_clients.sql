

CREATE      PROCEDURE [dbo].[sp_cds_oamps_clients]  @process_key int,@job_id int AS

-- Nov 16 2004: Swanson Phung - initial Release
-- 19 jan 2006: Swanson Phung - removed ods_oib_physicalbranch and BA data source only.
-- 03 Dec 2007: Swanson Phung - SQL 2005 migration and clean-up
-- 12 Jun 2009: Swanson Phung - added deposist BSB and account
-- 09 aug 2010: Swanson Phung - added ActiveClientInd

DECLARE  @log_msg varchar(100),@log_rollback varchar(100),@client_ident int
        ,@ins_log1 varchar(100), @del_log1 varchar(100), @ins_error1 int, @del_error1 int, @ins_log1_1 varchar(100), @ins_error1_1 int
        ,@ins_log2 varchar(100), @del_log2 varchar(100), @ins_error2 int, @del_error2 int
		,@upd_log1 varchar(100), @upd_error1 int

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL OFF
SET @client_ident = IDENT_CURRENT('cds_oamps_clients')


-- Remove the in-correct matched records (Exception file)
SET @log_msg = 'CIS - OAMPS Clients: Remove in-correct matched records '
DECLARE @clientcode1 varchar(100), @clientcode2 varchar(100),@client1_ID varchar(100),@client2_ID varchar(100),@rec_count int

DECLARE c1_cursor CURSOR FOR 
SELECT clientcode1,clientcode2 FROM [cis_OAMPS].dbo.ods_clients_matched_exception ORDER BY GroupNo, OrderNo

OPEN c1_cursor
FETCH NEXT FROM c1_cursor 
INTO @clientcode1, @clientcode2

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @client1_ID = (SELECT DDGroupID FROM [cis_OAMPS].dbo.ods_clients_matched WHERE clientcode = @clientcode1)
		SET @client2_ID = (SELECT DDGroupID FROM [cis_OAMPS].dbo.ods_clients_matched WHERE clientcode = @clientcode2)
		SET @rec_count  = (SELECT count(*)  FROM [cis_OAMPS].dbo.ods_clients_matched WHERE DDGroupID  = @client1_ID)
    
		IF  @client1_ID = @client2_ID
	        BEGIN
			-- PRINT @clientcode1 +' '+ convert(varchar(100),@client1_ID)+', '+ @clientcode2 +' '+ convert(varchar(100),@client2_ID)+', '+ convert(varchar(100),@rec_count)
				IF @rec_count = 2
					DELETE [cis_OAMPS].dbo.ods_clients_matched WHERE DDGroupID = @client1_ID
				ELSE
					IF @rec_count > 2
						DELETE [cis_OAMPS].dbo.ods_clients_matched WHERE clientcode = @clientcode1
			END
 
		-- Get the next rec.
		FETCH NEXT FROM c1_cursor 
		INTO @ClientCode1, @ClientCode2
  END

CLOSE c1_cursor
DEALLOCATE c1_cursor

EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @log_msg


-- START TRANSACTIONS.
BEGIN TRAN T1

   -- Preparation 
   SET @log_msg = 'CIS - OAMPS Clients: Clean-Up '
   DELETE [cis_OAMPS].dbo.cds_oamps_clients
   DBCC CHECKIDENT (cds_oamps_clients, RESEED, 1)
   SELECT @del_error1 = @@ERROR, @del_log1 = @log_msg


   -- Loading Unique Clients
   SET @log_msg = 'CIS - OAMPS Clients: Unique Clients '
   SET IDENTITY_INSERT [cis_OAMPS].dbo.cds_oamps_clients OFF

   INSERT INTO [cis_OAMPS].dbo.cds_oamps_clients
     (UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code,Last_Updated,Process_Key)
   SELECT 
      UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code,Last_Updated,Process_Key 
   FROM [cis_OAMPS].dbo.ods_clients_basic org
   WHERE not exists
         (SELECT * 
            FROM [cis_OAMPS].dbo.ods_clients_matched dup
           WHERE org.ClientCode = dup.ClientCode
             AND org.local_branchcode = dup.local_branchcode)
   SELECT @ins_error1 = @@ERROR, @ins_log1 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'


   -- Loading Matched clients
   SET @log_msg = 'CIS - OAMPS Clients: Matched Clients '
   SET IDENTITY_INSERT [cis_OAMPS].dbo.cds_oamps_clients ON
   INSERT INTO [cis_OAMPS].dbo.cds_oamps_clients
     (UID,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code,Last_Updated,Process_Key)
   SELECT 
      DDGROUPID,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code,Last_Updated,Process_Key 
   FROM [cis_OAMPS].dbo.ods_clients_matched

   SELECT @ins_error1_1 = @@ERROR, @ins_log1_1 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'


   -- Check errors
   IF @del_error1 = 0 AND @ins_error1 = 0 AND @ins_error1_1 = 0
      BEGIN
        COMMIT TRAN T1
        EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @del_log1   
        EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log1
        EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log1_1
      END
   ELSE
      BEGIN
        ROLLBACK TRAN T1
        DBCC CHECKIDENT (cds_oamps_clients, RESEED, @client_ident)
        IF @del_error1 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to DELETE ' + convert(varchar, @del_error1)            EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback
          END 
        IF @ins_error1 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to INSERT Duplicated Clients ' + convert(varchar, @ins_error1)
            EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
          END 
        IF @ins_error1_1 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to INSERT Unique Clients ' + convert(varchar, @ins_error1)
            EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
          END 
      END 


BEGIN TRAN T2
   -- Physical Branch
   SET @log_msg = 'CIS - OAMPS Clients: Physiccal Branch '
   DELETE [cis_OAMPS].dbo.ods_oamps_physicalbranch
   SELECT @del_error2 = @@ERROR, @del_log2 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'


   INSERT INTO [cis_OAMPS].dbo.ods_oamps_physicalbranch
         (UnitCode,SystemCode,LedgerCode,process_key)
   SELECT UnitCode,SystemCode,LedgerCode,@process_key
     FROM [cis_OAMPS].dbo.cds_oamps_clients 
   GROUP BY UnitCode,SystemCode,LedgerCode
   SELECT @ins_error2 = @@ERROR, @ins_log2 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'

   -- update deposist BSB and account
   SET @log_msg = 'CIS - OAMPS Clients: Deposist BSB, DepositAccount, and ActiveClientInd '
   UPDATE	[cis_OAMPS].dbo.cds_oamps_clients
   SET		 DepositBSB		= b.DepositBSB
			,DepositAccount = b.DepositAccount
			,ActiveClientInd= b.ActiveClientInd
   FROM
					[cis_OAMPS].dbo.cds_oamps_clients	a
		inner join	[dw_OAMPS].dbo.dds_fct_client		b on  a.ClientCode = b.ClientCode
   WHERE	a.ClientCode = b.ClientCode
   SELECT @upd_error1 = @@ERROR, @upd_log1 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS UPDATED'


   -- Check errors
   IF @del_error2 = 0 AND @ins_error2 = 0 AND @upd_error1 = 0 
      BEGIN
        COMMIT TRAN T2
        EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @del_log2   
        EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log2
        EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @upd_log1
      END
   ELSE
      BEGIN
        ROLLBACK TRAN T2
        IF @del_error2 <> 0
          BEGIN 
            SET @log_rollback = @del_log2 + 'ROLL BACK Failed to DELETE ' + convert(varchar, @del_error2)
            EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback
          END 
        IF @ins_error2 <> 0
          BEGIN 
            SET @log_rollback = @ins_log2 + 'ROLL BACK Failed to INSERT ' + convert(varchar, @ins_error2)
            EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
          END 
        IF @upd_error1 <> 0
          BEGIN 
            SET @log_rollback = @upd_log1 + 'ROLL BACK Failed to INSERT ' + convert(varchar, @upd_error1)
            EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
          END 
      END 

-- END TRANSACTIONS.
DECLARE @process_end datetime
SET @process_end = getdate()

IF    @del_error1 <> 0 OR @ins_error1 <> 0 OR @ins_error1_1 <> 0
   OR @del_error2 <> 0 OR @ins_error2 <> 0 OR @upd_error1 <> 0

   BEGIN     SET @log_msg = 'CIS - OAMPS Clients: ROLL BACK'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_end @job_id,@process_key,NULL,@process_end,@log_msg,'FAILED'  
     RAISERROR ('ROLL BACK: Failed to Delete / Insert', 16, 1)  
   END

