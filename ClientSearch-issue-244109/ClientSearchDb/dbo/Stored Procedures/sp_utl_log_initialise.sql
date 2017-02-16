


CREATE    PROCEDURE [dbo].[sp_utl_log_initialise]
    @in_job_id int,
    @in_process_key int,
    @jod_id int OUTPUT, 
    @file_pattern varchar(100) OUTPUT,
    @processed_date datetime OUTPUT,
    @load_type varchar(1) OUTPUT,
    @source_dir varchar(100) OUTPUT,
    @source_system char(10) OUTPUT,
    @dest_dir varchar(100) OUTPUT, 
    @process_key int OUTPUT,
    @file_processed varchar(100) OUTPUT, 
    @log_details varchar(500) OUTPUT, 
    @curr_processed_date datetime OUT, 
    @process_status varchar(100) OUTPUT,
    @job_desc varchar(100) OUTPUT, 
    @mail_from varchar(100) OUTPUT, 
    @mail_to varchar(100) OUTPUT, 
    @filename varchar(100) OUTPUT
AS

-- Nov 16 2004: Swanson Phung - initial Release

DECLARE @status varchar(100), @log varchar(100)
SET NOCOUNT ON
SET  @status = 'STARTED'
SET  @log = 'Process started '
-- Get Job Details for Job to be run.
SELECT DISTINCT Job_ID AS jod_id,
                Job_File_Pattern AS file_pattern, 
                Job_Processed_Date AS processed_date, 
                Job_Load_Type AS load_type,
                Job_Source_System AS source_system, 
                Job_Source_Dir AS source_dir, 
                Job_Dest_Dir AS dest_dir,
                @in_process_key AS  process_key, 
                'N/A' AS file_processed, -- <=== from null
                @log  AS log_details, 
                Job_Processed_Date  AS curr_processed_date, -- <=== from null
                @status AS process_status, 
                Job_Desc AS job_desc, 
                (SELECT  DISTINCT Value1 FROM  utl_system_option WHERE Type = 'DWH-Admin')  AS mail_from,
                (SELECT  DISTINCT Value2 FROM  utl_system_option WHERE Type = 'DWH-Admin') AS mail_to, 
                'N/A' AS filename -- <=== from null
FROM [cis_OAMPS].dbo.utl_job
WHERE Job_ID = @in_job_id
EXEC [cis_OAMPS].dbo.sp_utl_log_update  @in_process_key, @log




