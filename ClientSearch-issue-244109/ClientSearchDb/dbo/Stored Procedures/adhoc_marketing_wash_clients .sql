

CREATE      PROCEDURE [dbo].[adhoc_marketing_wash_clients ] AS 

----------------------------------------------------------------------------------------------------------
-- 12 Feb 2015 : Shiny Mukundan Phung - Initial release

----------------------------------------------------------------------------------------------------------

DECLARE
 
@comment varchar(255)
 
-- Create tmp table . Upload data into ods_oib_marketing_campaign_in structure.
-- ods_oib_marketing_campaign_in has the following fields [Member First Name] ,[Member Surname] ,[TradingName] ,[Address] ,[Suburb] ,[State] ,[Postcode] ,[PostalAddress] ,[PostalSuburb] ,[PostalState] ,[PostalPostcode] ,[Phone] ,[AfterHoursPhone] ,[Fax] ,[Mobile] ,[Email] ,[F1] ,[f2] ,[f3] ,[f4] ,[f5] ,[f6] ,[f7]



			--DROP TABLE #tmp_mktg 

			select * into #tmp_mktg from ods_oib_marketing_campaign_in
	
			alter table #tmp_mktg 
			add comment varchar(255) ,pure_address varchar(255),pure_PostalAddress varchar(255),
												IbaisClientCode varchar(50), IbaisClientExecutive varchar(50),IbaisClientName varchar(255),IbaisAddress varchar(255) ,IbaisPostalAddress varchar(255),IbaisPostcode  varchar(10)
												,IbaisPhoneno varchar(50),Ibaisfax varchar(50),Ibaismobile varchar(50) ,Ibaisemail varchar(50)
	                                                      
	     

 -- ** Start Cleansing --

-- update address if there is different fields for Suburb State and postcode.

					UPDATE #tmp_mktg  
					SET  pure_address = upper(dbo.fun_find_replace(isnull(address,'')+isnull(suburb,'')+isnull(state,'')+ISNULL(postcode,''),'0-9a-z'))
					WHERE address is not null

					UPDATE #tmp_mktg  
					SET  pure_PostalAddress = upper(dbo.fun_find_replace(isnull(PostalAddress,'')+isnull(PostalSuburb,'')+isnull(PostalState,'')+ISNULL(PostalPostcode,''),'0-9a-z'))
					WHERE PostalAddress is not null



-- Compare Name and update  
					UPDATE tm 
					SET			comment =  '1. Full name match' 
								   ,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone
								   ,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
				   INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc    ON  UPPER(tm.TradingName) = UPPER(dfc.ClientName)
				   and tm.TradingName is not null
				   
				   
				   
				   	UPDATE tm 
					SET			comment =  '1. Full name match' 
								   ,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone
								   ,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
				   INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc     
				   ON  [dw_oamps].dbo.fun_find_replace(dfc.ClientName,'0-9A-Z') = [dw_oamps].dbo.fun_find_replace(tm.TradingName,'0-9A-Z')
				   WHERE comment is null 
				   and tm.TradingName is not null	
 
   
  
  PRINT 'Name updated' 

-- Compare partial name and update
					UPDATE tm 
					SET			comment = '2. Partialname +Postcode match ' 
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone 
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
					INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
								ON  UPPER(dfc.ClientName) like '%'+UPPER(tm.TradingName)+'%'   AND tm.postcode  = dfc.Postcode
					WHERE comment is null 	
					and tm.TradingName is not null



  PRINT ' Partial Name updated' 
  
