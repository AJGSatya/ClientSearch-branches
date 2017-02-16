


CREATE PROCEDURE [dbo].[sp_utl_log_getkey]
    @job_id int,
    @process_key int OUTPUT
AS

-- 21 aug 2007 - Swanson Phung: SQL 2005 migration

DECLARE @status varchar(100), @ins_error int, @delay int
SET	NOCOUNT ON
SET	@status = 'STARTED'
SET @ins_error = 1
SET @delay = 5

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE	@ins_error <> 0 
	BEGIN
		BEGIN TRANSACTION
		-- Create NEW Process Key with default values.
		INSERT INTO utl_process	(Process_Start, Process_End, Process_Status, Process_File_Processed, Process_Job_ID  )
		VALUES					(GETDATE(), NULL, @status, NULL, @job_id)
		SELECT @process_key =  SCOPE_IDENTITY(), @ins_error = @@ERROR

		    IF @ins_error = 0
				BEGIN
					COMMIT TRAN 
					BREAK
				END
			ELSE 
				BEGIN
					ROLLBACK TRAN
				END

			IF @delay = 0
				BEGIN
					BREAK
					RAISERROR ('ROLL BACK: Failed to Create a new process', 16, 1)  
				END
			ELSE 
				BEGIN   
					WAITFOR DELAY '000:00:05'
					SET @delay = @delay  - 1
					CONTINUE
				END
	END

SET TRANSACTION ISOLATION LEVEL READ COMMITTED



