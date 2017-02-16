


CREATE      PROCEDURE [dbo].[sp_crm_renewal_clients]
AS 

-- 11 Dec 2008 - Swanson Phung : initial release
-- 22 Dec 2008 - Swanson Phung : modified to use cds_oamps_clients table and redo output file
-- 16 feb 2008 - Swanson Phung : added postcode, start and end dates
-- 22 Sep 2010 - Swanson Phung : ensure crm_campaign_history of CampaignType = 'Mail' 

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE  @process_key int,@job_id int,@processed_date datetime,@NULL_VL varchar(100)
		,@del_error int,@del_log varchar(500)
		,@upd_error int,@upd_log varchar(500)
		,@ins_error int,@ins_log varchar(500)
		,@sel_error int,@sel_log varchar(500)
		,@ods_total int,@loaded_total int,@log_msg varchar(500),@overall_error varchar(100)
		,@startdate varchar(20),@enddate varchar(20),@NoOfMonth int

-- Get Process Key.
SET		@job_id =  201
EXEC	sp_utl_log_getkey @job_id , @process_key OUTPUT
SET		@process_key = @process_key

IF		@process_key is NULL 
	BEGIN
		RAISERROR ('FAILED to Get Process_Key', 16, 1)  
		RETURN
	END
ELSE
	EXEC sp_utl_log_update  @process_key,  'Process started '


-- 1st run ONLY
SET	@startdate		= '01 Mar 2009'
SET @enddate		= '30 Jun 2009'


--SET	@NoOfMonth		= 4
--SET	@startdate		= dateadd(mm,datediff(mm,0,dateadd(mm,@NoOfMonth,getdate())),0)
--SET @enddate		= dateadd(dd,-1,dateadd(mm,datediff(mm,0,dateadd(mm,@NoOfMonth,getdate()))+1,0))
SET @processed_date = getdate()
SET @NULL_VL		= '!@#$%' 
SET @log_msg		= 'CRM Renewal Clients: ' + convert(varchar,datepart(month,@startdate)) + '/' + convert(varchar,datepart(year,@startdate)) + ' - ' 


BEGIN TRAN D1
		-- insert
		INSERT INTO dbo.crm_campaign_history
			(
			 ClientCode
			,CampaignType
			,CampaignDate
			,DateStart
			,DateEnd
			,Process_Key
			)	
		SELECT distinct
			 a.ClientCode
			,'Mail'			as CampaignType
			,getdate()		as CampaignDate
			,@startdate		as DateStart
			,@enddate		as DateEnd
			,@process_key	as Process_Key

		FROM
						[dw_oamps].dbo.dds_fct_policytransaction	a

		WHERE
				a.last_transaction_ind = 1
		and    (a.renewal_type not in ('SHTA', 'SHT') or a.renewal_type is null)
		and		a.Expirydate	between @startdate and @enddate
		and		rtrim(ltrim(a.TransactionType)) <> 'Cancellation'
		and		a.Policy_Status not in ('C', 'L')
		and		not exists
					( 
					select	1 -- list of clientcode
					from				[cis_oamps].dbo.crm_campaign_history	b
							inner join 	[cis_oamps].dbo.utl_process	c on c.Process_Key = b.Process_Key
					where	c.Process_Job_ID = @job_id									-- @job_id = 201 
					and		b.CampaignDate >= dateadd(mm,datediff(mm,0,getdate())-11,0) -- 1st day of 11 mths ago
					and		b.CampaignType = 'Mail'
					and		b.ClientCode = a.ClientCode
					)

		SELECT @ins_error = @@ERROR, @ins_log = @log_msg + convert(varchar, @@ROWCOUNT) + ' Rows INSERTED'
		EXECUTE sp_utl_log_update @process_key, @ins_log


		-- update
		UPDATE	dbo.crm_campaign_history

		SET	 
			 BranchCode			= b.BranchCode
			,ClientName			= b.ClientName
			,Address_Line_1		= b.Address_Line_1
			,Address_Line_2		= b.Address_Line_2
			,Address_Line_3		= b.Address_Line_3
			,Postcode			= b.Postcode
			,Addressee			= b.Addressee
			,Salutation			= b.Salutation
			,Phone				= b.Phone
			,Fax				= b.Fax
			,Mobile				= b.Mobile
			,Contact_Method		= b.Contact_Method
			,Contact_Preference	= b.Contact_Preference
			,Contact_Comments	= b.Contact_Comments
			,UID				= b.UID

		FROM
							[cis_oamps].dbo.crm_campaign_history	a
			left outer join	[cis_oamps].dbo.cds_oamps_clients		b on b.ClientCode = a.ClientCode
		WHERE
				a.Process_Key	= @process_key
		AND		a.CampaignType	= 'Mail'

		SELECT @upd_error = @@ERROR, @upd_log = @log_msg + convert(varchar, @@ROWCOUNT) + ' Rows UPDATED'
		EXECUTE sp_utl_log_update @process_key, @upd_log


