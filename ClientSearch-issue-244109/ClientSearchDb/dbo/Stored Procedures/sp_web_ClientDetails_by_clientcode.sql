


/****** Object:  Stored Procedure dbo.sp_web_ClientDetails_by_clientcode    Script Date: 23/12/2004 11:05:04 AM ******/

-- 23 jan 2007 Swanston: increased length of ledgercode and branchcode 
-- 12 Nov 2004 Michael Mackowiak: initial release

CREATE  PROCEDURE [dbo].[sp_web_ClientDetails_by_clientcode]

(
	@UID	integer output,
	@UnitCode varchar(20) output,
	@SystemCode varchar(20) output,
	@LedgerCode varchar(100) output,
	@BranchCode varchar(50) output,
	@Local_BranchCode varchar(20) output,
	@ClientCode varchar(100),
	@ClientName varchar(255) output,
	@Address_Line1 varchar(255) output,
	@Address_Line2 varchar(255) output,
	@Address_Line3 varchar(255) output,
	@Suburb varchar(255) output,
	@Postcode varchar(255) output,
	@Postal_Address_Line1 varchar(255) output,
	@Postal_Address_Line2 varchar(255) output,
	@Postal_Address_Line3 varchar(255) output,
	@Postal_Suburb varchar(255) output,
	@Addressee varchar(255) output,
	@Salutation varchar(255) output,
	@Gender varchar(30) output,
	@ClientExecutiveCode varchar(50) output,
	@Phone varchar(255) output,
	@Fax varchar(255) output,
	@Mobile varchar(255) output,
	@ABN varchar(255) output,
	@Retail_Wholesale varchar(255) output,
	@ContactMethod varchar(255) output,
	@ContactPreference varchar(255) output,
	@ContactComments varchar(255) output,
	@Operation varchar(255) output,
	@CommenceDate smalldatetime output,
	@AssociationCode varchar(100) output,
	@LastUpdated smalldatetime output,
	@ProcessKey int output

)

AS

	SELECT

	@UID = UID,
	@SystemCode = SystemCode,
	@LedgerCode = LedgerCode,
	@BranchCode  = BranchCode,
	@Local_BranchCode = Local_BranchCode,
	@ClientCode = ClientCode,
	@ClientName = ClientName,
	@Address_Line1 = Address_Line_1,
	@Address_Line2 = Address_Line_2,
	@Address_Line3 = Address_Line_3,
	@Suburb = Suburb,
	@Postcode = Postcode,
	@Postal_Address_Line1 = Postal_Address_Line_1,
	@Postal_Address_Line2 = Postal_Address_Line_2,
	@Postal_Address_Line3 = Postal_Address_Line_3,
	@Postal_Suburb = Postal_Suburb,
	@Addressee = Addressee,
	@Salutation = Salutation,
	@Gender = Gender,
	@ClientExecutiveCode = ClientExecutiveCode,
	@Phone = Phone,
	@Fax = Fax,
	@Mobile = Mobile,
	@ABN = ABN,
	@Retail_Wholesale = Retail_Wholesale,
	@ContactMethod = Contact_Method,
	@ContactPreference = Contact_Preference,
	@ContactComments = Contact_Comments,
	@Operation = Operation,
	@CommenceDate = Commence_Date,
	@AssociationCode = Association_Code,
	@LastUpdated = Last_Updated,
	@ProcessKey = Process_Key

	FROM
		cds_oamps_clients

	WHERE
		UPPER(clientcode) = UPPER(@clientcode)

