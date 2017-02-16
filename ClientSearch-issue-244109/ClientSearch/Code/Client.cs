using System;
using System.Linq;
using System.Web;

namespace ClientSearch.Code
{
    public class Client
    {
        public string Unit { get; set; }
        public string Name { get; set; }

        //[dw_oamps].[dbo].[dds_dim_executive]
        public string AccountExecutive { get; set; }

        //[dw_oamps].[dbo].[dds_dim_executive]
        public string AccountExecutiveName { get; set; }

        public string AddressLine1{ get; set; }
        public string AddressLine2 { get; set; }
        public string AddressLine3 { get; set; }

        public string BranchCode { get; set; }

        public string LocalBranchCode { get; set; }

        public string BranchName { get; set; }

        public string ClientCode { get; set; }
        public string LedgerCode { get; set; }
        public string RetailWholesale { get; set; }
        public string Operation { get; set; }
        public string ContactMethod { get; set; }
        public DateTime? CommenceDate { get; set; }
        public string ContactPreference { get; set; }
        public string TeamCode { get; set; }
        public DateTime? NextRenewalDate { get; set; }
        public DateTime? LastTransactionDate { get; set; }
        public string PostalAddressLine1 { get; set; }
        public string PostalAddressLine2 { get; set; }
        public string PostalAddressLine3 { get; set; }
        public string ContactComments { get; set; }

    }
}