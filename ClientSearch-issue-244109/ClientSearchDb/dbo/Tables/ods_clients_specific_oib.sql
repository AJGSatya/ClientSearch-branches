CREATE TABLE [dbo].[ods_clients_specific_oib] (
    [UnitCode]              VARCHAR (20)   NOT NULL,
    [SystemCode]            VARCHAR (20)   NOT NULL,
    [LedgerCode]            VARCHAR (100)  NOT NULL,
    [BranchCode]            VARCHAR (50)   NOT NULL,
    [Local_BranchCode]      VARCHAR (20)   NOT NULL,
    [ClientCode]            VARCHAR (100)  NOT NULL,
    [ClientName]            VARCHAR (255)  NULL,
    [TeamCode]              VARCHAR (100)  NULL,
    [Netbrokerage_lfy]      DECIMAL (9, 2) NULL,
    [BasePremium_lfy]       DECIMAL (9, 2) NULL,
    [Incomeband_lfy]        VARCHAR (30)   NULL,
    [Netbrokerage_ytd]      DECIMAL (9, 2) NULL,
    [BasePremium_ytd]       DECIMAL (9, 2) NULL,
    [Incomeband_ytd]        VARCHAR (30)   NULL,
    [Renewal_Date]          SMALLDATETIME  NULL,
    [Last_Transaction_Date] SMALLDATETIME  NULL,
    [NoOfClaim_l5yrs]       INT            NULL,
    [Process_Key]           INT            NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ods_clients_specific_oib]
    ON [dbo].[ods_clients_specific_oib]([ClientCode] ASC);

