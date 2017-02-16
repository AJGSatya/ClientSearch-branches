using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace ClientSearch.Code
{
    public static class Searcher
    {
        //private static readonly string _connectionString = ConfigurationManager.ConnectionStrings["ClientSearchDatabase"].ConnectionString;
        private static string _unitCodedefault = "(all)";
        
        private static DBNull _systemCodeDefault = DBNull.Value;
        private static string _ledgerCodeDefault = "(all)";
        private static DBNull _branchCodeDefault = DBNull.Value;
        private static DBNull _branchNameDefault = DBNull.Value;
        private static DBNull _localBranchCodeDefault = DBNull.Value;
        private static DBNull _clientCodeDefault = DBNull.Value;
        //private static string _clientNameDefault = DBNull.Value;
        private static DBNull _addressCombinedDefault = DBNull.Value;
        private static DBNull _postcodeDefault = DBNull.Value;
        private static DBNull _postalAddressCombinedDefault = DBNull.Value;
        private static DBNull _clientExecutiveCodeDefault = DBNull.Value;
        private static DBNull _clientExecutiveNameDefault = DBNull.Value;
        private static DBNull _uwPolicyNumberDefault = DBNull.Value;
        private static DBNull _memorandumNumberDefault = DBNull.Value;
        private static DBNull _invoicenumberDefault = DBNull.Value;
        private static DBNull _depositBSBDefault = DBNull.Value;
        private static DBNull _depositAccountDefault = DBNull.Value;
        

        /// <summary>
        /// 6 Sep 2016:KT: call sp 'sp_ClientSearch' instead of 'sp_shinny_ClientSearch'
        /// </summary>
        /// <param name="searchUnit"></param>
        /// <param name="searchLedger"></param>
        /// <param name="searchName"></param>
        /// <param name="searchAddress"></param>
        /// <param name="searchUnderWriterPolicyNo"></param>
        /// <param name="searchMemoNo"></param>
        /// <param name="searchInvoiceNo"></param>
        /// <param name="searchDepositBSB"></param>
        /// <param name="searchDepositAccount"></param>
        /// <param name="searchClientCode"></param>
        /// <returns></returns>
        public static List<Client> AdvancedSearchProc(
            string searchUnit,
            string searchLedger,
            string searchName,
            string searchAddress,
            string searchUnderWriterPolicyNo,
            string searchMemoNo,
            string searchInvoiceNo,
            string searchDepositBSB,
            string searchDepositAccount,
            string searchClientCode)
        {
            var command = new SqlCommand
            {
                CommandType = CommandType.StoredProcedure,
                CommandText = "[dbo].[sp_ClientSearch]"
            };

            var unitCodeParam = command.Parameters.Add("@UnitCode", SqlDbType.NChar);
            unitCodeParam.Value = string.IsNullOrEmpty(searchUnit) ? _unitCodedefault : searchUnit.Trim();
            
            var systemCodeParam = command.Parameters.Add("@SystemCode", SqlDbType.NChar);
            systemCodeParam.Value = _systemCodeDefault;

            var ledgerCodeParam = command.Parameters.Add("@LedgerCode", SqlDbType.NChar);
            ledgerCodeParam.Value = string.IsNullOrEmpty(searchLedger) ? _ledgerCodeDefault : searchLedger.Trim();

            var branchCodeParam = command.Parameters.Add("@BranchCode", SqlDbType.NChar);
            branchCodeParam.Value = _branchCodeDefault;

            var localbranchCodeParam = command.Parameters.Add("@Local_BranchCode", SqlDbType.NChar);
            localbranchCodeParam.Value = _localBranchCodeDefault;

            //var searchClientCodeParam = command.Parameters.Add("@ClientCode", SqlDbType.NChar);
            //searchClientCodeParam.Value = string.IsNullOrEmpty(searchClientCode) ? null : searchClientCode.Trim();

            if (!string.IsNullOrEmpty(searchClientCode))
            {
                var searchClientCodeParam = command.Parameters.Add("@ClientCode", SqlDbType.NVarChar);
                searchClientCodeParam.Value = searchClientCode.Trim();
            }   
            else
            {
                var searchClientCodeParam = command.Parameters.Add("@ClientCode", SqlDbType.NVarChar);
                searchClientCodeParam.Value = DBNull.Value;
            }

            //var clientNameParam = command.Parameters.Add("@ClientName", SqlDbType.NChar);
            //clientNameParam.Value = string.IsNullOrEmpty(searchName) ? null : searchName.Trim();

            if (!string.IsNullOrEmpty(searchName))
            {
                var clientNameParam = command.Parameters.Add("@ClientName", SqlDbType.NVarChar);
                clientNameParam.Value = searchName.Trim();
            }
            else
            {
                var clientNameParam = command.Parameters.Add("@ClientName", SqlDbType.NVarChar);
                clientNameParam.Value = DBNull.Value;
            }

            var addressCombinedParam = command.Parameters.Add("@Address_Combined", SqlDbType.NChar);
            if (string.IsNullOrEmpty(searchAddress))
                addressCombinedParam.Value = _addressCombinedDefault;
            else
                addressCombinedParam.Value = searchAddress.Trim();
            
            var postcodeParam = command.Parameters.Add("@Postcode", SqlDbType.NChar);
            postcodeParam.Value = _postcodeDefault;

            var postalAddressCombinedParam = command.Parameters.Add("@Postal_Address_Combined", SqlDbType.NChar);
            postalAddressCombinedParam.Value = _postalAddressCombinedDefault;

            var clientExecutiveCodeParam = command.Parameters.Add("@ClientExecutiveCode", SqlDbType.NChar);
            clientExecutiveCodeParam.Value = _clientExecutiveCodeDefault;

            var clientExecutiveNameParam = command.Parameters.Add("@ClientExecutiveName", SqlDbType.NChar);
            clientExecutiveNameParam.Value = _clientExecutiveNameDefault;

            var uwPolicyNumberParam = command.Parameters.Add("@uwPolicyNumber", SqlDbType.NChar);
            if (string.IsNullOrEmpty(searchUnderWriterPolicyNo))
                uwPolicyNumberParam.Value = _uwPolicyNumberDefault;
            else
                uwPolicyNumberParam.Value = searchUnderWriterPolicyNo.Trim();

            var memorandumNumberParam = command.Parameters.Add("@MemorandumNumber", SqlDbType.NChar);
            if (string.IsNullOrEmpty(searchMemoNo))
                memorandumNumberParam.Value = _memorandumNumberDefault;
            else
                memorandumNumberParam.Value = searchMemoNo.Trim();

            var invoiceNumberParam = command.Parameters.Add("@invoicenumber", SqlDbType.NChar);
            if (string.IsNullOrEmpty(searchInvoiceNo))
                invoiceNumberParam.Value = _invoicenumberDefault;
            else
                invoiceNumberParam.Value = searchInvoiceNo.Trim();

            var depositBsbParam = command.Parameters.Add("@DepositBSB", SqlDbType.NChar);
            if (string.IsNullOrEmpty(searchDepositBSB))
                depositBsbParam.Value = _depositBSBDefault;
            else
                depositBsbParam.Value = searchDepositBSB.Trim();

            var depositAccountParam = command.Parameters.Add("@DepositAccount", SqlDbType.NChar);
            if (string.IsNullOrEmpty(searchDepositAccount))
                depositAccountParam.Value = _depositAccountDefault;
            else
                depositAccountParam.Value = searchDepositAccount.Trim();

            return GetClients(command);
        }

        
        private static List<Client> GetClients(SqlCommand cmd)
        {
            System.Collections.Generic.List<Client> clients = new System.Collections.Generic.List<Client>();

            string connString = ConfigurationManager.ConnectionStrings["ClientSearchDatabase"].ConnectionString;

            using (SqlConnection cn = new SqlConnection(connString))
            {
                cmd.Connection = cn;
                cn.Open();
                
                DataSet ds = new DataSet();
                DataTable table = new DataTable();
                
                var reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                table.Load(reader);
                ds.Tables.Add(table);

                foreach (DataRow dr in table.Rows)
                {
                    Client c = new Client
                    {
                        Unit = dr["UnitCode"].ToString(),
                        Name = dr["ClientName"].ToString(),
                        AccountExecutive = dr["ClientExecutiveCode"].ToString(),
                        AccountExecutiveName = dr["ClientExecutiveName"].ToString(),
                        AddressLine1 = dr["Address_Line_1"].ToString(),
                        AddressLine2 = dr["Address_Line_2"].ToString(),
                        AddressLine3 = dr["Address_Line_3"].ToString(),
                        BranchCode = dr["BranchCode"].ToString(),
                        BranchName = dr["BranchCode"].ToString(), //name isfield branchcode
                        LocalBranchCode = dr["Local_BranchCode"].ToString(),
                        ClientCode = dr["ClientCode"].ToString(),
                        LedgerCode = dr["LedgerCode"].ToString(),
                        RetailWholesale = dr["Retail_Wholesale"].ToString(),
                        Operation = dr["Operation"].ToString(),
                        ContactMethod = dr["Contact_Method"].ToString(),
                        ContactPreference = dr["Contact_Preference"].ToString(),
                        TeamCode = dr["TeamCode"].ToString(),
                        PostalAddressLine1 = dr["Postal_Address_Line_1"].ToString(),
                        PostalAddressLine2 = dr["Postal_Address_Line_2"].ToString(),
                        PostalAddressLine3 = dr["Postal_Address_Line_3"].ToString(),
                        ContactComments = dr["Contact_Comments"].ToString()
                    };

                    if (!string.IsNullOrEmpty(dr["Commence_Date"].ToString()))
                        c.CommenceDate = Convert.ToDateTime(dr["Commence_Date"]);
                    else
                        c.CommenceDate = null;

                    if (!string.IsNullOrEmpty(dr["Renewal_Date"].ToString()))
                        c.NextRenewalDate = Convert.ToDateTime(dr["Renewal_Date"]);
                    else
                        c.NextRenewalDate = null;

                    if (!string.IsNullOrEmpty(dr["Last_Transaction_Date"].ToString()))
                        c.LastTransactionDate = Convert.ToDateTime(dr["Last_Transaction_Date"]);
                    else
                        c.LastTransactionDate = null;

                    clients.Add(c);
                }

                cn.Close();

            }

            return clients;
        }
    }
}