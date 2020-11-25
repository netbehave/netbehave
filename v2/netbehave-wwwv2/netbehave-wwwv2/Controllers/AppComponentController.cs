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
    [Route("api/[controller]")]
    [ApiController]
    public class AppComponentController : NetBehaveController<AppComponent>
    {
        // AppComponent

        public AppComponentController(ILogger<AppComponentController> logger, nbv2Context context) : base(logger, context)
        {
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult Element([FromQuery] string value)
        {
            AppComponent app = _context.AppComponent.Find(value);
            if (app == null)
            {
                return NotFound();
            }
            return Ok(app);
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlQuery)
        {
            IEnumerable<AppComponent> pagelist = pagelistSearch(urlQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<AppComponent> results = getPageResults(pagelist, urlQuery);
            return Ok(results);
        }


        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<AppComponent> pagelist = this._context.Set<AppComponent>();
            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<AppComponent> results = getPageResults(pagelist, urlQuery);
            return Ok(results);
        }


        protected override IEnumerable<AppComponent> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<AppComponent> pagelist = null;

            switch (urlQuery.SearchBy.ToLower())
            {
                /*
                case "ip_i":
                    // TODO
                    if (urlQuery.SearchType == "contains")
                    {
                        // pagelist = this._context.NetBlock.Where(netblock => netblock.Ip1.Contains(urlQuery.SearchValue));

                    }
                    else
                    {
                    }
                    long ip = Int64.Parse(urlQuery.SearchValue);
                    pagelist = this._context.AppInfo.Where(netblock => netblock.IpStartI <= ip && netblock.IpEndI >= ip);
                    break;
                    break;
                */
                case "idappinfo":
                case "id":
                default:
                    try
                    {
                        long id = Int64.Parse(urlQuery.SearchValue);
                        pagelist = this._context.AppComponent.Where(appcomponent => appcomponent.IdAppInfo == id);
                    }
                    catch (Exception /* ex */)
                    {

                    }
                    break;
            }
            return pagelist;
        }
    }
}