-- transaction check
IF		@ins_error = 0
	AND	@upd_error = 0	

	BEGIN -- success
		COMMIT TRAN D1

		-- output
		SELECT	-- header
				1	as t1
				,'Branch,ClientCode,ClientName,Address_Line_1,Address_Line_2,Address_Line_3,Postcode,Addressee,Salutation,Phone,Fax,Mobile,Contact_Method,Contact_Preference,Contact_Comments'
					as body
				,'' as postcode

		UNION 

		SELECT	-- data
				2	as t1
				,    '"'+a.Branchcode+'"'
					+',"'+a.ClientCode COLLATE Latin1_General_CS_AI+'"'
					+',"'+a.ClientName+'"'
					+',"'+a.Address_Line_1+'"'
					+',"'+a.Address_Line_2+'"'
					+',"'+a.Address_Line_3+'"'
					+',"'+a.Postcode+'"'
					+',"'+a.Addressee+'"'
					+',"'+a.Salutation+'"'
					+',"'+a.Phone+'"'
					+',"'+a.Fax+'"'
					+',"'+a.Mobile+'"'
					+',"'+a.Contact_Method+'"'
					+',"'+a.Contact_Preference+'"'
					+',"'+a.Contact_Comments+'"'
					as body
				,a.Postcode as postcode

		FROM
				[cis_oamps].dbo.crm_campaign_history a
		WHERE
				a.Process_Key					= @process_key
		AND		a.CampaignType					= 'Mail'
		AND		a.ClientName					is not null
		AND		len(rtrim(ltrim(a.ClientName))) <> 0
		AND
				EXISTS
				( -- list of clientcode with no duplicated address 
				select	1
				from 	( 
						select	max(clientcode) as clientcode
						from	dbo.crm_campaign_history
						WHERE	Process_Key		= @process_key
						AND		CampaignType	= 'Mail'
						group by UID
						) b 
				where
						b.ClientCode			= a.ClientCode
				)
		ORDER BY 3


		SELECT @sel_error = @@ERROR, @sel_log = @log_msg + convert(varchar, @@ROWCOUNT) + ' Rows OUTPUT'
		EXECUTE sp_utl_log_update @process_key, @sel_log

		-- log
		SET @log_msg = @log_msg + 'Completed. '
		EXECUTE sp_utl_log_update @process_key, @log_msg

	END -- success
ELSE
	BEGIN -- error
		ROLLBACK TRAN D1
		SET @overall_error = 'YES'
		IF @ins_error <> 0
			BEGIN
				SET @log_msg = @log_msg + 'Failed to INSERT, error is ' + convert(varchar(100),@ins_error)
				EXECUTE sp_utl_log_update @process_key, @log_msg
			END
		IF @upd_error <> 0
			BEGIN
				SET @log_msg = @log_msg + 'Failed to UPDATE, error is ' + convert(varchar(100),@upd_error)
				EXECUTE sp_utl_log_update @process_key, @log_msg
			END
	END -- error



-- overall check 
DECLARE @end_datetime datetime
SET @end_datetime = getdate()

IF	@overall_error = 'YES'
	BEGIN		EXECUTE sp_utl_log_end @job_id,@process_key,NULL,@end_datetime,'LOADING ERROR', 'FAILED'  
		RAISERROR ('LOADING ERROR: Check system log for details ', 16, 1)  
	END
ELSE
	BEGIN
		EXECUTE sp_utl_log_end @job_id,@process_key,NULL,@end_datetime,'CRM Renewal Clients - Process Ended','DONE'  
	END
