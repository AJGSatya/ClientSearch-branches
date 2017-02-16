

CREATE     PROCEDURE [dbo].[sp_ods_clients]
(
	 @process_key	int
	,@job_id		int
) AS

-- Nov 16 2004: Swanson Phung - initial Release
-- Feb 14 2005: Swanson Phung - remove "|" from dbo.ods_clients_basic for data cleasing/matching. 
-- Sep 19 2005: changed left outer join to inner join with ods_oib_physicalbranch for BA clients - exluding BA clients without ledger 
-- 19 jan 2006: Swanson Phung - removed ods_oib_physicalbranch and BA data source only.
-- 22 jan 2006: excluding PRIMROFF.LIVE ledger - USD 30649
-- 03 Dec 2007 - Swanson Phung: SQL 2005 migration and clean-up
-- 15 Apr 2010:Swanson Phung - client-without-transactions by removing join to dw_oamps.dbo.dds_fct_policytransaction if possible 



DECLARE  @log_msg varchar(100),@log_rollback varchar(100)
        ,@ins_log1 varchar(100), @del_log1 varchar(100), @ins_error1 int, @del_error1 int
        ,@ins_log2 varchar(100), @del_log2 varchar(100), @ins_error2 int, @del_error2 int

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL OFF

--- last financial year  
DECLARE @lfy_start smalldatetime, @lfy_end smalldatetime
IF datepart(m, getdate()) between 7 and 12 
     SET @lfy_start = convert(smalldatetime,'1 July '+ convert(varchar,datepart(yy,getdate())-1))
ELSE SET @lfy_start = convert(smalldatetime,'1 July '+ convert(varchar,datepart(yy,getdate())-2))
SET @lfy_end = dateadd(m,12,@lfy_start)


-- main loading

BEGIN TRAN T1
   SET @log_msg = 'CIS - OIB Clients: Basic, '

   DELETE [cis_oamps].dbo.ods_clients_basic  WHERE  UnitCode = 'OIB'
   SELECT @del_error1 = @@ERROR, @del_log1 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'

   INSERT INTO	[cis_oamps].dbo.ods_clients_basic
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
	,Association_Code
	,Last_Updated
	,Process_Key
	)
   SELECT --TOP 1000 -- <======= for test run 
	 'OIB' as UnitCode
	,'OIB' as SystemCode
	,cli.Ledger_Code as LedgerCode
	,cli.BranchCode
	,cli.Local_BranchCode
	,cli.ClientCode
	,cli.ClientName
	,cli.Address_Line_1
	,cli.Address_Line_2
	,cli.Address_Line_3
	,cli.Suburb
	,cli.Postcode
	,cli.Postal_Address_Line_1
	,cli.Postal_Address_Line_2
	,cli.Postal_Address_Line_3
	,cli.Postal_Suburb
	,cli.Addressee
	,cli.Salutation
	,cli.Gender
	,cli.ClientExecutiveCode
	,cli.Phone
	,cli.Fax
	,cli.Mobile
	,cli.Email
	,cli.ABN
	,cli.Retail_Wholesale
	,cli.Contact_Method
	,cli.Contact_Preference
	,cli.Contact_Comments
	,cli.Operation
	,cli.Association_Code
	,getdate()
	,cli.process_key

   FROM		[dw_oamps].dbo.dds_fct_client cli 

   WHERE	cli.ledger_code <> 'PRIMROFF.LIVE'

/*
-- 15 Apr 2010:Swanson Phung - client-without-transactions
   AND		exists 
			(-- clients with transaction ONLY
			select 1
			from [dw_oamps].dbo.dds_fct_policytransaction trn 
			where cli.clientcode = trn.clientcode
			)	
-- 15 Apr 2010:Swanson Phung - client-without-transactions
*/

   SELECT @ins_error1 = @@ERROR, @ins_log1 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'

   -- Check errors
   IF @del_error1 = 0 AND @ins_error1 = 0
      BEGIN
        COMMIT TRAN T1
        EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key, @del_log1   
        EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key, @ins_log1
      END
   ELSE
      BEGIN
        ROLLBACK TRAN T1
        IF @del_error1 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to DELETE ' + convert(varchar,@del_error1 )
            EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@log_rollback
          END 
        IF @ins_error1 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to INSERT ' + convert(varchar,@ins_error1 )
            EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@log_rollback  
          END 
      END 





