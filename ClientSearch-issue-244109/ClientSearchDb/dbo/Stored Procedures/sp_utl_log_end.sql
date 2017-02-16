
CREATE    PROCEDURE [dbo].[sp_utl_log_end]
    @job_id int, 
    @process_key int,
    @file_processed varchar(100), 
    @processed_date datetime, 
    @log_details varchar(500),
    @process_status varchar(20)
AS
-- Nov 16 2004: Swanson Phung - initial Release
-- 21 jul 2007 - Swanson Phung: update utl_job table when DONE only

 SET NOCOUNT ON
 
IF @process_status = 'DONE' 
	BEGIN
		SET @log_details = 'Process Ended ' 
		-- update JOB table 
		UPDATE      [cis_OAMPS].dbo.utl_job
		SET         Job_Processed_Date =  @processed_date
		WHERE      (Job_ID = @job_id )
	END
 ELSE

	BEGIN 
     SET @log_details = 'Process Ended with ' +@log_details
	END

-- update LOG table 
EXECUTE [cis_OAMPS].dbo.sp_utl_log_update @process_key, @log_details

-- update PROCESS table
UPDATE	[cis_OAMPS].dbo.utl_process
SET      Process_End			= GETDATE() 
        ,Process_Status			= @process_status 
        ,Process_File_Processed = @file_processed
WHERE	(Process_Key = @process_key)