-- matches iBAIS physical address with given physical address
					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'3. Address match' 
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
				   INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
				   ON     tm.pure_address   =	 replace(replace(replace(upper(dbo.fun_find_replace(isnull(dfc.Address_Line_1,'')+isnull(dfc.Address_Line_2,'')+isnull(dfc.Address_Line_3,''),'0-9a-z'))
																					,isnull(upper(replace(dfc.Suburb,' ','')),''),''),isnull(upper(replace(dfc.State,' ','')),''),''),isnull(upper(replace(dfc.Postcode,' ','')),''),'')	
																							+isnull(upper(replace(dfc.Suburb,' ','')),'')+isnull(upper(replace(dfc.State,' ','')),'')+isnull(upper(replace(dfc.Postcode,' ','')),'')
					and 	tm.pure_address is not null																						
	
	
					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'3. Address match' 
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
				   INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
				   ON   upper(dbo.fun_find_replace(isnull(tm.pure_address,''),'0-9a-z'))  =  upper(dbo.fun_find_replace(isnull(dfc.Address_Line_1,'') ,'0-9a-z')) 
					WHERE comment not like '%Address%' and isnull( tm.pure_address,'') <> ''
						and 	tm.pure_address is not null	
					
				 

 
	-- matches iBAIS physical address with given postal address
	
 					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'3. Address match' 
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
				   INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc																	
					ON		 tm.pure_PostalAddress   =	 replace(replace(replace(upper(dbo.fun_find_replace(isnull(dfc.Address_Line_1,'')+isnull(dfc.Address_Line_2,'')+isnull(dfc.Address_Line_3,''),'0-9a-z'))
																					,isnull(upper(replace(dfc.Suburb,' ','')),''),''),isnull(upper(replace(dfc.State,' ','')),''),''),isnull(upper(replace(dfc.Postcode,' ','')),''),'')	
																							+isnull(upper(replace(dfc.Suburb,' ','')),'')+isnull(upper(replace(dfc.State,' ','')),'')+isnull(upper(replace(dfc.Postcode,' ','')),'')
					WHERE comment not like '%Address%'    	
					and 	tm.pure_address is not null					
				 
				 
				
				 
	-- matches  with ibais Postal address given physical address
 
					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'4. Postal Address match' 
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
					 INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
					ON     tm.pure_address   =	 replace(replace(replace(upper(dbo.fun_find_replace(isnull(dfc.Postal_Address_Line_1,'')+isnull(dfc.Postal_Address_Line_2,'')+isnull(dfc.Postal_Address_Line_3,''),'0-9a-z'))
																	,isnull(upper(replace(dfc.Postal_Suburb,' ','')),''),''),isnull(upper(replace(dfc.State,' ','')),''),''),isnull(upper(replace(dfc.Postcode,' ','')),''),'')	
																	+isnull(upper(replace(dfc.Postal_Suburb,' ','')),'')+isnull(upper(replace(dfc.State,' ','')),'')+isnull(upper(replace(dfc.Postcode,' ','')),'')
				   
					WHERE comment not like '%Address%'
					and 	tm.pure_address is not null	    																	
					
	
	
	-- matches iBAIS Postal address with given postal address
	
	
 					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'4. Postal Address match' 
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
				   INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc																	
					ON		 tm.pure_PostalAddress   =	 replace(replace(replace(upper(dbo.fun_find_replace(isnull(dfc.Postal_Address_Line_1,'')+isnull(dfc.Postal_Address_Line_2,'')+isnull(dfc.Postal_Address_Line_3,''),'0-9a-z'))
																	,isnull(upper(replace(dfc.Postal_Suburb,' ','')),''),''),isnull(upper(replace(dfc.State,' ','')),''),''),isnull(upper(replace(dfc.Postcode,' ','')),''),'')	
																	+isnull(upper(replace(dfc.Postal_Suburb,' ','')),'')+isnull(upper(replace(dfc.State,' ','')),'')+isnull(upper(replace(dfc.Postcode,' ','')),'')
 					WHERE comment not like '%Address%'    
 					and tm.pure_PostalAddress is not null
				 
				 
  PRINT ' Address updated' 
    
    
    
