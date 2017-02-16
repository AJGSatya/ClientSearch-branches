

/****** Object:  Stored Procedure dbo.sp_report_unit_list    Script Date: 23/12/2004 11:05:03 AM ******/





CREATE   procedure sp_report_unit_list ( @unitcode varchar(20)) AS

-- Nov 16 2004: Swanson Phung - initial Release


if @unitcode = '(all)'

  SELECT  '(all)' as unitcode
   UNION
  (SELECT a.Unitcode
    FROM [cis_OAMPS].dbo.ods_oamps_physicalbranch a
     INNER JOIN [cis_OAMPS].dbo.ods_oamps_accesslevel b
     ON a.SystemCode = b.SystemCode
  WHERE AccessLevel = 1
--    AND a.UnitCode = @unitcode
  GROUP BY a.Unitcode)
  ORDER BY Unitcode

else 

  SELECT  '(all)' as unitcode
   UNION
  SELECT a.Unitcode
    FROM [cis_OAMPS].dbo.ods_oamps_physicalbranch a
     INNER JOIN [cis_OAMPS].dbo.ods_oamps_accesslevel b
     ON a.SystemCode = b.SystemCode
  WHERE AccessLevel = 1
    AND a.UnitCode = @unitcode
  GROUP BY a.Unitcode
  ORDER BY Unitcode





