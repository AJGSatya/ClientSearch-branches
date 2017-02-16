






CREATE PROCEDURE [dbo].[sp_ods_clients_matched]
(
	 @process_key	int
	,@job_id		int
) AS

-- Nov 16 2004: Swanson Phung - initial Release
-- Aug 22 2005: Swanson Phung - changed @clients_total from count of ods_clients_company => count of ods_clients_company and ods_clients_noncompany   
-- 19 jan 2006: Swanson Phung - removed ods_oib_physicalbranch and BA data source only.
-- 03 Dec 2007 - Swanson Phung: SQL 2005 migration and clean-up

DECLARE  @log_msg varchar(100),@log_rollback varchar(100),@process_end datetime
        ,@clients_total int,@clients_cleansed int,@clients_threshold int,@clients_com_matched int,@clients_ind_matched int, @clients_matched int
        ,@ins_log1_1 varchar(100), @del_log1_1 varchar(100), @ins_error1_1 int, @del_error1_1 int
        ,@ins_log1_2 varchar(100), @del_log1_2 varchar(100), @ins_error1_2 int, @del_error1_2 int
        ,@ins_log1_3 varchar(100), @del_log1_3 varchar(100), @ins_error1_3 int, @del_error1_3 int
        ,@ins_log2 varchar(100), @del_log2 varchar(100), @ins_error2 int, @del_error2 int,@ins_log2_1 varchar(100), @ins_error2_1 int

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL OFF

SET @clients_total			= (SELECT convert(int,count(*)) FROM [cis_OAMPS].dbo.ods_clients_company) + (SELECT convert(int,count(*)) FROM [cis_OAMPS].dbo.ods_clients_noncompany)
SET @clients_cleansed		= (SELECT convert(int,count(*)) FROM [cis_OAMPS].dbo.stg_clients_cleansed WHERE isnumeric(PCStatus) <> 0)
SET @clients_threshold		= (SELECT convert(int,Value1)	FROM [cis_OAMPS].dbo.utl_system_option WHERE Type = 'Clients_No')
SET @clients_com_matched    = (SELECT convert(int,count(*)) FROM [cis_OAMPS].dbo.stg_clients_company_matched) 
SET @clients_ind_matched    = (SELECT convert(int,count(*)) FROM [cis_OAMPS].dbo.stg_clients_noncompany_matched) 

-- debug
--print @clients_total
--print @clients_cleansed
--print @clients_Threshold
--print @clients_com_Matched
--print @clients_ind_Matched


