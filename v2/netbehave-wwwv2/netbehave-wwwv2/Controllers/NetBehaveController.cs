using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using netbehave_wwwv2.Data;
using netbehave_wwwv2.Utils;
using X.PagedList;

namespace netbehave_wwwv2.Controllers
{
    // [Microsoft.AspNetCore.Mvc.Route("api/[controller]")]
    public abstract class NetBehaveController<T> : ControllerBase where T : class
    {
        protected readonly ILogger<NetBehaveController<T>> _logger;
        protected nbv2Context _context;

        public NetBehaveController(ILogger<NetBehaveController<T>> logger, nbv2Context context)
        {
            _logger = logger;
            _context = context;
        }

        protected abstract IEnumerable<T> pagelistSearch(UrlSearchQuery urlQuery);

        protected PagedResults<T> getPageResults(IEnumerable<T> pagelist, UrlQuery urlQuery)
        {
            UrlQuery query = urlQuery;
            int pageNumber = 0;
            if (query != null)
            {
                if (query.PageNumber != null)
                {
                    pageNumber = (int)query.PageNumber;
                }
            } else
            {
                query = new UrlQuery();
            }

            PagedResults<T> results = new PagedResults<T>();
            results.PageNumber = pageNumber;
            results.PageSize = query.PageSize;
            results.TotalNumberOfRecords = pagelist.Count<T>();
            results.TotalNumberOfPages = (results.TotalNumberOfRecords / results.PageSize) + (results.TotalNumberOfRecords % results.PageSize == 0 ? 0 : 1);
            results.Results = pagelist.ToPagedList(pageNumber + 1, query.PageSize);

            // 
            /*W
            if (pageNumber < results.TotalNumberOfRecords)
            {
                results.NextPageUrl = "?PageNumber=" + (pageNumber + 1) + "&PageSize=" + results.PageSize;
            }
            if (pageNumber > 0)
            {
                results.PrevPageUrl = "?PageNumber=" + (pageNumber - 1) + "&PageSize=" + results.PageSize;
            }
            */
            return results;
        }
        /*
        protected IEnumerable<T> getPage(int? page)
        {
            // IEnumerable<T> list = this._context.Set<T>();
            return null;
        }
        protected IEnumerable<T> getPage(int? page)
        {
            // var products = MyProductDataSource.FindAllProducts(); //returns IQueryable<Product> representing an unknown number of products. a thousand maybe?
            var ips = this._context.Set<T>();
            var pageSize = 10;

            var pageNumber = page ?? 1; // if no page was specified in the querystring, default to the first page (1)
            var onePageOfProducts = ips.ToPagedList(pageNumber, pageSize); // will only contain 25 products max because of the pageSize
            return onePageOfProducts;
            // ViewBag.OnePageOfProducts = onePageOfProducts;
            // return View();
        }
        */

        /*
[Microsoft.AspNetCore.Mvc.HttpGet("list")]
public IActionResult List([FromQuery] UrlQuery urlQuery)
{
    IEnumerable<T> pagelist = null;
    // this._context.T();

    if (pagelist == null)
    {
        return NotFound();
    }

    PagedResults<T> results = getPageResults(pagelist, urlQuery);

    return Ok(results);
}
/*
using (SqlConnection connection = new SqlConnection(_connectionString))
{
    connection.Open();

    string sql = @"SELECT ContactWId, Title, FirstName, Surname FROM Contact";

    if (urlQuery.PageNumber.HasValue) { sql += @" ORDER BY Contact.ContactPK                OFFSET @PageSize * (@PageNumber - 1) ROWS                FETCH NEXT @PageSize ROWS ONLY"; }
    contacts = connection.Query<Contact>(sql, urlQuery);
}
*/

    }
}
