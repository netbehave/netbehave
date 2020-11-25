using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using netbehave_wwwv2.Data;
using netbehave_wwwv2.Models;
using netbehave_wwwv2.Utils;

namespace netbehave_wwwv2.Controllers
{
    [Microsoft.AspNetCore.Mvc.Route("api/[controller]")]
    [ApiController]
    public class IpController : NetBehaveController<Ip>
    {
        // private readonly ILogger<IpController> _logger;
        // private nbv2Context _context;

        public IpController(ILogger<IpController> logger, nbv2Context context) : base(logger, context)
        {
            // _logger = logger;
            // _context = context;
        }


        /*
        [Microsoft.AspNetCore.Mvc.HttpGet] // /{ip:alpha}
        public IActionResult Index([FromQuery] UrlQueryMDBDataTables urlQueryMDBDataTables)
        {
            IEnumerable<Ip> pagelist = this._context.Set<Ip>();
            if (pagelist == null)
            {
                return NotFound();
            }

            UrlQuery urlQuery = new UrlQuery();
            PagedResults<Ip> results = getPageResults(pagelist, urlQuery);

            List<string> columns = new List<string>();
            columns.Add("Ip1");
            columns.Add("IpI");
            columns.Add("IpVersion");
            columns.Add("IdHostInfo");
            columns.Add("NetBlockName");
            MDBDataTable mdb = new MDBDataTable();
            mdb.columns = columns.ToArray();
            mdb.rows = new string[results.Results.Count<Ip>(), columns.Count];
            int row = 0;
            foreach (Ip ip in results.Results)
            {
                mdb.rows[row, 0] = ip.Ip1;
                mdb.rows[row, 1] = ip.IpI.ToString();
                mdb.rows[row, 2] = ip.IpVersion.ToString();
                mdb.rows[row, 3] = ip.IdHostInfo.ToString();
                mdb.rows[row, 4] = ip.NetBlockName;
                row++;
            }


            return Ok(mdb);

        }
        */

        // https://localhost:32772/api/ip/element?ip=192.168.0.10
        // https://localhost:32772/api/ip/element?SearchBy=ip&SearchValue=192.168.0.10
        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult ElementByIp([FromQuery] string value)
        {
            // object[] searchQuery = new object[] { urlElementQuery.SearchBy, urlElementQuery.SearchValue };
            // Ip ipa = _context.Ip.Find(ip); // ["ip",
            /*
            Ip
            var ipa = await _context.Ip.FindAsync(ip);  //(ip);


            */

            Ip ipa = null;
            try
            {
                long ipI = Int64.Parse(value);
                IEnumerable<Ip> pagelist = this._context.Ip.Where(ipa => ipa.IpI == ipI);
                if (pagelist.Count() > 0)
                {
                    ipa = pagelist.First<Ip>();
                }
            }
            catch (Exception)
            {
                ipa = _context.Ip.Find(value);

            }
            if (ipa == null)
            {
                IEnumerable<Ip> pagelist = this._context.Ip.Where(ipa => ipa.Ip1 == value);
                if (pagelist.Count() > 0)
                {
                    ipa = pagelist.First<Ip>();
                }

            }
            // Ip ipa = _context.Ip.Find(value);
            if (ipa == null)
            {
                return NotFound();
            }
            loadExtra(ipa);
            return Ok(ipa);
        }

        private void loadExtra(Ip ipa)
        {


            var queryHIP =
    from hip in _context.HostInfoIp
    join hi in _context.HostInfo on hip.IdHostInfo equals hi.IdHostInfo
    where hip.Ip == ipa.Ip1
    select hi;

            foreach (HostInfo hi in queryHIP)
            {


                ipa.HostInfo.Add(hi);
            }

            foreach(HostInfo hi in ipa.HostInfo)
            {
                var queryApp =
from appcohost in _context.AppComponentHost
join appco in _context.AppComponent on appcohost.ComponentId equals appco.ComponentId
join app in _context.AppInfo on appco.IdAppInfo equals app.IdAppInfo
where appcohost.IdHostInfo == hi.IdHostInfo
select app;

                foreach (AppInfo app in queryApp)
                {
                    hi.AppInfo.Add(app);
                }
            }

            /*
            var uniqueCategories =
   (from fs in this._context.FlowSummary
    where (fs.Srcip == ipa.Ip1 || fs.Dstip == ipa.Ip1)
    select mult=>
    { fs.Cat, fs.Subcat}).Distinct().OrderBy(cat => cat).OrderBy(subcat => subcat).ToList();
            foreach (string cat in uniqueCategories)
            {
                string [] cat_subcat = new string[ ] { mult.cat }
                ipa.Categories.Add(mult);
            }
            /**/
            var distinctCatSubcat = this._context.FlowSummary
                .Select(fs => new { fs.Cat, fs.Subcat, fs.IdFlowCategories})
                .Distinct()
                .ToList();
            foreach(var CatSubcat in distinctCatSubcat)
            {
                string[] cat_subcat = new string[] { CatSubcat.Cat, CatSubcat.Subcat, CatSubcat.IdFlowCategories == null ? "" : CatSubcat.IdFlowCategories.ToString() };
                ipa.Categories.Add(cat_subcat);
            }
        }


