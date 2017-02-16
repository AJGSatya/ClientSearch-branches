CREATE TABLE [dbo].[crm_campaign_history] (
    [CampaignType]       VARCHAR (100) NOT NULL,
    [CampaignDate]       SMALLDATETIME NOT NULL,
    [BranchCode]         VARCHAR (50)  NULL,
    [ClientCode]         VARCHAR (100) NOT NULL,
    [ClientName]         VARCHAR (255) NULL,
    [Address_Line_1]     VARCHAR (255) NULL,
    [Address_Line_2]     VARCHAR (255) NULL,
    [Address_Line_3]     VARCHAR (255) NULL,
    [Postcode]           VARCHAR (255) NULL,
    [Addressee]          VARCHAR (255) NULL,
    [Salutation]         VARCHAR (255) NULL,
    [Phone]              VARCHAR (255) NULL,
    [Fax]                VARCHAR (255) NULL,
    [Mobile]             VARCHAR (255) NULL,
    [Contact_Method]     VARCHAR (255) NULL,
    [Contact_Preference] VARCHAR (255) NULL,
    [Contact_Comments]   VARCHAR (255) NULL,
    [UID]                INT           NULL,
    [DateStart]          SMALLDATETIME NULL,
    [DateEnd]            SMALLDATETIME NULL,
    [Process_Key]        INT           NOT NULL
);

