

CREATE      PROCEDURE [dbo].[sp_report_invalid_addr] (@ledgercode varchar(100)) AS 
-- Nov 16 2004: Swanson Phung - initial Release
-- Mar 29, 2005: Felix Huang - changed the display order to physical branch and client executive
-- Ded 19, 2007: Felix Huang - excluded non ba tables
-- Feb 25, 2010: Felix Huang - fixed bug in (all) option and limited to active clients only
-- Aug 09 2010: Swanson Phung - removed [dw_oamps] components


IF @ledgercode='(all)'

  select (case PCStatus 
        when 01 then 'No address lines input'
        when 02 then 'Town not Matched'
        when 03 then 'Street not Matched'
        when 04 then 'Premise not Found'
        when 05 then 'Duplicate Premise Found'
        when 07 then 'BFPO Address'
        when 08 then 'Foreign Address'
        when 10 then 'Irish Address'
        when 21 then 'Unmatched at Secondary Level'
        when 22 then 'Premise Range not Matched'
        when 32 then 'Premise Range is Contiguous'
        when 99 then 'No Work Done'
        else 'Unknown' end ) as PCStatus_desc
        ,cli.* 
  from  [cis_OAMPS].dbo.ods_clients_cleansed cli
       ,(select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_oib
         where Last_Transaction_Date > dateadd(year,-2,getdate())
      /*   union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_ahw
         where Last_Transaction_Date > dateadd(year,-2,getdate())
         union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_atura
         where Last_Transaction_Date > dateadd(year,-2,getdate())
         union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_vigil
         where Last_Transaction_Date > dateadd(year,-2,getdate())
         union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_yig
         where Last_Transaction_Date > dateadd(year,-2,getdate()) */) spc
  where cli.ClientCode= spc.ClientCode
    and cli.PCStatus not in ('00','PCStatus')
    and len(ltrim(Address_Line_1))<>0 
   -- and Address_Line_1 not like 'C/%'
   -- and Address_Line_1 not like 'PO BOX%'
--	and exists (select 1 from dw_oamps.dbo.dds_summ_clientanalysisbyfinancialmonth dsc where dsc.clientcode = cli.clientcode and reporting_month = dw_oamps.dbo.fun_bamonth (getdate()) and clientflag = 'active')
	and exists	(
				select	1 
				from	dbo.cds_oamps_clients coc
				where	coc.clientcode = cli.clientcode
				and		coc.ActiveClientInd = 'Y'
				)
  --  and ledgercode = @ledgercode
  --order by cli.SystemCode,cli.LedgerCode,cli.PCStatus

  order by cli.branchCode,cli.clientexecutiveCode

ELSE 

  select (case PCStatus 
        when 01 then 'No address lines input'
        when 02 then 'Town not Matched'
        when 03 then 'Street not Matched'
        when 04 then 'Premise not Found'
        when 05 then 'Duplicate Premise Found'
        when 07 then 'BFPO Address'
        when 08 then 'Foreign Address'
        when 10 then 'Irish Address'
        when 21 then 'Unmatched at Secondary Level'
        when 22 then 'Premise Range not Matched'
        when 32 then 'Premise Range is Contiguous'
        when 99 then 'No Work Done'
        else 'Unknown' end ) as PCStatus_desc
        ,cli.* 
  from  [cis_OAMPS].dbo.ods_clients_cleansed cli
       ,(select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_oib
         where Last_Transaction_Date > dateadd(year,-2,getdate())
       /*  union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_ahw
         where Last_Transaction_Date > dateadd(year,-2,getdate())
         union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_atura
         where Last_Transaction_Date > dateadd(year,-2,getdate())
         union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_vigil
         where Last_Transaction_Date > dateadd(year,-2,getdate())
         union
         select clientcode,Last_Transaction_Date
          from [cis_OAMPS].dbo.ods_clients_specific_yig
         where Last_Transaction_Date > dateadd(year,-2,getdate())*/ ) spc
  where cli.ClientCode= spc.ClientCode
    and cli.PCStatus not in ('00','PCStatus')
    and len(ltrim(Address_Line_1))<>0 
   -- and Address_Line_1 not like 'C/%'
   -- and Address_Line_1 not like 'PO BOX%'
    and ledgercode = @ledgercode
--	and exists (select 1 from dw_oamps.dbo.dds_summ_clientanalysisbyfinancialmonth dsc where dsc.clientcode = cli.clientcode and reporting_month = dw_oamps.dbo.fun_bamonth (getdate()) and clientflag = 'active')
	and exists	(
				select	1 
				from	dbo.cds_oamps_clients coc
				where	coc.clientcode = cli.clientcode
				and		coc.ActiveClientInd = 'Y'
				)

  order by cli.branchCode,cli.clientexecutiveCode






