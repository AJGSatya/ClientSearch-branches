

CREATE   PROCEDURE [dbo].[sp_utl_log_update]
  @process_key int,
  @log_details varchar(500)
AS

-- Nov 16 2004: Swanson Phung - initial Release

  SET NOCOUNT ON
  INSERT INTO [cis_OAMPS].dbo.utl_log  (Log_DateTime,  Log_Details,  Log_Process_key)
  VALUES        ( GETDATE(),  @log_details,  @process_key )