BEGIN TRAN T2
   SET @log_msg = 'CIS - OIB Clients: Specific, '

   DELETE [cis_oamps].dbo.ods_clients_specific_oib
   SELECT @del_error2 = @@ERROR, @del_log2 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS DELETED'

   INSERT INTO [cis_oamps].dbo.ods_clients_specific_oib
		(
		 UnitCode
		,SystemCode
		,LedgerCode
		,BranchCode
		,Local_BranchCode
		,ClientCode
		,ClientName
		,TeamCode
		,Netbrokerage_lfy
		,BasePremium_lfy
		,IncomeBand_lfy
		,Netbrokerage_ytd		,BasePremium_ytd		,IncomeBand_ytd		,Renewal_date
		,last_transaction_date
		,NoOfClaim_l5yrs
		,Process_Key
		)
   SELECT --TOP 1000 -- <======= for test run  
		 'OIB'
		,'OIB'
		,cli.Ledger_Code as LedgerCode
		,cli.BranchCode
		,cli.Local_BranchCode
		,cli.clientcode
		,cli.clientname
		,cli.TeamCode
		,lfy.Netbrokerage_lfy
		,lfy.BasePremium_lfy
		,lfy.IncomeBand_lfy
		,ytd.Netbrokerage_ytd
		,ytd.BasePremium_ytd
		,ytd.IncomeBand_ytd
		,ren.renewal_date
		,pol.last_transaction_date
		,cla.NoOfClaim_l5yrs
		,@process_key

   FROM
			[dw_oamps].dbo.dds_fct_client cli

-- 15 Apr 2010:Swanson Phung - client-without-transactions 		INNER JOIN    
		LEFT OUTER JOIN
  
			(-- clients with transaction only
			select	clientcode , max(invoicedate) as last_transaction_date
			from	[dw_oamps].dbo.dds_fct_policytransaction
			where	last_transaction_ind = 1
			group by clientcode 
			) pol  ON cli.clientcode = pol.clientcode

		LEFT OUTER JOIN
	
			(-- Last financial year - BasePremium, Netbrokerage, and IncomeBand 
			select 
			        clientcode
				   ,sum(BasePremium) as BasePremium_lfy
				   ,sum(Netbrokerage) as Netbrokerage_lfy
				   ,case when sum(Netbrokerage)< 0 then ' < 0'
						 when sum(Netbrokerage) between 0 and 250 then '0-250'
				         when sum(Netbrokerage) between 250 and 500 then '250-500'
					     when sum(Netbrokerage) between 500 and 1000 then '500-1000'
					     when sum(Netbrokerage) between 1000 and 2500 then '1000-2500'
					     when sum(Netbrokerage) between 2500 and 5000 then '2500-5000'
					     when sum(Netbrokerage) > 5000 then '5000+'
				         end as IncomeBand_lfy
			from	[dw_oamps].dbo.dds_fct_policytransaction
			where	Financial_month >= @lfy_start and Financial_month < @lfy_end
			group by clientcode 
			) lfy ON cli.clientcode = lfy.clientcode

		LEFT OUTER JOIN        

			(-- year to date - BasePremium, Netbrokerage, and IncomeBand 
			select 
			        clientcode
			       ,sum(BasePremium) as BasePremium_ytd
			       ,sum(Netbrokerage) as Netbrokerage_ytd
			       ,case when sum(Netbrokerage)< 0 then '< 0'
				         when sum(Netbrokerage) between 0 and 250 then '0-250'
			             when sum(Netbrokerage) between 250 and 500 then '250-500'
					     when sum(Netbrokerage) between 500 and 1000 then '500-1000'
					     when sum(Netbrokerage) between 1000 and 2500 then '1000-2500'
					     when sum(Netbrokerage) between 2500 and 5000 then '2500-5000'
				         when sum(Netbrokerage) > 5000 then '5000+'
					     end as IncomeBand_ytd
			from	[dw_oamps].dbo.dds_fct_policytransaction
			where	Financial_month >= @lfy_end
			group by clientcode 
			) ytd   ON cli.clientcode = ytd.clientcode

		LEFT OUTER JOIN        	

			(-- Active and Expired clients - re-newal date
			select	clientcode , min(expirydate) as renewal_date
			from	[dw_oamps].dbo.dds_fct_policytransaction
			where	last_transaction_ind = 1			and		transactiontype <> 'Cancellation'
			group by clientcode 
			) ren    ON cli.clientcode = ren.clientcode

		LEFT OUTER JOIN          

			(-- last 5 fiscal years - Total number of claims
			select	clientcode,count(claimno)as NoOfClaim_l5yrs
			from	[dw_oamps].dbo.dds_fct_policyclaim
			where	TransactionDate between dateadd(year, -5, getdate()) and getdate()
			group by clientcode 
			) cla    ON cli.clientcode = cla.clientcode

   WHERE cli.ledger_code <> 'PRIMROFF.LIVE'

   SELECT @ins_error2 = @@ERROR, @ins_log2 = @log_msg + convert(varchar, @@ROWCOUNT) + ' ROWS INSERTED'

   -- Check errors
   IF @del_error2 = 0 AND @ins_error2 = 0
      BEGIN
        COMMIT TRAN T2
        EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key, @del_log2   
        EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key, @ins_log2
      END
   ELSE
      BEGIN
        ROLLBACK TRAN T2
        IF @del_error2 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to DELETE ' + convert(varchar,@del_error2 )
            EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@log_rollback
          END 
        IF @ins_error2 <> 0
          BEGIN 
            SET @log_rollback = @log_msg + 'ROLL BACK Failed to INSERT ' + convert(varchar,@ins_error2 )
            EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@log_rollback  
          END 
      END 





