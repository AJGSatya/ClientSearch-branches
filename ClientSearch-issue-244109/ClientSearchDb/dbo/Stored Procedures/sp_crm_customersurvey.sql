

CREATE PROCEDURE [dbo].[sp_crm_customersurvey]  
(  
	@process_key int
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
-- 16 Apr 2013 - Shiny Mukundan: new extract format and layout
-- 08 May 2013 - Swanson Phung: added pol.Broker_Code <> 'WALSH
-- 30 Jul 2013 - Shiny Mukundan: modified Claims conditions to include "Inactive clients" and "Claim not paid" AND added the Transaction type CASE
-- 01 Aug 2013 - Shiny Mukundan: added new field for   'Underwriter TLA'
-- 15 Aug 2013 - Swanson Phung: clientSegments from client table  
-- 11 Nov 2013 - Shiny Mukundan : Added condition pol.Branchcode <> 'OGA Noumea'
-- 16 May 2014 - Swanson Phung: Claim extract dates = renewal extract dates
-- 15 Sep 2014 - Swanson Phung: removed workers compensation claims
-- 14 Apr 2014 - Shiny Mukundan : removed unconnected clients where Executive is equal to "CEBU – Personal Lines Unconnected'

SET NOCOUNT ON -- >>>> this requires for IS Output <<<< 


-- Dates
declare  @ReportDateStart		date
		,@ReportDateEnd			date
		,@ReportDateStartRen	date
		,@ReportDateEndRen		date


	if DATEPART(weekday,getdate()) = 4 -- Wed = 4
		begin 
			set @ReportDateStart	= DATEADD(DAY,-5, getdate())-- Sales 
			set @ReportDateEnd		= DATEADD(DAY,-2, getdate())-- Sales 
			set @ReportDateStartRen	= DATEADD(DAY,-8, getdate())-- Renewals and Claims
			set @ReportDateEndRen	= DATEADD(DAY,-6, getdate())-- Renewals and Claims
		end
	else 
	if DATEPART(weekday,getdate()) = 2 -- Mon = 2
		begin 
			set @ReportDateStart	= DATEADD(DAY,-6, getdate())-- Sales
			set @ReportDateEnd		= DATEADD(DAY,-4, getdate())-- Sales
			set @ReportDateStartRen	= DATEADD(DAY,-10,getdate())-- Renewals and Claims
			set @ReportDateEndRen	= DATEADD(DAY,-7, getdate())-- Renewals and Claims
		end

/* 
-- >>> for debug only <<<<
			set @ReportDateStart	= DATEADD(DAY,-6, getdate()-1)-- Sales
			set @ReportDateEnd		= DATEADD(DAY,-4, getdate()-1)-- Sales
			set @ReportDateStartRen	= DATEADD(DAY,-10,getdate()-1)-- Renewals and Claims
			set @ReportDateEndRen	= DATEADD(DAY,-7, getdate()-1)-- Renewals and Claims
-- >>> for debug only <<<<
*/

DECLARE	 @JobDesc		varchar(200)
		,@StepDesc		varchar(200)
		,@StepCompleted varchar(200)
		,@ProcessEnd	datetime
		,@ErrMsg		varchar(4000)
		,@ErrSeverity	int
		,@CampaignType	varchar(200)

SET 	@JobDesc		= 'CRM Customer Survey'
SET		@CampaignType	= 'CustomerSurvey'


-- report

		SET		@StepDesc = 'Output' 
		--  CLAIMS DATA 
		SELECT	--TOP 10	
			 replace(cli.Email,',',' ')				as 'EmailAddress'
			,replace(cli.Salutation,',',' ')		as 'Salutation'
			,replace(cli.Mailing_Contact,',',' ')	as 'MailingContact'
			,(CASE WHEN cla.ClassCode in ('PLHG','PLHP','PLLL','PLPM')	then 'A&D Claims'
			       ELSE 'OAMPS Claims' end)         as 'TransactionType'
			,pol.Branchcode							as 'BranchCode'
			,substring(cli.ClientSegment,4,100)		as 'IncomeBand' 
			,replace(cla.ClassDesc,',',' ')			as 'PolicyType'
			,cli.ClientCode							as 'ClientNumber'
			,' '									as 'SiteID'   -- Blank Field
			,pol.RegionCode							as 'Region'
			,replace(cli.ClientName,',',' ')		as 'TradingName'
			,replace(exe.Executive_Name,',',' ')	as 'ExecutiveName'
			,clm.ClaimNo							as 'PolicyNo'
			,substring(isnull(clm.UnderwriterCode, pol.UnderwriterCode),patindex('%[_]%',isnull(clm.UnderwriterCode, pol.UnderwriterCode))+1,3)  as 'Underwriter TLA'
			,convert(varchar(10),clm.TransactionDate,103) as 'TransactionDate'
			,'NA'									as 'EffectiveDate'
		FROM
						(-- unique client code
						select	ClientCode, max(ClaimNo) as ClaimNo
						from	[dw_oamps].dbo.dds_fct_policyclaim
						where	[Status] = 'X' -- closed 
						and		TransactionDate between @ReportDateStartRen and @ReportDateEndRen
						and		datediff(day,DateNotified,TransactionDate) <= 365 -- 12 months
						and		ClaimNo is not null
						and		LastVersion = 1
						-- and		ClaimTotal <> 0  -- exclude NO-PAID Claims 
						group by ClientCode
						) cus
			inner join	[dw_oamps].dbo.dds_fct_policyclaim			clm on clm.ClaimNo			= cus.ClaimNo
			inner join	[dw_oamps].dbo.dds_fct_client				cli	on cli.ClientCode		= clm.ClientCode 
			inner join	[dw_oamps].dbo.dds_fct_policytransaction	pol	on pol.Ledger_Code		= clm.Ledger_Code and pol.TransactionNo = clm.TransactionNo
			inner join	[dw_oamps].dbo.dds_dim_executive			exe	on exe.Executive_Code	= clm.ClientExecutiveCode --pol.AccountExecutiveCode
			inner join	[dw_oamps].dbo.dds_dim_policyclass			cla on cla.classcode		= clm.classcode

		WHERE	
				clm.LastVersion = 1
		--AND		cli.ActiveClientInd = 'Y'									-- active clients
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
		AND		pol.Broker_Code <> 'WALSH'	
		AND		pol.Branchcode <> 'OGA Noumea'
		AND		cla.ClassDesc not like '%Workers Compensation%'
		AND		cla.ClassMajor not like '%Workers Compensation%'
		AND		exe.Executive_Code not like '%PLCEBU%'		--Unconnected personal lines

UNION  


		--  RENEWALS DATA 
		SELECT --TOP 10
			 replace(cli.Email,',',' ')				as 'EmailAddress'
			,replace(cli.Salutation,',',' ')		as 'Salutation'
			,replace(cli.Mailing_Contact,',',' ')	as 'MailingContact'
			,'Renewals'								as 'TransactionType'
			,pol.Branchcode							as 'BranchCode'
			,substring(cli.ClientSegment,4,100)		as 'IncomeBand' 
			,replace(cla.ClassDesc,',',' ')			as 'PolicyType'
			,cli.ClientCode							as 'ClientNumber'
			,' '									as 'SiteID'   -- Blank Field
			,pol.RegionCode							as 'Region'
			,replace(cli.ClientName,',',' ')		as 'TradingName'
			,replace(exe.Executive_Name,',',' ')	as 'ExecutiveName'
			,pol.policyno							as 'PolicyNo'
			,substring(pol.UnderwriterCode,patindex('%[_]%',pol.UnderwriterCode)+1,3)  as 'Underwriter TLA'
			,convert(varchar(10),pol.invoicedate,103)  as 'TransactionDate'
			,convert(varchar(10),pol.inceptiondate,103) as 'EffectiveDate'
		FROM
						(-- unique client code
						select	ClientCode, max(Ledger_Code+ '_'+TransactionNo) as LedgerCode_TransactionNo
						from	[dw_oamps].dbo.dds_fct_policytransaction
						where	TransactionType in ('Renewal','New business')
						and		MarketCode in ('R1','R2','Z1')
						and		inceptiondate between @ReportDateStartRen and @ReportDateEndRen
						and		Broker_Code <> 'WALSH'
						AND		Branchcode <> 'OGA Noumea'
						group by ClientCode
						) cus
			inner join	[dw_oamps].dbo.dds_fct_policytransaction	pol on pol.Ledger_Code+'_'+pol.TransactionNo = cus.LedgerCode_TransactionNo
			inner join	[dw_oamps].dbo.dds_fct_client				cli	on cli.ClientCode		= pol.ClientCode 
			inner join	[dw_oamps].dbo.dds_dim_executive			exe	on exe.Executive_Code	= pol.AccountExecutiveCode
			inner join	[dw_oamps].dbo.dds_dim_policyclass			cla on cla.classcode		= pol.classcode
		
		WHERE				
				cli.ActiveClientInd = 'Y'										-- active clients
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
		AND		exe.Executive_Code not like '%PLCEBU%'		--Unconnected personal lines


UNION	


		-- SALES DATA		
		SELECT --TOP 10
			 replace(cli.Email,',',' ')				as 'EmailAddress'
			,replace(cli.Salutation,',',' ')		as 'Salutation'
			,replace(cli.Mailing_Contact,',',' ')	as 'MailingContact'
			,'Sales'								as 'TransactionType'
			,pol.Branchcode							as 'BranchCode'
			,substring(cli.ClientSegment,4,100)		as 'IncomeBand' 
			,replace(cla.ClassDesc,',',' ')			as 'PolicyType'
			,cli.ClientCode							as 'ClientNumber'
			,' '									as 'SiteID'   -- Blank Field
			,pol.RegionCode							as 'Region'
			,replace(cli.ClientName,',',' ')		as 'TradingName'
			,replace(exe.Executive_Name,',',' ')	as 'ExecutiveName'
			,pol.policyno							as 'PolicyNo'
			,substring(pol.UnderwriterCode,patindex('%[_]%',pol.UnderwriterCode)+1,3)  as 'Underwriter TLA'
			,convert(varchar(10),pol.invoicedate,103)  as 'TransactionDate'
			,convert(varchar(10),pol.inceptiondate,103) as 'EffectiveDate'
		FROM
						(-- unique client code
						select	ClientCode, max(Ledger_Code+ '_'+TransactionNo) as LedgerCode_TransactionNo
						from	[dw_oamps].dbo.dds_fct_policytransaction
						where	TransactionType = 'New business'
						and		MarketCode in ('N1','N2','S2')
						and		invoicedate between @ReportDateStart and @ReportDateEnd
						and		Broker_Code <> 'WALSH'
						AND		Branchcode <> 'OGA Noumea'
						group by ClientCode
						) cus
			inner join	[dw_oamps].dbo.dds_fct_policytransaction	pol on pol.Ledger_Code+'_'+pol.TransactionNo = cus.LedgerCode_TransactionNo
			inner join	[dw_oamps].dbo.dds_fct_client				cli	on cli.ClientCode		= pol.ClientCode 
			inner join	[dw_oamps].dbo.dds_dim_executive			exe	on exe.Executive_Code	= pol.AccountExecutiveCode
			inner join	[dw_oamps].dbo.dds_dim_policyclass			cla on cla.classcode		= pol.classcode
		WHERE	
				cli.ActiveClientInd = 'Y'										-- active clients
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
		AND		exe.Executive_Code not like '%PLCEBU%'		--Unconnected personal lines

		SELECT	@StepCompleted	=@JobDesc+' : '+@StepDesc+' '+convert(varchar,@@ROWCOUNT)+' Rows'
		EXECUTE sp_utl_log_update @process_key,@StepCompleted