IF     @clients_com_matched >= @clients_threshold	-- Bus Client Matching check
   AND @clients_ind_matched >= @clients_threshold	-- Non Bus Clients Matching check
   AND @clients_total		 = @clients_cleansed	-- Cleansing process check 


  BEGIN

  -- START TRANSACTIONS.

    BEGIN TRAN T1
     SET @log_msg = 'CIS - ODS Loading Clients: '
     -- Clean-up
     DELETE [cis_OAMPS].dbo.ods_clients_cleansed
     SELECT @del_error1_1 = @@ERROR, @del_log1_1 = @log_msg + 'Cleansed ' + convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @del_log1_1  

     DELETE [cis_OAMPS].dbo.ods_clients_company_matched
     SELECT @del_error1_2 = @@ERROR, @del_log1_2 = @log_msg +'Company Matched '+ convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @del_log1_2  

     DELETE [cis_OAMPS].dbo.ods_clients_noncompany_matched
     SELECT @del_error1_3 = @@ERROR, @del_log1_3 = @log_msg +'Non-Company Matched '+ convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @del_log1_3  

     -- Loading

     INSERT INTO [cis_OAMPS].dbo.ods_clients_cleansed
       (PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
       ,Last_Updated,Process_Key)
     SELECT  
        PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
       ,Last_Updated,@Process_Key
     FROM [cis_OAMPS].dbo.stg_clients_cleansed
     WHERE isnumeric(PCStatus) <> 0
     SELECT @ins_error1_1 = @@ERROR, @ins_log1_1 = @log_msg +'Cleansed '+ convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log1_1  


     INSERT INTO [cis_OAMPS].dbo.ods_clients_company_matched
		(DDGroupID
		,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
		,Last_Updated,Process_Key,DDPctg)
     SELECT  
         substring(DDGroupID,2,len(DDGroupID)-1) -- remove unwanted 1st letter
		,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
		,Last_Updated,@Process_Key,DDPctg
     FROM [cis_OAMPS].dbo.stg_clients_company_matched
     SELECT @ins_error1_2 = @@ERROR, @ins_log1_2 = @log_msg +'Company Matched '+ convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log1_2 


     INSERT INTO [cis_OAMPS].dbo.ods_clients_noncompany_matched
		(DDGroupID
		,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
		,Last_Updated,Process_Key,DDPctg)
     SELECT  
		 substring(DDGroupID,2,len(DDGroupID)-1) -- remove unwanted 1st letter
		,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
		,Last_Updated,@Process_Key,DDPctg
     FROM [cis_OAMPS].dbo.stg_clients_noncompany_matched
     SELECT @ins_error1_3 = @@ERROR, @ins_log1_3 = @log_msg +'Non-Company Matched '+ convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log1_3 


     -- Check errors
     IF @del_error1_1 = 0 AND @ins_error1_1 = 0 AND
        @del_error1_2 = 0 AND @ins_error1_2 = 0 AND
        @del_error1_3 = 0 AND @ins_error1_3 = 0
        BEGIN
          COMMIT TRAN T1
        END
     ELSE
        BEGIN
          ROLLBACK TRAN T1
          IF @del_error1_1 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'Cleansed - Failed to DELETE ' + convert(varchar, @del_error1_1)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback
            END 
          IF @ins_error1_1 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'Cleansed - Failed to INSERT ' + convert(varchar, @ins_error1_1)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
            END 
          IF @del_error1_2 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'Company Matched - Failed to DELETE ' + convert(varchar, @del_error1_2)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback
            END 
          IF @ins_error1_2 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'Company Matched - Failed to INSERT ' + convert(varchar, @ins_error1_2)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
            END 
          IF @del_error1_3 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'Non-Company Matched - Failed to DELETE ' + convert(varchar, @del_error1_3)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback
            END 
          IF @ins_error1_3 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'Non-Company Matched - Failed to INSERT ' + @ins_error1_3
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
            END 
        END 


    BEGIN TRAN T2
     SET @log_msg = 'CIS - ODS Matching Clients: '
     -- backup previous run - matched clients
     DELETE [cis_OAMPS].dbo.ods_clients_matched_prevrun
     INSERT INTO [cis_OAMPS].dbo.ods_clients_matched_prevrun
     SELECT * FROM [cis_OAMPS].dbo.ods_clients_matched

     -- prepare for this run
     DELETE [cis_OAMPS].dbo.ods_clients_matched
     SELECT @del_error2 = @@ERROR, @del_log2 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @del_log2   


     -- matched Company clients ID start at 80000000
     INSERT INTO [cis_OAMPS].dbo.ods_clients_matched
       (DDGroupID
       ,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
       ,Last_Updated,Process_Key)
     SELECT  
	    80000000+convert(int,DDGroupID)as DDGroupID
       ,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
       ,Last_Updated,@Process_Key
     FROM [cis_OAMPS].dbo.ods_clients_company_matched
     SELECT @ins_error2 = @@ERROR, @ins_log2 = @log_msg + 'Company Matched ' +  convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log2


     -- matched Non-Company clients ID start at 90000000
     INSERT INTO [cis_OAMPS].dbo.ods_clients_matched
       (DDGroupID
       ,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
       ,Last_Updated,Process_Key)
     SELECT  
        90000000+convert(int,DDGroupID)as DDGroupID
       ,PCStatus,AddressKey,DPID,CompanyKey,CompanyKeyword,NameKey,UnitCode,SystemCode,LedgerCode,BranchCode,Local_BranchCode,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Suburb,Postcode,Postal_Address_Line_1,Postal_Address_Line_2,Postal_Address_Line_3,Postal_Suburb,Addressee,Salutation,Gender,ClientExecutiveCode,Phone,Fax,Mobile,Email,ABN,Retail_Wholesale,Contact_Method,Contact_Preference,Contact_Comments,Operation,Commence_Date,Association_Code
       ,Last_Updated,@Process_Key
     FROM [cis_OAMPS].dbo.ods_clients_noncompany_matched
     SELECT @ins_error2_1 = @@ERROR, @ins_log2_1 = @log_msg + 'Non-Company Matched ' + convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'
     EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @ins_log2_1

     -- Check errors
     IF @del_error2 = 0 AND @ins_error2 = 0 AND @ins_error2_1 = 0
        BEGIN
          COMMIT TRAN T2
        END
     ELSE
        BEGIN
          ROLLBACK TRAN T2
          IF @del_error2 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'ROLL BACK Failed to DELETE ' + convert(varchar, @del_error2) 
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback
            END 
          IF @ins_error2 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'ROLL BACK Failed to INSERT ' + convert(varchar, @ins_error2)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
            END 
          IF @ins_error2_1 <> 0
            BEGIN 
              SET @log_rollback = @log_msg + 'ROLL BACK Failed to INSERT ' + convert(varchar, @ins_error2_1)
              EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key,@log_rollback  
            END 
        END 

  -- END TRANSACTIONS

  END

ELSE
  BEGIN
    SET @process_end = getdate()
    SET @log_msg = 'ABORTED... '+convert(varchar,@clients_total)+' Total, '+convert(varchar,@clients_cleansed)+' cleansed, '+convert(varchar,@clients_com_matched)+' Bus matched, '+ +convert(varchar,@clients_ind_matched)+' Non-Bus matched, '+convert(varchar, @clients_threshold) + ' Threshold Level '
    EXECUTE [cis_OAMPS].dbo.sp_utl_log_end @job_id,@process_key,NULL,@process_end,@log_msg,'FAILED'  
    RAISERROR ('ABORTED: No of matched Clients < Threshold level', 16, 1)  
  END






