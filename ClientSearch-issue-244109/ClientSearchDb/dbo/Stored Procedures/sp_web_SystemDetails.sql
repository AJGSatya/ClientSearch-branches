
/****** Object:  Stored Procedure dbo.sp_web_SystemDetails    Script Date: 23/12/2004 11:05:04 AM ******/


-- 12 Nov 2004 Michael Mackowiak: initial release

CREATE  PROCEDURE [dbo].[sp_web_SystemDetails]

	@ClientCode	varchar(100),
	@SystemCode	varchar(20)

AS

	
If  @SystemCode = 'AHW'
	
		SELECT *
		FROM
			ods_clients_specific_ahw
		WHERE
			UPPER(ClientCode) = UPPER(@ClientCode)

else If  @SystemCode = 'ATURA'
	
		SELECT *
		FROM
			ods_clients_specific_atura
		WHERE
			UPPER(ClientCode) = UPPER(@ClientCode)

else If  @SystemCode =  'OIB'
	
		SELECT *
		FROM
			ods_clients_specific_oib
		WHERE
			UPPER(ClientCode) = UPPER(@ClientCode)

else If  @SystemCode =  'VIGIL'
	
		SELECT *
		FROM
			ods_clients_specific_vigil
		WHERE
			UPPER(ClientCode) = UPPER(@ClientCode)

else If  @SystemCode =  'YIG'
	
		SELECT *
		FROM
			ods_clients_specific_yig
		WHERE
			UPPER(ClientCode) = UPPER(@ClientCode)

