

/****** Object:  Stored Procedure dbo.sp_report_ledger_list_all    Script Date: 23/12/2004 11:05:03 AM ******/


/****** Object:  Stored Procedure dbo.sp_report_ledger_list_all    Script Date: 14/12/2004 3:10:00 PM ******/




CREATE     procedure sp_report_ledger_list_all AS

-- Nov 16 2004: Swanson Phung - initial Release

SELECT  '(all)' as ledgercode

 UNION

SELECT ledgercode FROM  [cis_OAMPS].dbo.ods_oamps_physicalbranch
GROUP BY  ledgercode 
ORDER BY ledgercode



