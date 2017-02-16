CREATE TABLE [dbo].[ods_clients_matched_exception] (
    [GroupNo]     INT           NOT NULL,
    [OrderNo]     INT           NOT NULL,
    [ClientCode1] VARCHAR (100) NOT NULL,
    [ClientCode2] VARCHAR (100) NOT NULL,
    [Type]        VARCHAR (20)  NULL,
    [Process_Key] INT           NULL
);

