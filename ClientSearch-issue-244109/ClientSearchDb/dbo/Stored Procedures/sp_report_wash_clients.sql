
CREATE PROCEDURE [dbo].[sp_report_wash_clients]
(
	 @confirmation		varchar(10) 
	
) AS

------------------------------------------------------------------
-- 24 Mar 2015  - Shiny Mukundan: initial release
------------------------------------------------------------------

Declare  @SSISPath		varchar(100)
		,@SSISName		varchar(100)
		,@SSISStatus	varchar(10)
		,@cmd			varchar(2000)
		,@param			varchar(100)



select	@SSISPath	= Value1	from dbo.utl_system_option where Type = 'SSIS_Path_DW'		
select	@SSISName	= 'CIS_Client_Washing.dtsx'
--select	@param		= ' /SET "\Package.Variables[User::ReportingMonth].Properties[Value]";'+'"'+@ReportingMonth+'"'

 
set		@cmd		= 'DTExec /F "' + @SSISPath  + @SSISName+'"' --+ @param
print	'' +@cmd

-- main
if lower(@confirmation)		= 'ok'
--and @SSISStatus				= 'FREE'
--and isdate(@ReportingMonth)	= 1

	begin
	 
		
		select 'OK' as result,'Process is successfully ended (email sent)' as resultmsg
		exec master..xp_cmdshell @cmd 
		
		

		-- SSIS FREE
		/*update dbo.utl_system_option 
		set Value2 = 'FREE'
		where Type = 'SSIS_DWPolicyTransaction'
		
		-- reset @ReportingMonth
		update dbo.utl_system_option 
		set Value1 = ''
		where Type = 'INCOMEPOSTING-BA2F1-ReportingMonth'*/

	end 

else 

		select 'NOT-OK' as result, 'Process is UN-SUCCESSFULLY ended' as resultmsg