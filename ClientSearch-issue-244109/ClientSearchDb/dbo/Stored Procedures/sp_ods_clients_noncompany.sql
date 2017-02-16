


CREATE     PROCEDURE [dbo].[sp_ods_clients_noncompany] AS

-- Nov 16 2004: Swanson Phung - initial Release
-- Aug 22 2005: added temp fix for hopewiser program
-- Nov 29 2005: more temp fix for hopewiser program
-- 03 Dec 2007 - Swanson Phung: SQL 2005 migration and clean-up


TRUNCATE TABLE	[cis_oamps].dbo.ods_clients_noncompany
   
INSERT INTO		[cis_oamps].dbo.ods_clients_noncompany
SELECT	* 
FROM	ods_clients_basic org
WHERE	not exists
           (
			SELECT	* 
            FROM	[cis_oamps].dbo.ods_clients_company com
            WHERE	org.ClientCode = com.ClientCode
            AND		org.local_branchcode = com.local_branchcode
			)


-- temp fix for hopewiser -- remove bad-rec, date: 22 aug 2005
  delete from .dbo.ods_clients_company
  where ClientName like '%Units Plan 85/97 85/91 & 86/01%'
     or ClientName like 'body corp%plan%'
     or ClientName like '%Unit Plan 85/97 85/91 & 86/01%' -- Nov 29 2005
     or Clientname like 'Marjorie Bush (owner of units 1 & 2/2A E%' -- mar 21 2006

  delete from .dbo.ods_clients_noncompany
  where ClientName like '%Units Plan 85/97 85/91 & 86/01%'
     or ClientName like 'body corp%plan%'
     or ClientName like '%Unit Plan 85/97 85/91 & 86/01%' -- Nov 29 2005
     or Clientname like 'Marjorie Bush (owner of units 1 & 2/2A E%' -- mar 21 2006
-- temp fix for hopewiser -- remove bad-rec, date: 22 aug 2005