        // https://localhost:32772/api/ip/search?SearchBy=ip1&SearchValue=.0.1&SearchType=contains
        // https://localhost:32772/api/ip/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlSearchQuery)
        {
            IEnumerable<Ip> pagelist = pagelistSearch(urlSearchQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<Ip> results = getPageResults(pagelist, urlSearchQuery);

            return Ok(results);
        }


        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<Ip> pagelist = null;
            string orderBy = urlQuery.OrderBy;
            if (orderBy == null) { orderBy = "ip"; }

            switch (orderBy)
            {
                case "ip1":
                case "ipi":
                case "ip_i":
                case "ip":
                    pagelist = this._context.Set<Ip>().OrderBy(ip => ip.IpI);
                    break;
                default:
                    break;
            }

            if (pagelist == null)
            {
                pagelist = this._context.Set<Ip>().OrderBy(ip => ip.IpI);
            }

            if (pagelist == null)
            {
                return NotFound();
            }


            PagedResults<Ip> results = getPageResults(pagelist, urlQuery);

            return Ok(results);
        }


        protected override IEnumerable<Ip> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<Ip> pagelist = null;

            switch (urlQuery.SearchBy.ToLower())
            {
                case "netblockname":
                    if (urlQuery.SearchType == "contains")
                    {
                        pagelist = this._context.Ip.Where(ip => ip.NetBlockName.ToLower().Contains(urlQuery.SearchValue.ToLower())).OrderBy(ip => ip.IpI);

                    }
                    else
                    {
                        pagelist = this._context.Ip.Where(ip => ip.NetBlockName == urlQuery.SearchValue).OrderBy(ip => ip.IpI);
                    }
                    break;
                case "ip1":
                default:
                    if (urlQuery.SearchType == "contains")
                    {
                        pagelist = this._context.Ip.Where(ip => ip.Ip1.Contains(urlQuery.SearchValue)).OrderBy(ip => ip.IpI);

                    }
                    else
                    {
                        pagelist = this._context.Ip.Where(ip => ip.Ip1 == urlQuery.SearchValue).OrderBy(ip => ip.IpI); ;
                    }
                    break;
            }
            return pagelist;
        }



        /*
        using (SqlConnection connection = new SqlConnection(_connectionString))
        {
            connection.Open();

            string sql = @"SELECT ContactId, Title, FirstName, Surname FROM Contact";

            if (urlQuery.PageNumber.HasValue) { sql += @" ORDER BY Contact.ContactPK                OFFSET @PageSize * (@PageNumber - 1) ROWS                FETCH NEXT @PageSize ROWS ONLY"; }
            contacts = connection.Query<Contact>(sql, urlQuery);
        }
        */
        /*
        protected PagedResults<Ip> getPageResults(IEnumerable<Ip> pagelist, UrlQuery urlQuery)
        {
            UrlQuery query = urlQuery;
            if (query == null)
            {
                query = new UrlQuery();
            }
            int pageNumber = 0;
            if (query.PageNumber != null)
            {
                pageNumber = (int)query.PageNumber;
            }

            PagedResults<Ip> results = new PagedResults<Ip>();
            results.PageNumber = pageNumber;
            results.PageSize = query.PageSize;
            results.TotalNumberOfRecords = pagelist.Count<Ip>();
            results.TotalNumberOfPages = (results.TotalNumberOfRecords / results.PageSize) + (results.TotalNumberOfRecords % results.PageSize == 0 ? 0 : 1);
            results.Results = pagelist.ToPagedList(pageNumber + 1, query.PageSize);
            // 
            return results;
        }
            /*
            if (pageNumber < results.TotalNumberOfRecords)
            {
                results.NextPageUrl = "?PageNumber=" + (pageNumber + 1) + "&PageSize=" + results.PageSize;
            }
            if (pageNumber > 0)
            {
                results.PrevPageUrl = "?PageNumber=" + (pageNumber - 1) + "&PageSize=" + results.PageSize;
            }
            */


