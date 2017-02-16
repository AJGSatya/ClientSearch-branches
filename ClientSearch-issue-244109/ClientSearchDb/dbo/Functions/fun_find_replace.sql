
-- /**** Removes any special characters from @inputString that do not meet the  provided criteria. ** /

--  This function takes input string and the valid characters and replaces all the characters other than those in valid characters string. 
--  Can be used as follows :  select [dbo].fun_find_replace('Valid are chars and 0 to 9 not *^' ,'0-9a-z ')  


CREATE FUNCTION [dbo].[fun_find_replace](@inputString VARCHAR(MAX), @validChars VARCHAR(100)) RETURNS VARCHAR(500) 
AS
BEGIN       
WHILE @inputString like '%[^' + @validChars + ']%'     

  SELECT @inputString = REPLACE(@inputString,SUBSTRING(@inputString,PATINDEX('%[^' + @validChars + ']%',@inputString),1),'')    
 
RETURN @inputString END 

