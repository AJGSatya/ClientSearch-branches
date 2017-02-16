

CREATE   PROCEDURE [dbo].[sp_ods_clients_company] AS

-- Nov 16 2004: Swanson Phung - initial Release
-- 03 Dec 2007 - Swanson Phung: SQL 2005 migration
-- 03 Dec 2007 - Swanson Phung: SQL 2005 migration and clean-up

DECLARE @pattern varchar(5000), @input varchar(100)

SET	@pattern = 
'SET QUOTED_IDENTIFIER OFF
 TRUNCATE TABLE [cis_oamps].dbo.ods_clients_company
 INSERT INTO [cis_oamps].dbo.ods_clients_company
 SELECT * FROM ods_clients_basic
 WHERE 
 --   len(ABN) <> 0 
 --   OR (LedgerCode = "AHW" AND Operation <> "Builder-OB") 
 --   OR Address_line_1 like "%[^a-z]ltd[^a-z]%"
 --   OR Address_line_1 like "%[^a-z]pty[^a-z]%"
 --   OR Address_line_1 like "%[^a-z]p/l[^a-z]%"
    ClientName like '

DECLARE c1 CURSOR FOR
SELECT Value1 FROM [cis_oamps].dbo.utl_system_option WHERE Type ='bus_ref'
OPEN c1

FETCH NEXT FROM c1 INTO @input
WHILE @@FETCH_STATUS = 0
 BEGIN
--     PRINT @input
     SET @pattern = @pattern+'"%[^a-z]'+@input+'[^a-z]%"
    OR ClientName like "%[^a-z]'+@input+'%"'
     FETCH NEXT FROM c1 INTO @input
     IF @@FETCH_STATUS = 0 SET @pattern = @pattern+'
    OR ClientName like '
 END

CLOSE c1
DEALLOCATE c1
SET @pattern = @pattern+'
SET QUOTED_IDENTIFIER OFF '

--PRINT @pattern
EXECUTE (@pattern)

