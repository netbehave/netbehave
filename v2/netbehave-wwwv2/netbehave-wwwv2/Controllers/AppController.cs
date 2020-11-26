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
    public class AppController : NetBehaveController<AppInfo>
    {
        public AppController(ILogger<AppController> logger, nbv2Context context) : base(logger, context)
        {
        }


        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult Element([FromQuery] int value)
        {
            // object[] searchQuery = new object[] { urlElementQuery.SearchBy, urlElementQuery.SearchValue };
            // Ip ipa = _context.Ip.Find(ip); // ["ip",
            /*
            Ip
            var ipa = await _context.Ip.FindAsync(ip);  //(ip);


            */
            AppInfo app = _context.AppInfo.Find(value);
            loadExtra1(app);
            loadExtra2(app);
            if (app == null)
            {
                return NotFound();
            }
            return Ok(app);
        }

        // https://localhost:32772/api/ip/search?SearchBy=ip1&SearchValue=.0.1&SearchType=contains
        // https://localhost:32772/api/ip/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlSearchQuery)
        {
            IEnumerable<AppInfo> pagelist = pagelistSearch(urlSearchQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<AppInfo> results = getPageResults(pagelist, urlSearchQuery);
            foreach (AppInfo ai in results.Results)
            {
                loadExtra1(ai);
            }

            foreach (AppInfo ai in results.Results)
            {
                loadExtra2(ai);
            }
            return Ok(results);
        }


        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<AppInfo> pagelist = null;
            string orderBy = urlQuery.OrderBy;
            if (orderBy == null) { orderBy = "id"; }
            switch (orderBy)
            {
                case "Name":
                case "name":
                    pagelist = this._context.AppInfo.OrderBy(appinfo => appinfo.AppName);
                    break;
                case "appSourceId":
                    pagelist = this._context.AppInfo.OrderBy(appinfo => appinfo.AppSourceId);
                    break;
                case "idAppInfo":
                case "id":
                    pagelist = this._context.AppInfo.OrderBy(appinfo => appinfo.IdAppInfo);
                    break;
                default:
                    break;
            }
            if (pagelist == null)
            {
                pagelist = this._context.AppInfo.OrderBy(appinfo => appinfo.AppSourceId).ThenBy(appinfo => appinfo.IdAppInfo).OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId); //  Set<AppInfo>();
            }

            if (pagelist == null)
            {
                return NotFound();
            }
            foreach (AppInfo ai in pagelist)
            {
                // Console.WriteLine(ai.AppName);
            }


            PagedResults<AppInfo> results = getPageResults(pagelist, urlQuery);

            foreach (AppInfo ai in results.Results)
            {
                loadExtra1(ai);
            }

            foreach (AppInfo ai in results.Results)
            {
                loadExtra2(ai);
            }

            /*

             */

            return Ok(results);
        }


        private void loadExtra1(AppInfo ai)
        {
            IEnumerable<AppComponent> list = this._context.AppComponent.Where(appcomponent => appcomponent.IdAppInfo == ai.IdAppInfo);
            foreach (AppComponent ac in list)
            {
                ac.IdAppInfoNavigation = null;
                ai.AppComponent.Add(ac);
            }
        }
        private void loadExtra2(AppInfo ai)
        {
            foreach (AppComponent ac in ai.AppComponent)
            {
                IEnumerable<AppComponentHost> listHost = this._context.AppComponentHost.Where(appcomponenthost =>
                    appcomponenthost.IdAppInfo == ai.IdAppInfo
                    && appcomponenthost.ComponentId == ac.ComponentId
                    && appcomponenthost.ComponentType == ac.ComponentType
                    );
                foreach (AppComponentHost ach in listHost)
                {
                    ach.AppComponent = null;
                    ac.AppComponentHost.Add(ach);
                }
            }

        }

        protected override IEnumerable<AppInfo> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<AppInfo> pagelist = null;

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
                case "appsourceid":
                    if (urlQuery.SearchType == "contains")
                    {
                        // 
                        // pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppName.Contains(urlQuery.SearchValue, StringComparison.OrdinalIgnoreCase)); // .OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);

                        pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppSourceId.ToLower().Contains(urlQuery.SearchValue.ToLower())).OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);
                        // pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppName.IndexOf(urlQuery.SearchValue, StringComparison.OrdinalIgnoreCase) != -1); // .OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);
                        // 
                    }
                    else
                    {
                        pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppSourceId == urlQuery.SearchValue).OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);
                    }
                    break;
                case "appname":
                case "name":
                default:
                    if (urlQuery.SearchType == "contains")
                    {
                        // 
                        // pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppName.Contains(urlQuery.SearchValue, StringComparison.OrdinalIgnoreCase)); // .OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);

                        pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppName.ToLower().Contains(urlQuery.SearchValue.ToLower())).OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);
                        // pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppName.IndexOf(urlQuery.SearchValue, StringComparison.OrdinalIgnoreCase) != -1); // .OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);
                        // 
                    }
                    else
                    {
                        pagelist = this._context.AppInfo.Where(appinfo => appinfo.AppName == urlQuery.SearchValue).OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId);
                    }
                    break;
            }
            return pagelist;
        }
    }
}
