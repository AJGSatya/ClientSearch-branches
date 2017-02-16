
CREATE PROCEDURE [dbo].[sp_crm_customersurvey_claims]  
(  
	@process_key					int
) AS
-- 20 Sep 2010 - Swanson Phung: initial release - migrated from DI and added crm_campaign_history
-- 22 Oct 2010 - Swanson Phung: multi-version PolicyClaim added LastVersion = 1
-- 07 Oct 2010 - Swanson Phung: added LastVersion = 1 for 2nd policyclaim table
-- 09 Aug 2011 - Swanson Phung: new email output layout
-- 09 Aug 2011 - Swanson Phung: excluded NO-PAID Claims
-- 30 Aug 2011 - Swanson Phung: excluded deceased clients
-- 03 Jan 2012 - Swanson Phung: modified extract conditions and add Mailing_Contact
-- 06 Jan 2012 - Swanson Phung: added Contact_Preference
-- 26 Mar 2012 - Swanson Phung: excluded regioncode and clm.ClientExecutiveCode
-- 28 Feb 2013 - Swanson Phung: new extracts

SET NOCOUNT ON -- >>>> this requires for IS Output <<<< 


-- Dates
declare  @ReportDateStart	date
		,@ReportDateEnd		date

	if DATEPART(weekday,getdate()) = 4 -- Wed = 4
		begin 
			set @ReportDateStart	= DATEADD(DAY,-5, getdate())-- Sales and Claims
			set @ReportDateEnd		= DATEADD(DAY,-2, getdate())-- Sales and Claims
--			set @ReportDateStart	= DATEADD(DAY,-8, getdate())-- Renewals
--			set @ReportDateEnd		= DATEADD(DAY,-6, getdate())-- Renewals
		end
	else 
	if DATEPART(weekday,getdate()) = 2 -- Mon = 2
		begin 
			set @ReportDateStart	= DATEADD(DAY,-6, getdate())-- Sales and Claims
			set @ReportDateEnd		= DATEADD(DAY,-4, getdate())-- Sales and Claims
--			set @ReportDateStart	= DATEADD(DAY,-10,getdate())-- Renewals
--			set @ReportDateEnd		= DATEADD(DAY,-7, getdate())-- Renewals
		end



DECLARE	 @JobDesc		varchar(200)
		,@StepDesc		varchar(200)
		,@StepCompleted varchar(200)
		,@ProcessEnd	datetime
		,@ErrMsg		varchar(4000)
		,@ErrSeverity	int
		,@CampaignType	varchar(200)

SET 	@JobDesc		= 'CRM Customer Survey Claims'
SET		@CampaignType	= 'CustomerSurvey - Claims'



		-- CLAIMS

		SET		@StepDesc = 'Output' 
		SELECT	--TOP 1000 
			 replace(cli.Email,',',' ')				as 'EmailAddress'
			,replace(cli.ClientName,',',' ')		as 'TradingName'
			,replace(cli.Salutation,',',' ')		as 'Salutation'
			,replace(cli.Mailing_Contact,',',' ')	as 'MailingContact'
			,cli.ClientCode							as 'ClientNumber'
			,replace(cla.ClassDesc,',',' ')			as 'PolicyType'
			,replace(exe.Executive_Name,',',' ')	as 'ExecutiveName'
			,pol.Branchcode							as 'BranchCode'
			,pol.RegionCode							as 'Region'
			,(case	when	amt.NPLClientInd = 'Y'																then 'Personal Lines Only'
					when	amt.amountgained <1001	and amt.NPLClientInd = 'N'									then 'Micro SME Clients < $1K' 
					when	amt.amountgained >1000	and amt.amountgained <5001	and amt.NPLClientInd = 'N'		then 'Small Commercial Clients $1K - $5K' 
					when	amt.amountgained >5000	and amt.amountgained <10001	and amt.NPLClientInd = 'N'		then 'Medium Commercial Clients $5K - $10K'
					when	amt.amountgained >10000	and amt.amountgained <20001	and amt.NPLClientInd = 'N'		then 'Large Commercial Clients $10K - $20K'
					when	amt.amountgained >20000 and amt.NPLClientInd = 'N'									then 'Corporate Clients $20K+'
					else '00 Unknown' end)			as 'IncomeBand'
			,convert(varchar(10),clm.TransactionDate,103) as 'ClaimClosureDate'
			,clm.ClaimNo							as 'ClaimNumber'
			,cli.Contact_Preference					as 'ContactPreference'

		FROM
						(-- unique client code
						select	ClientCode, max(ClaimNo) as ClaimNo
						from	[dw_oamps].dbo.dds_fct_policyclaim
						where	[Status] = 'X' -- closed 
						and		TransactionDate between @ReportDateStart and @ReportDateEnd
						and		datediff(day,DateNotified,TransactionDate) <= 365 -- 12 months
						and		ClaimNo is not null
						and		LastVersion = 1
						and		ClaimTotal <> 0 -- exclude NO-PAID Claims
						group by ClientCode
						) cus
			inner join	[dw_oamps].dbo.dds_fct_policyclaim			clm on clm.ClaimNo			= cus.ClaimNo
			inner join	[dw_oamps].dbo.dds_fct_client				cli	on cli.ClientCode		= clm.ClientCode 
			inner join	[dw_oamps].dbo.dds_fct_policytransaction	pol	on pol.Ledger_Code		= clm.Ledger_Code and pol.TransactionNo = clm.TransactionNo
			inner join	[dw_oamps].dbo.dds_dim_executive			exe	on exe.Executive_Code	= clm.ClientExecutiveCode --pol.AccountExecutiveCode
			inner join	[dw_oamps].dbo.dds_dim_policyclass			cla on cla.classcode		= clm.classcode
			inner join	( -- list of latest amountgained
						select a.ClientCode,a.reporting_year,a.NPLClientInd,max(a.amountgained) as amountgained
						from		[dw_oamps].dbo.dds_summ_clientanalysisbyfinancialyear a 
						inner join (
									select ClientCode,MAX(reporting_year) as reporting_year
									from [dw_oamps].dbo.dds_summ_clientanalysisbyfinancialyear
									group by ClientCode
									) b on b.ClientCode = a.ClientCode and b.reporting_year = a.reporting_year
						group by	a.ClientCode,a.reporting_year,a.NPLClientInd
						) amt on amt.clientcode = pol.ClientCode

		WHERE	
				clm.LastVersion = 1
		AND		cli.ActiveClientInd = 'Y'										-- active clients
		AND		cli.Incomeband_past12mts not in ('0. No-Transaction','1. <=0')
		AND		isnull(cli.VIP,'') not like '%Staff%'
		AND		cli.ClientName not like '%deceased%'							-- excl. deceased clients
		AND		upper(cli.Contact_Preference) not like '%No contact%'			-- excl. Contact_Preference = No contact
		AND		len(cli.Email) > 10												-- email > 10 chars	
		AND		PATINDEX('%@%',cli.Email)> 0									-- email with @ char	
		AND		upper(cli.Email) <> 'NA'
		AND		upper(cli.Email) <> 'NULL'
		AND		upper(cli.Email) not like '%NOTAPPLICABLE%'
		AND		upper(cli.Email) not like '%NA@NA%'
		AND		upper(cli.Email) not like '%NA.COM%'
		AND		upper(cli.Email) not like '%NOEMAIL%'
		AND		upper(cli.Email) not like '%NULL@NULL%'
		AND		upper(cli.Email) not like '%@oamps.com%'


		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted


