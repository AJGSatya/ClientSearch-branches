
-- 26 Jun 2007 Felix: Fixed bug in the address field search
-- 23 jan 2007 Swanston: increased length of ledgercode and branchcode 
-- 18 Apr 2005 Felix: Added search for underwriter policy and memo number, invoice number
-- 12 Nov 2004 Swanston: added ledgercode(all) if statement
-- 01 Nov 2004 Michael Mackowiak: initial release
-- 31 Jul 2008 Swanston: added wild card search for MemoNo, invoiceNo, and UnderwriterNo 
-- 12 Jun 2009:Swanson Phung - added deposist BSB and account
-- 22 Dec 2009: Felix Huang - changed to use dynamic sql
-- 19 Jan 2010:Felix Huang -- added wildcard search for client code and policy number.
-- 29 Jan 2010: Changed to accomodate apostrophes in client name search and increase number of records returned to 20
-- 15 Apr 2010:Swanson Phung - client-without-transactions by removing join to dw_oamps.dbo.dds_fct_policytransaction if possible 
-- 01 Sep 2016: KT: add ClientExecutiveName to the search
-- 06 Sep 2016: KT: rename from sp_shinny_ClientSearch to sp_ClientSearch
/*
exec [sp_web_ClientSearch] @UnitCode = '(all)', @SystemCode = NULL, @LedgerCode = '(all)', @BranchCode = NULL, @Local_BranchCode = NULL, @ClientCode = NULL, @ClientName = 'Australian Hearing', @Address_Combined = NULL, 
@Postcode = NULL, @Postal_Address_Combined = NULL, @ClientExecutiveCode = NULL, @uwPolicyNumber = NULL, @MemorandumNumber = null, 
@InvoiceNumber = NULL
*/
CREATE       PROCEDURE [dbo].[sp_ClientSearch]

	@UnitCode	[varchar](20),
	@SystemCode	[varchar](20),
	@LedgerCode	[varchar](100),
	@BranchCode	[varchar](50),
	@Local_BranchCode	[varchar](20),
	@ClientCode	[varchar](100),
	@ClientName	[varchar](255),
	@Address_Combined	[varchar](255),
	@Postcode	[varchar](255),
	@Postal_Address_Combined	[varchar](255),
	@ClientExecutiveCode	[varchar](50),
	@ClientExecutiveName	[varchar](50),
	@uwPolicyNumber	[varchar](50),
	@MemorandumNumber [varchar](50),
    @invoicenumber [varchar] (50)
   ,@DepositBSB		[varchar] (20)
   ,@DepositAccount [varchar] (50)

AS

if		(@memorandumNumber	is null or len(ltrim(@memorandumNumber)) = 0)
	and (@uwPolicynumber	is null or len(ltrim(@uwPolicynumber)) = 0)
	and (@invoicenumber		is null or len(ltrim(@invoicenumber)) = 0)
 begin
	
	SELECT top 20	ClientView.*                   
 	FROM	ClientView		
	WHERE  (ClientName like   '%'+@ClientName+'%'	 or @ClientName is null)
	 AND (unitcode like   ''+@unitcode+'%'						or 	@UnitCode = '(all)' 	)
	AND (SystemCode like   ''+@SystemCode+'%'					or @SystemCode is null)
	AND (LedgerCode like   ''+@LedgerCode+'%'					or @LedgerCode = '(all)')
	AND (BranchCode like   ''+@BranchCode+'%'					or @BranchCode is null)	
	AND (Local_BranchCode like  '' +@Local_BranchCode+'%'		or @Local_BranchCode is null) 
	AND (ClientCode like   '%'+@ClientCode+'%'					or @ClientCode is null )
	AND (ClientExecutiveCode like   ''+@ClientExecutiveCode+'%'  or @ClientExecutiveCode is null)
	AND (ClientExecutiveName like   ''+@ClientExecutiveName+'%'  or @ClientExecutiveName is null)
	AND (DepositBSB like   ''+@DepositBSB+'%'					or @DepositBSB is null)
	AND (DepositAccount  like   ''+@DepositAccount +'%'			or @DepositAccount is null)
	AND ((isnull(Address_line_1,'''') + isnull(Address_line_2, '''') + isnull(Address_line_3,'''')) like   '%'+@Address_Combined+'%'  OR @Address_Combined is null )
	AND ((isnull(Postal_Address_Line_1,'''') + isnull(Postal_Address_Line_2, '''') + isnull(Postal_Address_Line_3,'''')) like   '%'+@Postal_Address_Combined+'%'  OR @Postal_Address_Combined is null)
	 
end
else
	SELECT top 20	ClientView.*                   
 	FROM	ClientView		
	WHERE  (ClientName like   '%'+@ClientName+'%'	 or @ClientName is null)
	 AND (unitcode like   ''+@unitcode+'%'						or 	@UnitCode = '(all)' 	)
	AND (SystemCode like   ''+@SystemCode+'%'					or @SystemCode is null)
	AND (LedgerCode like   ''+@LedgerCode+'%'					or @LedgerCode = '(all)')
	AND (BranchCode like   ''+@BranchCode+'%'					or @BranchCode is null)
	AND (Local_BranchCode like  '' +@Local_BranchCode+'%'		or @Local_BranchCode is null) 
	AND (ClientCode like   '%'+@ClientCode+'%'					or @ClientCode is null )
	AND (ClientExecutiveCode like   ''+@ClientExecutiveCode+'%'  or @ClientExecutiveCode is null)
	AND (ClientExecutiveName like   ''+@ClientExecutiveName+'%'  or @ClientExecutiveName is null)
	AND (DepositBSB like   ''+@DepositBSB+'%'					or @DepositBSB is null)
	AND (DepositAccount  like   ''+@DepositAccount +'%'			or @DepositAccount is null)
	AND ((isnull(Address_line_1,'''') + isnull(Address_line_2, '''') + isnull(Address_line_3,'''')) like   '%'+@Address_Combined+'%'  OR @Address_Combined is null )
	AND ((isnull(Postal_Address_Line_1,'''') + isnull(Postal_Address_Line_2, '''') + isnull(Postal_Address_Line_3,'''')) like   '%'+@Postal_Address_Combined+'%'  OR @Postal_Address_Combined is null)
	AND EXISTS
		(
			select	1 FROM	dw_oamps.dbo.dds_fct_policytransaction dfp
			where 	dfp.clientcode = clientview.clientcode
			and (dfp.PolicyNo like '%'+@memorandumNumber+'%'				or 	@memorandumNumber   is null )
			and (dfp.underwriter_policy	like   ''+@uwPolicynumber+'%'	or	@uwPolicynumber  is null)
			and (dfp.invoice_number		like   ''+@invoicenumber+'%'	or	@invoicenumber  is null )
		)
  
 