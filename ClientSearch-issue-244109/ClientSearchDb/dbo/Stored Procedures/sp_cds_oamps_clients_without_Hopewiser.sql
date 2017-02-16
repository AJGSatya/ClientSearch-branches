
CREATE      PROCEDURE [dbo].[sp_cds_oamps_clients_without_Hopewiser]  AS
-- 30 may 2013: Swanson Phung - initial Release
-- 17 sep 2015: Swanson Phung - added len(LedgerCode) between 4 and 20 

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE	 @JobDesc		varchar(200)
		,@StepDesc		varchar(200)
		,@StepCompleted varchar(200)
		,@ProcessEnd	datetime
		,@ErrMsg		varchar(4000)
		,@ErrSeverity	int
		,@job_id		int
		,@process_key	int
		

-- Process Key.
SET	@job_id =  902
EXEC sp_utl_log_getkey @job_id , @process_key OUTPUT SET		@process_key = @process_key
IF @process_key is NULL  BEGIN RAISERROR ('FAILED to Get Process_Key', 16, 1) RETURN END
ELSE EXEC sp_utl_log_update  @process_key,'Process started '



-- main
	SET	@JobDesc = 'CIS - OAMPS Clients'
	BEGIN TRY

	  BEGIN TRANSACTION


		SET		@StepDesc = 'cds table - Delete'
		DELETE	[cis_oamps].dbo.cds_oamps_clients
		DBCC	CHECKIDENT (cds_oamps_clients, RESEED, 1)
		
		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted



		SET		@StepDesc = 'cds table - Insert'
		SET IDENTITY_INSERT [cis_oamps].dbo.cds_oamps_clients OFF

		INSERT INTO [cis_oamps].dbo.cds_oamps_clients
				(
				 UnitCode
				,SystemCode
				,LedgerCode
				,BranchCode
				,Local_BranchCode
				,ClientCode
				,ClientName
				,Address_Line_1
				,Address_Line_2
				,Address_Line_3
				,Suburb
				,Postcode
				,Postal_Address_Line_1
				,Postal_Address_Line_2
				,Postal_Address_Line_3
				,Postal_Suburb
				,Addressee
				,Salutation
				,Gender
				,ClientExecutiveCode
				,Phone
				,Fax
				,Mobile
				,Email
				,ABN
				,Retail_Wholesale
				,Contact_Method
				,Contact_Preference
				,Contact_Comments
				,Operation
				,Commence_Date
				,Association_Code
				,Last_Updated
				,Process_Key
				,DepositBSB
				,DepositAccount
				,ActiveClientInd
				)
		SELECT 
			 	 'OIB' as UnitCode
				,'OIB' as SystemCode
				,Ledger_Code
				,BranchCode
				,Local_BranchCode
				,ClientCode
				,ClientName
				,Address_Line_1
				,Address_Line_2
				,Address_Line_3
				,Suburb
				,Postcode
				,Postal_Address_Line_1
				,Postal_Address_Line_2
				,Postal_Address_Line_3
				,Postal_Suburb
				,Addressee
				,Salutation
				,Gender
				,ClientExecutiveCode
				,Phone
				,Fax
				,Mobile
				,Email
				,ABN
				,Retail_Wholesale
				,Contact_Method
				,Contact_Preference
				,Contact_Comments
				,Operation
				,Commence_Date
				,Association_Code
				,getdate() as Last_Updated
				,Process_Key
				,DepositBSB
				,DepositAccount
				,ActiveClientInd

		FROM		[dw_OAMPS].dbo.dds_fct_client cli
		
		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted



		SET		@StepDesc = 'cds table - Remove Dummy'
		DELETE	[cis_oamps].dbo.cds_oamps_clients
		WHERE	ledgercode = 'PRIMROFF.LIVE'
		OR		clientname is null
		OR		clientname like '%See Particulars%'
		OR		clientname like '%Unidentified%client%'
		OR		clientname like '%As Per Schedule%'
		OR		clientname like 'Commissions'
		OR		clientname like '%AMTI DECLINED%'
		OR		clientname like '%test%client%'
		OR		clientname like 'Adjustment%'
		OR		clientname like 'Sub Agent Commissions%'
		OR		clientname like 'DO NOT SEND'
		OR		clientname like '%Dummy Client%'
		OR		clientname like 'Premium Debtors'
		OR		clientname like 'SEE TX12'
		OR		clientname like 'QUOTE'
		OR		clientname like 'Sub Agent Commission Creditors'
		OR		clientname like 'Broker Fees'

		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted
		


		SET		@StepDesc = 'Physicalbranch - Delete'
		DELETE [cis_oamps].dbo.ods_oamps_physicalbranch

		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted



		SET		@StepDesc = 'Physicalbranch - Insert'
		INSERT INTO [cis_oamps].dbo.ods_oamps_physicalbranch
				(UnitCode,SystemCode,LedgerCode,process_key)
		SELECT	 UnitCode,SystemCode,LedgerCode,@process_key
		FROM	[cis_oamps].dbo.cds_oamps_clients 
		WHERE	len(LedgerCode) between 4 and 20 
		GROUP BY UnitCode,SystemCode,LedgerCode

		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted




		-- Success. Commit the transaction
		COMMIT

		-- Job End - DDS ONLY 
		SET @ProcessEnd	= getdate()
		SET	@StepCompleted	= @JobDesc + ' : Completed '
	 	EXECUTE sp_utl_log_end @job_id,@process_key,NULL,@ProcessEnd,@StepCompleted,'DONE'  

	  END TRY


	  BEGIN CATCH

		ROLLBACK

		SET @ProcessEnd		= getdate()
		SET @ErrMsg			= ERROR_MESSAGE()
		SET @ErrSeverity	= ERROR_SEVERITY()
		SET @StepCompleted	= @JobDesc + ' : ERROR occured at ' + @StepDesc + ' - ' + @ErrMsg

		-- error details
		EXECUTE sp_utl_log_update @process_key,@StepCompleted 
		-- job end
	 	EXECUTE sp_utl_log_end @job_id,@process_key,NULL,@ProcessEnd,@StepCompleted,'FAILED'  
		RAISERROR (@StepCompleted,@ErrSeverity,1)  

	  END CATCH



