﻿CREATE TABLE [dbo].[ods_clients_noncompany_matched] (
    [DDGroupID]             INT           NOT NULL,
    [PCStatus]              VARCHAR (255) NULL,
    [AddressKey]            VARCHAR (255) NULL,
    [DPID]                  VARCHAR (255) NULL,
    [CompanyKey]            VARCHAR (255) NULL,
    [CompanyKeyword]        VARCHAR (255) NULL,
    [NameKey]               VARCHAR (255) NULL,
    [UnitCode]              VARCHAR (20)  NOT NULL,
    [SystemCode]            VARCHAR (20)  NOT NULL,
    [LedgerCode]            VARCHAR (100) NOT NULL,
    [BranchCode]            VARCHAR (50)  NOT NULL,
    [Local_BranchCode]      VARCHAR (20)  NOT NULL,
    [ClientCode]            VARCHAR (100) NOT NULL,
    [ClientName]            VARCHAR (255) NULL,
    [Address_Line_1]        VARCHAR (255) NULL,
    [Address_Line_2]        VARCHAR (255) NULL,
    [Address_Line_3]        VARCHAR (255) NULL,
    [Suburb]                VARCHAR (255) NULL,
    [Postcode]              VARCHAR (255) NULL,
    [Postal_Address_Line_1] VARCHAR (255) NULL,
    [Postal_Address_Line_2] VARCHAR (255) NULL,
    [Postal_Address_Line_3] VARCHAR (255) NULL,
    [Postal_Suburb]         VARCHAR (255) NULL,
    [Addressee]             VARCHAR (255) NULL,
    [Salutation]            VARCHAR (255) NULL,
    [Gender]                VARCHAR (30)  NULL,
    [ClientExecutiveCode]   VARCHAR (50)  NULL,
    [Phone]                 VARCHAR (255) NULL,
    [Fax]                   VARCHAR (255) NULL,
    [Mobile]                VARCHAR (255) NULL,
    [Email]                 VARCHAR (255) NULL,
    [ABN]                   VARCHAR (255) NULL,
    [Retail_Wholesale]      VARCHAR (255) NULL,
    [Contact_Method]        VARCHAR (255) NULL,
    [Contact_Preference]    VARCHAR (255) NULL,
    [Contact_Comments]      VARCHAR (255) NULL,
    [Operation]             VARCHAR (255) NULL,
    [Commence_Date]         SMALLDATETIME NULL,
    [Association_Code]      VARCHAR (100) NULL,
    [Last_Updated]          SMALLDATETIME NOT NULL,
    [Process_Key]           INT           NOT NULL,
    [DDPctg]                VARCHAR (255) NOT NULL
);

