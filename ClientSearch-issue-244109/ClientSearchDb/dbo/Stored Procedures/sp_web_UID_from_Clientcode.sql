

/****** Object:  Stored Procedure dbo.sp_web_UID_from_Clientcode    Script Date: 23/12/2004 11:05:04 AM ******/

-- 23 jan 2007 Swanston: increased length of clientcode 
-- 26 Nov 2004 Michael Mackowiak: initial release

CREATE  PROCEDURE [dbo].[sp_web_UID_from_Clientcode]

	@UID int output,
	@clientcode	varchar(100)

AS

	SELECT 
		@UID = UID

	FROM
		cds_oamps_clients

	WHERE
		UPPER(clientcode) = UPPER(@clientcode)
		
		print @UID


