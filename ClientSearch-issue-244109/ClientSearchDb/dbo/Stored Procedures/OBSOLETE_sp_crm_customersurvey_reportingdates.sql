
CREATE PROCEDURE [dbo].[OBSOLETE_sp_crm_customersurvey_reportingdates]
(
	 @month_start			datetime	OUTPUT
	,@month_end				datetime	OUTPUT
	,@claims_month_start	datetime	OUTPUT
	,@claims_month_end		datetime	OUTPUT
	,@claims_required		varchar(10)	OUTPUT
	,@Overwrite_Month_Start	varchar(50)	OUTPUT
	,@Overwrite_Month_End	varchar(50)	OUTPUT
) AS

-- 20 Sep 2010 - Swanson Phung: initial release - migrated from DI and added crm_campaign_history
-- 10 Nov 2010 - Swanson Phung: claims extract will be same as Sales and Renewals

-- Reporting dates
declare	 @OverwriteMonthStart	varchar(50)
		,@OverwriteMonthEnd		varchar(50)
		,@MonthStart			datetime
		,@MonthEnd				datetime
		,@1mthB4MonthStart		datetime
		,@ClaimsMonthStart		datetime
		,@ClaimsMonthEnd		datetime
		,@ClaimsRequired		varchar(10)
		
set 	@OverwriteMonthStart	= (select Value1 from dbo.utl_system_option where Type ='CRM-CUSTOMERSURVEY-ExtractMonthStart')
set 	@OverwriteMonthEnd		= (select Value1 from dbo.utl_system_option where Type ='CRM-CUSTOMERSURVEY-ExtractMonthEnd')
--select @OverwriteMonthStart,@OverwriteMonthEnd


-- Sales and Renewals
if	@OverwriteMonthStart	<> 'NO' and isdate(@OverwriteMonthStart)	= 1
  begin	-- Overwrite - MonthStart and Month
	set @MonthStart			=(select              dateadd(mm,datediff(mm,0,@OverwriteMonthStart),0)		)
	set @MonthEnd			=(select dateadd(d,-1,dateadd(mm,datediff(mm,0,@OverwriteMonthStart)+1,0))		)
  end	-- Overwrite
else
  begin	-- default
		-- for sales and renewals - previous month
	set @MonthStart			=(select              dateadd(mm,datediff(mm,0,getdate())-1,0)		)
	set @MonthEnd			=(select dateadd(d,-1,dateadd(mm,datediff(mm,0,getdate()),0))		)
  end	-- default


-- Claims : will be same as Sales and Renewals

	set @ClaimsMonthStart	= @MonthStart
	set @ClaimsMonthEnd		= @MonthEnd
	set @ClaimsRequired		= 'YES'

/*
if	@OverwriteMonthStart	<> 'NO' and isdate(@OverwriteMonthStart)	= 1
and @OverwriteMonthEnd		<> 'NO' and isdate(@OverwriteMonthEnd)		= 1
and convert(smalldatetime,@OverwriteMonthStart) <= convert(smalldatetime,@OverwriteMonthEnd)
  begin	-- Overwrite - MonthStart and Month
	set @ClaimsRequired		= 'YES'
	set @ClaimsMonthStart	=(select              dateadd(mm,datediff(mm,0,@OverwriteMonthStart),0)	)
	set @ClaimsMonthEnd		=(select dateadd(d,-1,dateadd(mm,datediff(mm,0,@OverwriteMonthEnd)+1,0))	)
  end	-- Overwrite
else
  begin	-- default
	set @ClaimsMonthStart	=(select			  dateadd(qq,datediff(qq,0,getdate())-1,0)		)
	set @ClaimsMonthEnd		=(select dateadd(d,-1,dateadd(qq,datediff(qq,0,getdate()),0))		)

	-- claims default is required in Jan,Apr,jul,Nov ONLY
	if	datepart(m, getdate() ) = 1
	or	datepart(m, getdate() ) = 4
	or	datepart(m, getdate() ) = 7
	or	datepart(m, getdate() ) = 10
		set @ClaimsRequired		= 'YES'
	else 
		set @ClaimsRequired		= 'NO'

  end	-- default
*/

-- outputs
select
	 @MonthStart
	,@MonthEnd
	,@ClaimsMonthStart
	,@ClaimsMonthEnd
	,@ClaimsRequired
	,@OverwriteMonthStart
	,@OverwriteMonthEnd



