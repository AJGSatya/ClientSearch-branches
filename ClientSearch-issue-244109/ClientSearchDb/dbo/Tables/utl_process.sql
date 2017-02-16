CREATE TABLE [dbo].[utl_process] (
    [Process_Key]            INT           IDENTITY (1, 1) NOT NULL,
    [Process_Start]          DATETIME      NULL,
    [Process_End]            DATETIME      NULL,
    [Process_Status]         VARCHAR (100) NULL,
    [Process_File_Processed] VARCHAR (100) NULL,
    [Process_Job_ID]         INT           NOT NULL
);