-- Compare PhoneNo and update			

					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'5. Phoneno match'
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
					INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
					ON  [dw_oamps].dbo.fun_find_replace( isnull(tm.Phone,tm.AfterHoursPhone) ,'0-9') = [dw_oamps].dbo.fun_find_replace(dfc.Phone,'0-9')  
				    AND( [dw_oamps].dbo.fun_find_replace( isnull(tm.Phone,tm.AfterHoursPhone)  ,'0-9') <>''  
						 OR [dw_oamps].dbo.fun_find_replace(dfc.Phone,'0-9') <>'')
							  AND       (  COMMENT  like '%Address%'  OR comment  like '%name%'  OR COMMENT is null ) 
					AND tm.AfterHoursPhone is not null
					
					UPDATE tm 
					SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'5. Phoneno match'
					FROM #tmp_mktg  tm
					INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
					ON  [dw_oamps].dbo.fun_find_replace( isnull(tm.Phone,tm.AfterHoursPhone) ,'0-9') = [dw_oamps].dbo.fun_find_replace(dfc.Phone,'0-9')  
					  AND ( [dw_oamps].dbo.fun_find_replace( isnull(tm.Phone,tm.AfterHoursPhone)  ,'0-9') <>''   OR [dw_oamps].dbo.fun_find_replace(dfc.Phone,'0-9') <>'')
					 WHERE tm.Postcode = dfc.Postcode 
					 AND substring(dfc.ClientName,1,10) like '%'+substring(tm.TradingName,1,10) +'%'
					 AND    COMMENT is null 
								
				              
   
  PRINT ' Phone no updated' 
  
  -- Compare Fax no  and update		
  
					UPDATE tm 
					SET			 comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'6. Fax No Match'
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
					INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
					ON  [dw_oamps].dbo.fun_find_replace(tm.fax,'0-9') = [dw_oamps].dbo.fun_find_replace(dfc.Fax,'0-9')  
								AND ( [dw_oamps].dbo.fun_find_replace(tm.fax,'0-9') <>''   OR [dw_oamps].dbo.fun_find_replace(dfc.fax,'0-9') <>'')
								AND		 [dw_oamps].dbo.fun_find_replace(tm.fax,'0-9') > 0 
							  AND       (  COMMENT  like '%Address%'  OR comment  like '%name%'  OR COMMENT is null ) 
							  and tm.fax is not null
    
    
    
    -- Compare Mobile no and update
    
    
				   UPDATE tm 
				   SET			 comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'7. Mobile no match'
									,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone  
									,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
					INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
					ON  [dw_oamps].dbo.fun_find_replace(tm.mobile,'0-9') = [dw_oamps].dbo.fun_find_replace(dfc.Mobile,'0-9')  
					
					AND ( [dw_oamps].dbo.fun_find_replace(tm.Mobile,'0-9') <>''   OR [dw_oamps].dbo.fun_find_replace(dfc.Mobile,'0-9') <>'')
					AND       (  COMMENT  like '%Address%'  OR comment  like '%name%'  OR COMMENT is null ) 
					and tm.Mobile is not null
    
    
    
    
 -- Compare Email and update		
 	
  
				UPDATE tm 
				SET			comment = CASE WHEN comment is null THEN '' ELSE comment+' & ' END +'8. Email Match'
								,IbaisClientCode = dfc.clientcode
							   ,IbaisClientExecutive=dfc.ClientExecutiveCode
							   ,IbaisClientName = dfc.ClientName
							   ,IbaisAddress = dfc.Address_Line_1
							   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
							   ,IbaisPostcode =dfc.Postcode
							   ,IbaisPhoneno = dfc.Phone  
								,Ibaisfax = dfc.Fax
							   ,Ibaismobile=dfc.Mobile
							   ,Ibaisemail=dfc.Email
				FROM #tmp_mktg  tm
				INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
				ON  UPPER(dfc.Email) = UPPER(tm.email) and ( tm.email is not null) 
							  AND       (  COMMENT  like '%Address%'  OR comment  like '%name%'  OR COMMENT is null ) 
					  --AND       (    UPPER(tm.address) =  UPPER(dfc.Address_Line_1)   OR  UPPER(dfc.ClientName) like '%'+UPPER(tm.TradingName)+'%'  OR COMMENT not like '%Address%'  OR comment not like '%name%' )
 
 
 
 --- Member name or Surname match
					UPDATE tm 
					SET			comment =  '9. Partial name + phone match' 
								   ,IbaisClientCode = dfc.clientcode
								   ,IbaisClientExecutive=dfc.ClientExecutiveCode
								   ,IbaisClientName = dfc.ClientName
								   ,IbaisAddress = dfc.Address_Line_1
								   ,IbaisPostalAddress=dfc.Postal_Address_Line_1
								   ,IbaisPostcode =dfc.Postcode
								   ,IbaisPhoneno = dfc.Phone
								   ,Ibaisfax = dfc.Fax
								   ,Ibaismobile=dfc.Mobile
								   ,Ibaisemail=dfc.Email
					FROM #tmp_mktg  tm
					INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc 
					ON  [dw_oamps].dbo.fun_find_replace( isnull(tm.Phone,tm.AfterHoursPhone) ,'0-9') = [dw_oamps].dbo.fun_find_replace(dfc.Phone,'0-9')  
					   AND ( [dw_oamps].dbo.fun_find_replace( isnull(tm.Phone,tm.AfterHoursPhone)  ,'0-9') <>''   OR [dw_oamps].dbo.fun_find_replace(dfc.Phone,'0-9') <>'')
					   AND      COMMENT is null 
					   AND  ( [dw_oamps].dbo.fun_find_replace(dfc.ClientName,'0-9A-Z') like '%'+[dw_oamps].dbo.fun_find_replace(tm.TradingName,'0-9A-Z')+'%' 
									    OR dfc.ClientName like '%'+[Member First Name]+'%'
										 OR dfc.ClientName like '%'+[Member Surname]+'%') 
 
 
  
  -- ** End Cleansing
  
   -- Create Output table for Report

	TRUNCATE TABLE   ods_oib_marketing_campaign_out 
	
	
	INSERT into ods_oib_marketing_campaign_out 
	select *	from #tmp_mktg
	 

