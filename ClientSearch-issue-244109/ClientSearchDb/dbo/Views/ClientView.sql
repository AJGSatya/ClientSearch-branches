-- 01 Sep 2016: Kha Tran: add ClientExecutiveName to the search

CREATE VIEW [dbo].[ClientView]
AS
SELECT TOP (100) PERCENT 
	coc.UID, 
	coc.LedgerCode, 
	coc.BranchCode, 
	coc.Local_BranchCode, coc.ClientCode, coc.ClientName, coc.Address_Line_1, 
	coc.Address_Line_2, 
    coc.Address_Line_3, coc.Suburb, coc.Postcode, coc.Postal_Address_Line_1, coc.Postal_Address_Line_2, coc.Postal_Address_Line_3, coc.Postal_Suburb, 
    coc.Addressee, coc.Salutation, coc.Gender, 
	coc.ClientExecutiveCode, 
	e.Executive_Name as 'ClientExecutiveName', 
	coc.Phone, coc.Fax, 
	coc.Mobile, coc.Email, coc.ABN, coc.Retail_Wholesale, 
    coc.Contact_Method, 
	coc.Contact_Preference, coc.Contact_Comments, coc.Operation, coc.Commence_Date, coc.Association_Code, coc.Last_Updated, 
    coc.Process_Key, dbo.ods_oamps_accesslevel.AccessLevel, coc.SystemCode, coc.UnitCode, coc.DepositBSB, coc.DepositAccount, cs.TeamCode, 
    cs.Renewal_Date, 
	cs.Last_Transaction_Date
FROM            
	dbo.ods_oamps_accesslevel 
		INNER JOIN .dbo.cds_oamps_clients AS coc 
			ON dbo.ods_oamps_accesslevel.SystemCode = coc.SystemCode 
		LEFT JOIN [$(DwOamps)].dbo.dds_dim_executive e
			ON coc.ClientExecutiveCode = e.Executive_Code
		LEFT OUTER JOIN dbo.ods_clients_specific_oib AS cs 
			ON cs.ClientCode = coc.ClientCode
		
WHERE        
	(dbo.ods_oamps_accesslevel.AccessLevel = 1)
ORDER BY 
	dbo.ods_oamps_accesslevel.UnitCode, 
	coc.LedgerCode, 
	coc.ClientCode


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ods_oamps_accesslevel"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 310
               Right = 356
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "coc"
            Begin Extent = 
               Top = 21
               Left = 442
               Bottom = 298
               Right = 904
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cs"
            Begin Extent = 
               Top = 6
               Left = 942
               Bottom = 135
               Right = 1148
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ClientView';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ClientView';

