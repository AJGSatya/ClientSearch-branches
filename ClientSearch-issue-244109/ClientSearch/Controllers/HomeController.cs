using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using ClientSearch.Code;
using ClientSearch.Models;

namespace ClientSearch.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index(string sort = "", string sortdir = "", string searchText = "")
        {
            ViewBag.ddlSearchUnit = GetItemsUnit(string.Empty);
            ViewBag.ddlSearchLedger = GetItemsLedger(string.Empty);

            ClientSearchViewModel model;

            if (string.IsNullOrEmpty(sort) && string.IsNullOrEmpty(sortdir) && string.IsNullOrEmpty(searchText))
            {
                ViewBag.ShowAdvancedSearch = "hideAdvancedSearch"; //standard
                model = new ClientSearchViewModel();
            }
            else
            {
                model = DoSort(sort, sortdir);
            }

            return View(model);
        }

        private ClientSearchViewModel DoSort(string sort, string sortdir)
        {
            ClientSearchViewModel model;
            var cache = new DefaultCacheProvider();
            var cacheKey = Request.LogonUserIdentity.Name;
            var cachedModel = cache.Get(cacheKey);
            if (cachedModel == null)
                model = new ClientSearchViewModel();
            else
            {
                model = (ClientSearchViewModel) cachedModel;

                sortdir = string.IsNullOrEmpty(sortdir) ? "asc" : sortdir;
                sort = string.IsNullOrEmpty(sort) ? "name" : sort;

                if (string.Equals(model.SortField, sort, StringComparison.CurrentCultureIgnoreCase))
                    model.SortDirection = string.Equals(sortdir.ToLowerInvariant(), "asc") ? "desc" : "asc";
                model.SortField = sort;

                switch (sort.ToLowerInvariant())
                {
                    case "unit":
                    {
                        model.SearchResults = string.Equals(model.SortDirection, "asc")
                            ? model.SearchResults.OrderBy(x => x.Unit)
                            : model.SearchResults.OrderByDescending(x => x.Unit);
                        break;
                    }
                    case "ledger code":
                    {
                        model.SearchResults = string.Equals(model.SortDirection, "asc")
                            ? model.SearchResults.OrderBy(x => x.LedgerCode)
                            : model.SearchResults.OrderByDescending(x => x.LedgerCode);
                        break;
                    }
                    case "name":
                    {
                        model.SearchResults = string.Equals(model.SortDirection, "asc")
                            ? model.SearchResults.OrderBy(x => x.Name)
                            : model.SearchResults.OrderByDescending(x => x.Name);
                        break;
                    }
                    case "client code":
                    {
                        model.SearchResults = string.Equals(model.SortDirection, "asc")
                            ? model.SearchResults.OrderBy(x => x.ClientCode)
                            : model.SearchResults.OrderByDescending(x => x.ClientCode);
                        break;
                    }
                    case "account executive":
                    {
                        model.SearchResults = string.Equals(model.SortDirection, "asc")
                            ? model.SearchResults.OrderBy(x => x.AccountExecutive)
                            : model.SearchResults.OrderByDescending(x => x.AccountExecutive);
                        break;
                    }
                }
            }
            return model;
        }

        [HttpPost]
        public ActionResult Index(FormCollection form)
        {
            ViewBag.ddlSearchUnit = GetItemsUnit(string.Empty);
            ViewBag.ddlSearchLedger = GetItemsLedger(string.Empty);

            var searchText = form["txtSearchText"].Trim();
            var model = new ClientSearchViewModel
            {
                SearchText = searchText,
                SearchUnit = form["ddlSearchUnit"],
                SortField = form["SortField"],
                SortDirection = form["SortDirection"]
            };

            ViewBag.ShowAdvancedSearch = form["hidIsAdvanced"].Trim();
            form["hidIsAdvanced"] = ViewBag.ShowAdvancedSearch;

            ViewBag.txtSearchText = searchText;
            var searchUnit = form["ddlSearchUnit"];
            var searchLedger = form["ddlSearchLedger"];
            var searchName = form["txtSearchText"];
            var searchClientCode = form["txtSearchClientCode"];
            var searchAddress = form["txtSearchAddress"];
            var searchUnderWriterPolicyNo = form["txtSearchUnderWriterPolicyNo"];
            var searchMemoNo = form["txtSearchMemoNo"];
            var searchInvoiceNo = form["txtSearchInvoiceNo"];
            var searchDepositBsb = form["txtSearchDepositBSB"];
            var searchDepositAccount = form["txtSearchDepositAccount"];

            var clientFromAdvancedSearch = Searcher.AdvancedSearchProc(searchUnit,
                searchLedger,
                searchName,
                searchAddress,
                searchUnderWriterPolicyNo,
                searchMemoNo,
                searchInvoiceNo,
                searchDepositBsb,
                searchDepositAccount,
                searchClientCode);

            model.SearchResults = clientFromAdvancedSearch;

            var cache = new DefaultCacheProvider();
            if (Request.LogonUserIdentity != null)
            {
                var cacheKey = Request.LogonUserIdentity.Name;
                cache.Set(cacheKey, model, 30);
            }

            //reset fields for reshowing
            ViewBag.ddlSearchUnit = GetItemsUnit(searchUnit);
            ViewBag.ddlSearchLedger = GetItemsLedger(searchLedger);
            ViewBag.txtSearchName = searchName;
            ViewBag.txtSearchAddress = searchAddress;
            ViewBag.txtSearchUnderWriterPolicyNo = searchUnderWriterPolicyNo;
            ViewBag.txtSearchMemoNo = searchMemoNo;
            ViewBag.txtSearchInvoiceNo = searchInvoiceNo;
            ViewBag.txtSearchDepositBSB = searchDepositBsb;
            ViewBag.txtSearchDepositAccount = searchDepositAccount;
            ViewBag.txtSearchClientCode = searchClientCode;
            return View(model);
        }

        private List<SelectListItem> GetItemsUnit(string valueSelected)
        {
            var items = new List<SelectListItem>();

            items.Add(new SelectListItem { Text = string.Empty, Selected = (valueSelected == string.Empty) });
            items.Add(new SelectListItem { Text = "OIB", Selected = (valueSelected == "OIB") });

            return items;
        }

        private List<SelectListItem> GetItemsLedger(string valueSelected)
        {
            var items = new List<SelectListItem>
            {
                new SelectListItem {Text = string.Empty, Selected = (valueSelected == string.Empty)},
                new SelectListItem {Text = "AJG.BLUE", Selected = (valueSelected == "AJG.BLUE")},
                new SelectListItem {Text = "AJG.COR", Selected = (valueSelected == "AJG.COR")},
                new SelectListItem {Text = "AJG.INSTRAT", Selected = (valueSelected == "AJG.INSTRAT")},
                new SelectListItem {Text = "AJG.STR", Selected = (valueSelected == "AJG.STR")},
                new SelectListItem {Text = "OAM.ACT", Selected = (valueSelected == "OAM.ACT")},
                new SelectListItem {Text = "OAM.CGM", Selected = (valueSelected == "OAM.CGM")},
                new SelectListItem {Text = "OAM.CRED", Selected = (valueSelected == "OAM.CRED")},
                new SelectListItem {Text = "OAM.DUB", Selected = (valueSelected == "OAM.DUB")},
                new SelectListItem {Text = "OAM.GAK", Selected = (valueSelected == "OAM.GAK")},
                new SelectListItem {Text = "OAM.GAP", Selected = (valueSelected == "OAM.GAP")},
                new SelectListItem {Text = "OAM.JWL", Selected = (valueSelected == "OAM.JWL")},
                new SelectListItem {Text = "OAM.NEW", Selected = (valueSelected == "OAM.NEW")},
                new SelectListItem {Text = "OAM.NPL", Selected = (valueSelected == "OAM.NPL")},
                new SelectListItem {Text = "OAM.NSWC", Selected = (valueSelected == "OAM.NSWC")},
                new SelectListItem {Text = "OAM.NT", Selected = (valueSelected == "OAM.NT")},
                new SelectListItem {Text = "OAM.NTA", Selected = (valueSelected == "OAM.NTA")},
                new SelectListItem {Text = "OAM.OMP", Selected = (valueSelected == "OAM.OMP")},
                new SelectListItem {Text = "OAM.QLDC", Selected = (valueSelected == "OAM.QLDC")},
                new SelectListItem {Text = "OAM.QLDM", Selected = (valueSelected == "OAM.QLDM")},
                new SelectListItem {Text = "OAM.QLDT", Selected = (valueSelected == "OAM.QLDT")},
                new SelectListItem {Text = "OAM.SAM", Selected = (valueSelected == "OAM.SAM")},
                new SelectListItem {Text = "OAM.SYDM", Selected = (valueSelected == "OAM.SYDM")},
                new SelectListItem {Text = "OAM.SYDN", Selected = (valueSelected == "OAM.SYDN")},
                new SelectListItem {Text = "OAM.TAS", Selected = (valueSelected == "OAM.TAS")},
                new SelectListItem {Text = "OAM.VICB", Selected = (valueSelected == "OAM.VICB")},
                new SelectListItem {Text = "OAM.VICH", Selected = (valueSelected == "OAM.VICH")},
                new SelectListItem {Text = "OAM.VICM", Selected = (valueSelected == "OAM.VICM")},
                new SelectListItem {Text = "OAM.VICS", Selected = (valueSelected == "OAM.VICS")},
                new SelectListItem {Text = "OAM.VICW", Selected = (valueSelected == "OAM.VICW")},
                new SelectListItem {Text = "OAM.WA", Selected = (valueSelected == "OAM.WA")},
                new SelectListItem {Text = "OAM.WAB", Selected = (valueSelected == "OAM.WAB")},
                new SelectListItem {Text = "OAM.WAGG", Selected = (valueSelected == "OAM.WAGG")},
                new SelectListItem {Text = "OAM.WANG", Selected = (valueSelected == "OAM.WANG")}
            };

            return items;
        }
    }
}