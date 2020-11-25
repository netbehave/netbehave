using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using netbehave_wwwv2.Data;
using netbehave_wwwv2.Models;
using netbehave_wwwv2.Utils;

namespace netbehave_wwwv2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FlowCategoriesController :  NetBehaveController<FlowCategories>
    {
        public FlowCategoriesController(ILogger<FlowCategoriesController> logger, nbv2Context context) : base(logger, context)
        {
            // _logger = logger;
            // _context = context;
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult Element([FromQuery] int id)
        {
            FlowCategories fc = _context.FlowCategories.Find(id);

            if (fc == null)
            {
                return NotFound();
            }
            // loadExtra(fs);
            return Ok(fc);
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<FlowCategories> pagelist = this._context.Set<FlowCategories>().OrderBy(fc => fc.Cat).OrderBy(fc => fc.Subcat);
            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<FlowCategories> results = getPageResults(pagelist, urlQuery);
            return Ok(results);
        }

        // https://localhost:32772/api/host/search?SearchBy=ip1&SearchValue=.0.1&SearchType=contains
        // https://localhost:32772/api/host/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlQuery)
        {
            IEnumerable<FlowCategories> pagelist = pagelistSearch(urlQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<FlowCategories> results = getPageResults(pagelist, urlQuery);

            return Ok(results);
        }

        protected override IEnumerable<FlowCategories> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<FlowCategories> pagelist = null;
            long intvalue = -1;
            try
            {
                intvalue = Int64.Parse(urlQuery.SearchValue);
            }
            catch (Exception /* ex */)
            {

            }

            switch (urlQuery.SearchBy.ToLower())
            {
                case "cat":
                    pagelist = this._context.FlowCategories.Where(fs => fs.Cat == urlQuery.SearchValue).OrderBy(fs => fs.Subcat);
                    break;
                case "idflowcategories":
                    pagelist = this._context.FlowCategories.Where(fs => fs.IdFlowCategories == intvalue);
                    break;

                // case "ip1":
                default:
                    break;
            }
            return pagelist;

        }
    }
}
