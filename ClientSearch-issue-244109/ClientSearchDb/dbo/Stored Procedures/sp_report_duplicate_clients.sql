



/****** Object:  Stored Procedure dbo.sp_report_duplicate_clients    Script Date: 14/12/2004 3:09:59 PM ******/
CREATE      PROCEDURE sp_report_duplicate_clients (@ledgercode varchar(100)) AS 

-- Nov 16 2004: Swanson Phung - initial Release
-- Mar 29, 2005: Felix Huang - changed the display order to branch code and client executive code


IF @ledgercode='(all)'

  select org.* 
  from [cis_OAMPS].dbo.cds_oamps_clients org
   inner join 
     (select UID,ledgercode 
      from [cis_OAMPS].dbo.cds_oamps_clients  
  --    where ledgercode = @ledgercode
      group by UID,ledgerCode 
      having count(*) > 1) dup 
  on org.UID=dup.UID and org.ledgercode=dup.ledgercode
 -- order by  org.SystemCode, org.LedgerCode, org.UID
  order by branchcode, clientexecutiveCode
ELSE 

  select org.* 
  from [cis_OAMPS].dbo.cds_oamps_clients org
   inner join 
     (select UID,ledgercode 
      from [cis_OAMPS].dbo.cds_oamps_clients  
      where ledgercode = @ledgercode
      group by UID,ledgerCode 
      having count(*) > 1) dup 
  on org.UID=dup.UID and org.ledgercode=dup.ledgercode
  --order by  org.SystemCode, org.LedgerCode, org.UID
  order by branchcode, clientexecutiveCode