-- Delete tmp table
	drop table #tmp_mktg 
	
	
	  -- Update nearest postcode for verification if required
  
/*   update tm 
   SET	 comment = ' Branch '+ np.Branch
    FROM #tmp_mktg  tm 
       INNER JOIN [nearest_postcode] np  
          ON  isnull(left(replicate('0',4-LEN([dw_oamps].dbo.fun_find_replace(np.postcode,'0-9')))+[dw_oamps].dbo.fun_find_replace(np.postcode,'0-9'),10),'' )  =  isnull(left(replicate('0',4-LEN([dw_oamps].dbo.fun_find_replace(tm.postcode,'0-9')))+[dw_oamps].dbo.fun_find_replace(tm.postcode,'0-9'),10),'' )
   WHERE comment is null         */ 
 

-------------------------------------------------------------------------------------------------------
/*
-- Validation

		 	SELECT	mc.*,dfc.ClientName,dfc.Address_Line_1,dfc.Address_Line_2,dfc.Postcode,dfc.Phone,dfc.Suburb,dfc.*
			FROM ods_marketing_campaign mc ,	[dw_oamps].dbo.dds_fct_client	 dfc
		 WHERE 	(   ( mc.TradingName = dfc.ClientName )
		    		OR ( mc.address =  dfc.Address_Line_1 and mc.postcode  = dfc.Postcode) 
		    		OR    (  [dw_oamps].dbo.fun_find_replace(mc.Phone,'0-9') = [dw_oamps].dbo.fun_find_replace(Phone,'0-9')  AND ( [dw_oamps].dbo.fun_find_replace(mc.Phone,'0-9') <>''   OR [dw_oamps].dbo.fun_find_replace(Phone,'0-9') <>'') ) 
					OR  UPPER(mc.TradingName) like '%'+UPPER(dfc.ClientName)+'%' 
						)   
						

	 SELECT	mc.*,dfc.ClientName,dfc.Address_Line_1,dfc.Address_Line_2,dfc.Postal_Address_Line_1,dfc.Address_Line_3,dfc.Postal_Address_Line_2,dfc.Postal_Address_Line_3 ,dfc.Postcode,dfc.Phone,dfc.Suburb,dfc.*
			FROM ods_marketing_campaign mc ,	[dw_oamps].dbo.dds_fct_client	 dfc
		 WHERE   UPPER(dfc.ClientName) like '%'+UPPER(mc.TradingName)+'%'   AND mc.postcode  = dfc.Postcode


 SELECT	tm.*,dfc.ClientName,dfc.Address_Line_1,dfc.Address_Line_2,dfc.Postal_Address_Line_1,dfc.Address_Line_3,dfc.Postal_Address_Line_2,dfc.Postal_Address_Line_3 ,dfc.Postcode,dfc.Phone,dfc.Suburb,dfc.*
			FROM ods_marketing_campaign tm
	 INNER JOIN	[dw_oamps].dbo.dds_fct_client	 dfc ON   ( UPPER(tm.address) =  UPPER(dfc.Address_Line_1) and tm.postcode  = dfc.Postcode )
	and  tm.TradingName = 'Caltex Copping Roadhouse'
	
	
	select * from #tmp_mktg where TradingName = 'Caltex Copping Roadhouse'
	

	*/