-- misc

DECLARE @misc_log varchar(100), @misc_error int
SET @log_msg = 'CIS - ODS Clients: Misc, '

   -- remove dummy customers  
   DELETE [cis_oamps].dbo.ods_clients_basic_rejected

   INSERT INTO [cis_oamps].dbo.ods_clients_basic_rejected
   SELECT *
     FROM [cis_oamps].dbo.ods_clients_basic
   WHERE
		 clientname is null
      or clientname like '%See Particulars%'
      or clientname like '%Unidentified%client%'
      or clientname like '%As Per Schedule%'
      or clientname like 'Commissions'
      or clientname like '%AMTI DECLINED%'
      or clientname like '%test%client%'
      or clientname like 'Adjustment%'
      or clientname like 'Sub Agent Commissions%'
      or clientname like 'DO NOT SEND'
      or clientname like '%Dummy Client%'
      or clientname like 'Premium Debtors'
      or clientname like 'SEE TX12'
      or clientname like 'QUOTE'
      or clientname like 'Sub Agent Commission Creditors'
      or clientname like 'Broker Fees'

   DELETE [cis_oamps].dbo.ods_clients_basic
   WHERE clientcode in ( select clientcode from [cis_oamps].dbo.ods_clients_basic_rejected ) 

   SELECT @misc_error = @@ERROR, @misc_log = @log_msg + convert(varchar, @@ROWCOUNT) + ' Dummy client ROWS REMOVED'
   EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@misc_log

   -- Remove postcode if postcode includes in address lines. 
   --UPDATE [cis_oamps].dbo.ods_clients_basic
   --   SET Postcode = null 
   -- WHERE postcode is not null
   --   AND (PATINDEX('%[^box][ ][2-8][0-9][0-9][0-9]%',Address_Line_1)<>0 AND SUBSTRING(Address_Line_1,PATINDEX('%[^box][ ][2-8][0-9][0-9][0-9]%',Address_Line_1)+2, 4) = RTRIM(LTRIM(Postcode)))
   --    OR (PATINDEX('%[^box][ ][2-8][0-9][0-9][0-9]%',Address_Line_2)<>0 AND SUBSTRING(Address_Line_2,PATINDEX('%[^box][ ][2-8][0-9][0-9][0-9]%',Address_Line_2)+2, 4) = RTRIM(LTRIM(Postcode)))
   --    OR (PATINDEX('%[^box][ ][2-8][0-9][0-9][0-9]%',Address_Line_3)<>0 AND SUBSTRING(Address_Line_3,PATINDEX('%[^box][ ][2-8][0-9][0-9][0-9]%',Address_Line_3)+2, 4) = RTRIM(LTRIM(Postcode)))
   --SELECT @misc_error = @@ERROR, @misc_log = @log_msg + convert(varchar, @@ROWCOUNT) + ' Postcode ROWS UPDATED'
   --EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@misc_log


   -- Replace 'P/L' to 'PTY LTD' and double_quotation(") to single quotation(') - for data cleansing/matching.
   UPDATE [cis_oamps].dbo.ods_clients_basic
      SET ClientName = REPLACE(ClientName,'P/L','PTY LTD')
    WHERE ClientName like '%P/L%'

   UPDATE [cis_oamps].dbo.ods_clients_specific_oib
      SET ClientCode = REPLACE(ClientCode,'"',' ')
    WHERE ClientName like '"'

   UPDATE [cis_oamps].dbo.ods_clients_basic
      SET ClientCode = REPLACE(ClientCode,'"',' ')
         ,ClientName = REPLACE(ClientName,'"',' ')
         ,Address_Line_1 = REPLACE(Address_Line_1,'"',' ')
         ,Address_Line_2 = REPLACE(Address_Line_2,'"',' ')
         ,Address_Line_3 = REPLACE(Address_Line_3,'"',' ')
         ,Suburb = REPLACE(Suburb,'"',' ')
         ,Postcode = REPLACE(Postcode,'"',' ')
         ,Postal_Address_Line_1 = REPLACE(Postal_Address_Line_1,'"',' ')
         ,Postal_Address_Line_2 = REPLACE(Postal_Address_Line_2,'"',' ')
         ,Postal_Address_Line_3 = REPLACE(Postal_Address_Line_3,'"',' ')
         ,Addressee  = REPLACE(Addressee,'"',' ')
         ,Salutation = REPLACE(Salutation,'"',' ')
         ,ClientExecutiveCode = REPLACE(ClientExecutiveCode,'"',' ')
         ,Postal_Suburb = REPLACE(Postal_Suburb,'"',' ')
         ,Phone = REPLACE(Phone,'"',' ')
         ,Fax = REPLACE(Fax,'"',' ')
         ,Mobile = REPLACE(Mobile,'"',' ')
         ,Email = REPLACE(Email,'"',' ')
         ,Contact_Comments = REPLACE(Contact_Comments,'"',' ')
         ,Operation = REPLACE(Operation,'"',' ')
         ,Association_Code = REPLACE(Association_Code,'"',' ')

/*
   UPDATE [cis_oamps].dbo.ods_clients_basic
      SET ClientCode = REPLACE(ClientCode,char(13),' ')
         ,ClientName = REPLACE(ClientName,char(13),' ')
         ,Address_Line_1 = REPLACE(Address_Line_1,char(13),' ')
         ,Address_Line_2 = REPLACE(Address_Line_2,char(13),' ')
         ,Address_Line_3 = REPLACE(Address_Line_3,char(13),' ')
         ,Suburb = REPLACE(Suburb,char(13),' ')
         ,Postcode = REPLACE(Postcode,char(13),' ')
         ,Postal_Address_Line_1 = REPLACE(Postal_Address_Line_1,char(13),' ')
         ,Postal_Address_Line_2 = REPLACE(Postal_Address_Line_2,char(13),' ')
         ,Postal_Address_Line_3 = REPLACE(Postal_Address_Line_3,char(13),' ')
         ,Addressee  = REPLACE(Addressee,char(13),' ')
         ,Salutation = REPLACE(Salutation,char(13),' ')
         ,ClientExecutiveCode = REPLACE(ClientExecutiveCode,char(13),' ')
         ,Postal_Suburb = REPLACE(Postal_Suburb,char(13),' ')
         ,Phone = REPLACE(Phone,char(13),' ')
         ,Fax = REPLACE(Fax,char(13),' ')
         ,Mobile = REPLACE(Mobile,char(13),' ')
         ,Email = REPLACE(Email,char(13),' ')
         ,Contact_Comments = REPLACE(Contact_Comments,char(13),' ')
         ,Operation = REPLACE(Operation,char(13),' ')
         ,Association_Code = REPLACE(Association_Code,char(13),' ')

   UPDATE [cis_oamps].dbo.ods_clients_basic
      SET ClientCode = REPLACE(ClientCode,char(10),' ')
         ,ClientName = REPLACE(ClientName,char(10),' ')
         ,Address_Line_1 = REPLACE(Address_Line_1,char(10),' ')
         ,Address_Line_2 = REPLACE(Address_Line_2,char(10),' ')
         ,Address_Line_3 = REPLACE(Address_Line_3,char(10),' ')
         ,Suburb = REPLACE(Suburb,char(10),' ')
         ,Postcode = REPLACE(Postcode,char(10),' ')
         ,Postal_Address_Line_1 = REPLACE(Postal_Address_Line_1,char(10),' ')
         ,Postal_Address_Line_2 = REPLACE(Postal_Address_Line_2,char(10),' ')
         ,Postal_Address_Line_3 = REPLACE(Postal_Address_Line_3,char(10),' ')
         ,Addressee  = REPLACE(Addressee,char(10),' ')
         ,Salutation = REPLACE(Salutation,char(10),' ')
         ,ClientExecutiveCode = REPLACE(ClientExecutiveCode,char(10),' ')
         ,Postal_Suburb = REPLACE(Postal_Suburb,char(10),' ')
         ,Phone = REPLACE(Phone,char(10),' ')
         ,Fax = REPLACE(Fax,char(10),' ')
         ,Mobile = REPLACE(Mobile,char(10),' ')
         ,Email = REPLACE(Email,char(10),' ')
         ,Contact_Comments = REPLACE(Contact_Comments,char(10),' ')
         ,Operation = REPLACE(Operation,char(10),' ')
         ,Association_Code = REPLACE(Association_Code,char(10),' ')
*/

   UPDATE [cis_oamps].dbo.ods_clients_basic
   SET	 ClientCode				= replace(ClientCode,char(13)+char(10),' ')
		,ClientName				= replace(ClientName,char(13)+char(10),' ')
		,Address_Line_1			= replace(Address_Line_1,char(13)+char(10),' ')
		,Address_Line_2			= replace(Address_Line_2,char(13)+char(10),' ')
		,Address_Line_3			= replace(Address_Line_3,char(13)+char(10),' ')
		,Suburb					= replace(Suburb,char(13)+char(10),' ')
		,Postcode				= replace(Postcode,char(13)+char(10),' ')
		,Postal_Address_Line_1	= replace(Postal_Address_Line_1,char(13)+char(10),' ')
		,Postal_Address_Line_2	= replace(Postal_Address_Line_2,char(13)+char(10),' ')
		,Postal_Address_Line_3	= replace(Postal_Address_Line_3,char(13)+char(10),' ')
		,Postal_Suburb			= replace(Postal_Suburb,char(13)+char(10),' ')
		,Addressee				= replace(Addressee,char(13)+char(10),' ')
		,Salutation				= replace(Salutation,char(13)+char(10),' ')
		,Gender					= replace(Gender,char(13)+char(10),' ')
		,ClientExecutiveCode	= replace(ClientExecutiveCode,char(13)+char(10),' ')
		,Phone					= replace(Phone,char(13)+char(10),' ')
		,Fax					= replace(Fax,char(13)+char(10),' ')
		,Mobile					= replace(Mobile,char(13)+char(10),' ')
		,Email					= replace(Email,char(13)+char(10),' ')
		,ABN					= replace(ABN,char(13)+char(10),' ')
		,Retail_Wholesale		= replace(Retail_Wholesale,char(13)+char(10),' ')
		,Contact_Method			= replace(Contact_Method,char(13)+char(10),' ')
		,Contact_Preference		= replace(Contact_Preference,char(13)+char(10),' ')
		,Contact_Comments		= replace(Contact_Comments,char(13)+char(10),' ')
		,Operation				= replace(Operation,char(13)+char(10),' ')
		,Association_Code		= replace(Association_Code,char(13)+char(10),' ')
	WHERE
		charindex(char(13)+char(10),ClientCode)				>0
	OR	charindex(char(13)+char(10),ClientName)				>0
	OR	charindex(char(13)+char(10),Address_Line_1)			>0
	OR	charindex(char(13)+char(10),Address_Line_2)			>0
	OR	charindex(char(13)+char(10),Address_Line_3)			>0
	OR	charindex(char(13)+char(10),Suburb)					>0
	OR	charindex(char(13)+char(10),Postcode)				>0
	OR	charindex(char(13)+char(10),Postal_Address_Line_1)	>0
	OR	charindex(char(13)+char(10),Postal_Address_Line_2)	>0
	OR	charindex(char(13)+char(10),Postal_Address_Line_3)	>0
	OR	charindex(char(13)+char(10),Postal_Suburb)			>0
	OR	charindex(char(13)+char(10),Addressee)				>0
	OR	charindex(char(13)+char(10),Salutation)				>0
	OR	charindex(char(13)+char(10),Gender)					>0
	OR	charindex(char(13)+char(10),ClientExecutiveCode)	>0
	OR	charindex(char(13)+char(10),Phone)					>0
	OR	charindex(char(13)+char(10),Fax)					>0
	OR	charindex(char(13)+char(10),Mobile)					>0
	OR	charindex(char(13)+char(10),Email)					>0
	OR	charindex(char(13)+char(10),ABN)					>0
	OR	charindex(char(13)+char(10),Retail_Wholesale)		>0
	OR	charindex(char(13)+char(10),Contact_Method)			>0
	OR	charindex(char(13)+char(10),Contact_Preference)		>0
	OR	charindex(char(13)+char(10),Contact_Comments)		>0
	OR	charindex(char(13)+char(10),Operation)				>0
	OR	charindex(char(13)+char(10),Association_Code)		>0


   UPDATE [cis_oamps].dbo.ods_clients_basic
      SET ClientCode = REPLACE(ClientCode,'|',' ')
         ,ClientName = REPLACE(ClientName,'|',' ')
         ,Address_Line_1 = REPLACE(Address_Line_1,'|',' ')
         ,Address_Line_2 = REPLACE(Address_Line_2,'|',' ')
         ,Address_Line_3 = REPLACE(Address_Line_3,'|',' ')
         ,Suburb = REPLACE(Suburb,'|',' ')
         ,Postcode = REPLACE(Postcode,'|',' ')
         ,Postal_Address_Line_1 = REPLACE(Postal_Address_Line_1,'|',' ')
         ,Postal_Address_Line_2 = REPLACE(Postal_Address_Line_2,'|',' ')
         ,Postal_Address_Line_3 = REPLACE(Postal_Address_Line_3,'|',' ')
         ,Addressee  = REPLACE(Addressee,'|',' ')
         ,Salutation = REPLACE(Salutation,'|',' ')
         ,ClientExecutiveCode = REPLACE(ClientExecutiveCode,'|',' ')
         ,Postal_Suburb = REPLACE(Postal_Suburb,'|',' ')
         ,Phone = REPLACE(Phone,'|',' ')
         ,Fax = REPLACE(Fax,'|',' ')
         ,Mobile = REPLACE(Mobile,'|',' ')
         ,Email = REPLACE(Email,'|',' ')
         ,Contact_Comments = REPLACE(Contact_Comments,'|',' ')
         ,Operation = REPLACE(Operation,'|',' ')
         ,Association_Code = REPLACE(Association_Code,'|',' ')

   SELECT @misc_error = @@ERROR, @misc_log = @log_msg + 'Clean-up is completed'
   EXECUTE [cis_oamps].dbo.sp_utl_log_update @process_key,@misc_log


-- error check 
DECLARE @process_end datetime
SET @process_end = getdate()

IF    @del_error1 <> 0 OR @ins_error1 <> 0
   OR @del_error2 <> 0 OR @ins_error2 <> 0
   BEGIN     SET @log_msg = 'CIS - ODS Clients: ROLL BACK'
     EXECUTE [cis_oamps].dbo.sp_utl_log_end @job_id,@process_key,NULL,@process_end,@log_msg,'FAILED'  
     RAISERROR ('ROLL BACK: Failed to Delete / Insert', 16, 1)  
   END



