        /*
// return all
public IEnumerable<Ip> Get() // , int pageSize = 5
{
    return _context.Ip;
}


// GET: api/Ip/5
[Microsoft.AspNetCore.Mvc.HttpGet("item")] // /{ip:alpha}
public async Task<ActionResult<Ip>> GetIp(string ip)
{
    var ipa = await _context.Ip.FindAsync(ip);  //(ip);

    if (ipa == null)
    {
        return NotFound();
    }

    return ipa;
}
// GET: api/Ip/page
// [HttpGet("page/{id}")]
[Microsoft.AspNetCore.Mvc.HttpGet("page/{page:int}")]
// [HttpGet]
public IEnumerable<Ip> Page(int page = 0) // , int pageSize = 5
{
    return getPage(page); //  _context.Ip;
}

protected IEnumerable<Ip> getPage(int? page)
{
    // var products = MyProductDataSource.FindAllProducts(); //returns IQueryable<Product> representing an unknown number of products. a thousand maybe?
    var ips = this._context.Set<Ip>();
    var pageSize = 10;

    var pageNumber = page ?? 1; // if no page was specified in the querystring, default to the first page (1)
    var onePageOfProducts = ips.ToPagedList(pageNumber, pageSize); // will only contain 25 products max because of the pageSize
    return onePageOfProducts;
    // ViewBag.OnePageOfProducts = onePageOfProducts;
    // return View();
}
*/

        /* 
        public async Task<IHttpActionResult> Get(int? page = null, int pageSize = 10, string orderBy = nameof(Ip.Ip1), bool ascending = true)
        {
            if (page == null)
                return (IHttpActionResult)Ok(await _context.Ip.ToListAsync());

            var ips = await CreatePagedResults<Ip, nbv2Context.Ip>
                (_context.Ip, page.Value, pageSize, orderBy, ascending);
            return (IHttpActionResult)Ok(ips);
        }

        /// <summary>
        /// Creates a paged set of results.
        /// </summary>
        /// <typeparam name="T">The type of the source IQueryable.</typeparam>
        /// <typeparam name="TReturn">The type of the returned paged results.</typeparam>
        /// <param name="queryable">The source IQueryable.</param>
        /// <param name="page">The page number you want to retrieve.</param>
        /// <param name="pageSize">The size of the page.</param>
        /// <param name="orderBy">The field or property to order by.</param>
        /// <param name="ascending">Indicates whether or not the order should be ascending (true) or descending (false.)</param>
        /// <returns>Returns a paged set of results.</returns>
        protected async Task<PagedResults<TReturn>> CreatePagedResults<T, TReturn>(
            IQueryable<T> queryable,
            int page,
            int pageSize,
            string orderBy,
            bool ascending)
        {
            var skipAmount = pageSize * (page - 1);

            var projection = queryable
                .OrderByPropertyOrField(orderBy, ascending)
                .Skip(skipAmount)
                .Take(pageSize).ProjectTo<TReturn>();

            var totalNumberOfRecords = await queryable.CountAsync();
            var results = await projection.ToListAsync();

            var mod = totalNumberOfRecords % pageSize;
            var totalPageCount = (totalNumberOfRecords / pageSize) + (mod == 0 ? 0 : 1);

            var nextPageUrl =
            page == totalPageCount
                ? null
                : Url?.Link("DefaultApi", new
                {
                    page = page + 1,
                    pageSize,
                    orderBy,
                    ascending
                });

            return new PagedResults<TReturn>
            {
                Results = results,
                PageNumber = page,
                PageSize = results.Count,
                TotalNumberOfPages = totalPageCount,
                TotalNumberOfRecords = totalNumberOfRecords,
                NextPageUrl = nextPageUrl
            };
        }
        /* */


        /*
        public async Task<IEnumerable<Ip>> FindPaged<Ip>(int page, int pageSize)
        {
            return await GetPagedNames(page).ToPagedListAsync(page, pageSize);
        }

        protected IPagedList<Ip> GetPagedNames(int? page)
        {
            // return a 404 if user browses to before the first page
            if (page.HasValue && page < 1)
                return null;

            // retrieve list from database/whereverand
            var listUnpaged = this._context.Set<Ip>();

            // page the list
            const int pageSize = 20;
            var listPaged = listUnpaged.ToPagedList(page ?? 1, pageSize);

            // return a 404 if user browses to pages beyond last page. special case first page if no items exist
            if (listPaged.PageNumber != 1 && page.HasValue && page > listPaged.PageCount)
                return null;

            return listPaged;
        }

        // in this case we return IEnumerable<string>, but in most
        // - DB situations you'll want to return IQueryable<string>
        protected IEnumerable<string> GetStuffFromDatabase()
        {
            var sampleData = System.IO.File.ReadAllText("Names.txt");
            return sampleData.Split('\n');
        }

        /*
        Task&lt;IEnumerable&lt;T&gt;&gt; FindPaged&lt;T&gt;(int page, int pageSize) where T : class;
        Task<IEnumerable<T>> FindPaged<T>(int page, int pageSize) where T : class;

        public async Task&lt;IEnumerable&lt;T&gt;&gt; FindPaged&lt;T&gt;(int page, int pageSize) where T : class
                {
            return await this.dbContext.Set&lt;T&gt;().ToPagedListAsync(page, pageSize);
        }
        */
    }
}
