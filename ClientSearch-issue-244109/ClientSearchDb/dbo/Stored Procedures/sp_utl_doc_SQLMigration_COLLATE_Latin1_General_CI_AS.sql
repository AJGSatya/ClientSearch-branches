
CREATE PROCEDURE [dbo].[sp_utl_doc_SQLMigration_COLLATE_Latin1_General_CI_AS] AS



DROP INDEX [IX_ods_clients_specific_oib] ON [dbo].[ods_clients_specific_oib] 
ALTER TABLE [dbo].[ods_clients_specific_oib] ALTER COLUMN	[ClientCode] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL
CREATE NONCLUSTERED INDEX [IX_ods_clients_specific_oib] ON [dbo].[ods_clients_specific_oib] 
(	[ClientCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
