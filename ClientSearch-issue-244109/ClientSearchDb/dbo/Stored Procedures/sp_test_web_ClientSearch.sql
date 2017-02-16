

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
/*
exec [sp_web_ClientSearch] @UnitCode = '(all)', @SystemCode = NULL, @LedgerCode = '(all)', @BranchCode = NULL, @Local_BranchCode = NULL, @ClientCode = NULL, @ClientName = 'Australian Hearing', @Address_Combined = NULL, 
@Postcode = NULL, @Postal_Address_Combined = NULL, @ClientExecutiveCode = NULL, @uwPolicyNumber = NULL, @MemorandumNumber = null, 
@InvoiceNumber = NULL
*/
CREATE       PROCEDURE [dbo].[sp_test_web_ClientSearch]

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
	@uwPolicyNumber	[varchar](50),
	@MemorandumNumber [varchar](50),
    @invoicenumber [varchar] (50)
   ,@DepositBSB		[varchar] (20)
   ,@DepositAccount [varchar] (50)

AS
declare @sqlstring varchar(8000)

set @memorandumNumber	= replace(@memorandumNumber,'%','')
set @uwPolicynumber		= replace(@uwPolicynumber,'%','')
set @invoicenumber		= replace(@invoicenumber,'%','')


set @clientname = replace(@clientname, char(39), '''''')

set @sqlstring = '
	SELECT top 20	ClientView.*                   
 	FROM	ClientView		
	WHERE  '  + char(10)

-- Parameters from dds_fct_policytransaction
if		(@memorandumNumber	is null or len(ltrim(@memorandumNumber)) = 0)
	and (@uwPolicynumber	is null or len(ltrim(@uwPolicynumber)) = 0)
	and (@invoicenumber		is null or len(ltrim(@invoicenumber)) = 0)
  begin
	set @sqlstring = @sqlstring + '2>0'
  end
else 
  begin
	set @sqlstring = @sqlstring +
	'	EXISTS (
			select	1 FROM	dw_oamps.dbo.dds_fct_policytransaction dfp
			where 	dfp.clientcode = clientview.clientcode'+ char(10)
	if @memorandumNumber is not null set @sqlstring = @sqlstring + 'and dfp.PolicyNo like ''%'+@memorandumNumber+'%''' + char(10)
	if @uwPolicynumber is not null set @sqlstring = @sqlstring + 'and dfp.underwriter_policy	like  '''+@uwPolicynumber+'%''' + char(10)
	if @invoicenumber is not null set @sqlstring = @sqlstring + 'and dfp.invoice_number		like  '''+@invoicenumber+'%''' + char(10)
	set @sqlstring = @sqlstring +')' + char(10)
  end
-- Parameters from dds_fct_policytransaction

if @unitcode <>'(all)' set @sqlstring = @sqlstring	 + ' AND unitcode like  '''+@unitcode+'%'''
if @SystemCode <>'(all)' set @sqlstring = @sqlstring + ' AND SystemCode like  '''+@SystemCode+'%'''
if @LedgerCode <>'(all)' set @sqlstring = @sqlstring + ' AND LedgerCode like  '''+@LedgerCode+'%'''
if @BranchCode <>'(all)' set @sqlstring = @sqlstring + ' AND BranchCode like  '''+@BranchCode+'%'''
if @Local_BranchCode <>'(all)' set @sqlstring = @sqlstring + ' AND Local_BranchCode like  '''+@Local_BranchCode+'%'''
if @ClientCode <>'(all)' set @sqlstring = @sqlstring + ' AND ClientCode like  ''%'+@ClientCode+'%'''
if @ClientName <>'(all)' set @sqlstring = @sqlstring + ' AND ClientName like  ''%'+@ClientName+'%'''
if @ClientExecutiveCode <>'(all)' set @sqlstring = @sqlstring + ' AND ClientExecutiveCode like  '''+@ClientExecutiveCode+'%'''
if @DepositBSB <>'(all)' set @sqlstring = @sqlstring + ' AND DepositBSB like  '''+@DepositBSB+'%'''
if @DepositAccount  <>'(all)' set @sqlstring = @sqlstring + ' AND DepositAccount  like  '''+@DepositAccount +'%'''
if @Address_Combined <>'(all)' set @sqlstring = @sqlstring + ' AND (isnull(Address_line_1,'''') + isnull(Address_line_2, '''') + isnull(Address_line_3,'''')) like  ''%'+@Address_Combined+'%'''
if @Postal_Address_Combined <>'(all)' set @sqlstring = @sqlstring + ' AND (isnull(Postal_Address_Line_1,'''') + isnull(Postal_Address_Line_2, '''') + isnull(Postal_Address_Line_3,'''')) like  ''%'+@Postal_Address_Combined+'%'''

execute (@sqlstring)
print @sqlstring







