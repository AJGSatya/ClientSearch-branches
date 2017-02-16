CREATE TABLE [dbo].[utl_log] (
    [Log_Key]         INT           IDENTITY (1, 1) NOT NULL,
    [Log_DateTime]    DATETIME      NULL,
    [Log_Details]     VARCHAR (500) NULL,
    [Log_Process_Key] INT           NOT NULL
);

