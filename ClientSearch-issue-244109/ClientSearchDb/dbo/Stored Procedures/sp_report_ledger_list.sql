

/****** Object:  Stored Procedure dbo.sp_report_ledger_list    Script Date: 23/12/2004 11:05:03 AM ******/



/****** Object:  Stored Procedure dbo.sp_report_ledger_list    Script Date: 14/12/2004 3:09:59 PM ******/



CREATE     procedure sp_report_ledger_list (@unitcode varchar(20)) AS

-- Nov 16 2004: Swanson Phung - initial Release

If @unitcode = '(all)'
  SELECT '(all)'  as ledgercode
   UNION
  SELECT a.ledgercode 
    FROM [cis_OAMPS].dbo.ods_oamps_physicalbranch a
     INNER JOIN [cis_OAMPS].dbo.ods_oamps_accesslevel b
     ON a.SystemCode = b.SystemCode
  WHERE AccessLevel = 1
--    AND a.unitcode = @unitcode
  GROUP BY a.ledgercode 
  ORDER BY ledgercode
else 
  SELECT '(all)'  as ledgercode
   UNION
  SELECT a.ledgercode 
    FROM [cis_OAMPS].dbo.ods_oamps_physicalbranch a
     INNER JOIN [cis_OAMPS].dbo.ods_oamps_accesslevel b
     ON a.SystemCode = b.SystemCode
  WHERE AccessLevel = 1
    AND a.unitcode = @unitcode
  GROUP BY a.ledgercode 
  ORDER BY ledgercode




