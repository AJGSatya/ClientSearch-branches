CREATE TABLE [dbo].[utl_job] (
    [Job_ID]             INT           NOT NULL,
    [Job_Desc]           VARCHAR (100) NULL,
    [Job_File_Pattern]   VARCHAR (100) NULL,
    [Job_Processed_Date] DATETIME      NULL,
    [Job_Load_Type]      VARCHAR (10)  NULL,
    [Job_Cat]            VARCHAR (100) NULL,
    [Job_Source_System]  VARCHAR (100) NULL,
    [Job_Source_Dir]     VARCHAR (100) NULL,
    [Job_Dest_Dir]       VARCHAR (100) NULL
);

