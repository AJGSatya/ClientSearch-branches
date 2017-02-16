
/****** Object:  Stored Procedure dbo.sp_web_ClientDetails_by_UID    Script Date: 23/12/2004 11:05:04 AM ******/

-- 08 Nov 2004 Michael Mackowiak: initial release

CREATE PROCEDURE [dbo].[sp_web_ClientDetails_by_UID]

	@UID	integer

AS

	SELECT *

	FROM
		cds_oamps_clients INNER JOIN ods_oamps_accesslevel ON cds_oamps_clients.SystemCode = ods_oamps_accesslevel.SystemCode

	WHERE

		UID = @UID
