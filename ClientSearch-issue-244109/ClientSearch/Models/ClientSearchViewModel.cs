using System.Collections.Generic;
using ClientSearch.Code;

namespace ClientSearch.Models
{
    public class ClientSearchViewModel
    {
        public ClientSearchViewModel()
        {
            SearchResults = new List<Client>();
            SortField = "Name";
            SortDirection = "ASC";
        }

        public IEnumerable<ClientSearch.Code.Client> SearchResults { get; set; }
        public string SearchText { get; set; }
        public string SearchUnit { get; set; }
        public string ClientCode { get; set; }
        public string SortField { get; set; }
        public string SortDirection { get; set; }
    }
}