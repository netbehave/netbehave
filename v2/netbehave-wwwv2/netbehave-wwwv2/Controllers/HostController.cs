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
    public class HostController : NetBehaveController<HostInfo>
    {
        public HostController(ILogger<HostController> logger, nbv2Context context) : base(logger, context)
        {
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult Element([FromQuery] int value)
        {
            HostInfo host = _context.HostInfo.Find(value);
            if (host == null)
            {
                return NotFound();
            }
            loadExtra(host);
            return Ok(host);
        }

        // https://localhost:32772/api/host/search?SearchBy=ip1&SearchValue=.0.1&SearchType=contains
        // https://localhost:32772/api/host/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlSearchQuery)
        {
            IEnumerable<HostInfo> pagelist = pagelistSearch(urlSearchQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<HostInfo> results = getPageResults(pagelist, urlSearchQuery);

            return Ok(results);
        }

        private void loadExtra(HostInfo host)
        {
            IEnumerable<HostInfoIp> list = this._context.HostInfoIp.Where(hostinfoip => hostinfoip.IdHostInfo == host.IdHostInfo);
            foreach (HostInfoIp hip in list)
            {
                hip.IdHostInfoNavigation = null;
                host.HostInfoIp.Add(hip);
            }

            // join appco in this._context.AppComponent
            // on app.IdAppInfo equals appco.IdAppInfo


            // IEnumerable<AppInfo> relatedApps = this._context.AppInfo.Where(appinfo => appinfo.)
            // on appcohost.ComponentId equals appco.ComponentId
            // on app.IdAppInfo equals appco.IdAppInfo
            // on new { appcohost.ComponentId, app.IdAppInfo }  equals new { appco.ComponentId, appco.IdAppInfo }

            var queryApp =
                from appcohost in _context.AppComponentHost
                join appco in _context.AppComponent on appcohost.ComponentId equals appco.ComponentId
                join app in _context.AppInfo on appco.IdAppInfo equals app.IdAppInfo
                where appcohost.IdHostInfo == host.IdHostInfo
                select app;

            foreach (AppInfo app in queryApp)
            {
                host.AppInfo.Add(app);
            }

            /*
            foreach (var obj in query)
            {
                AppInfo app = (AppInfo)obj;
                host.AppInfo.Add(app);
            }


                            from app in _context.AppInfo
                            join appco in _context.AppComponentHost,
                            join appcohost in _context.AppComponentHost
                            on new { app.IdAppInfo, host.IdHostInfo } equals new { appcohost.IdHostInfo, appcohost.IdAppInfo }
                            select new
                            {
                                app.IdAppInfo, 
                                app.AppName
                            };


                        /*
                        IEnumerable<AppComponentHost> relatedApps = this._context.AppInfo.Where(appinfo => appinfo.)

                        IEnumerable<AppInfo> relatedApps = this._context.AppInfo.Where(appinfo => appinfo.)
                            // .OrderBy(appinfo => appinfo.AppSourceId).ThenBy(appinfo => appinfo.IdAppInfo).OrderBy(appinfo => appinfo.AppSource).OrderBy(appinfo => appinfo.AppSourceId); //  Set<AppInfo>();
                        /* */
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<HostInfo> pagelist = null;
            string orderBy = urlQuery.OrderBy;
            if (orderBy == null) { orderBy = "id"; }
            switch (orderBy)
            {
                case "Name":
                case "name":
                    pagelist = this._context.HostInfo.OrderBy(hostinfo => hostinfo.Name); 
                    break;
                case "idHostInfo":
                case "id":
                    pagelist = this._context.HostInfo.OrderBy(hostinfo => hostinfo.IdHostInfo);
                    break;
                default:
                    break;
            }
            if (pagelist == null)
            {
                pagelist = this._context.HostInfo.OrderBy(hostinfo => hostinfo.HostSource).OrderBy(hostinfo => hostinfo.HostSourceId);
            }
            /*
            if (urlQuery.OrderBy == null)
            {
            } else
            {

                pagelist = this._context.HostInfo.OrderBy(hostinfo => hostinfo.HostSource).OrderBy(hostinfo => hostinfo.HostSourceId); //  Set<AppInfo>();

            }
            */
            if (pagelist == null)
            {
                return NotFound();
            }
            foreach (HostInfo host in pagelist)
            {
                // Console.WriteLine(host.Name);
            }


            PagedResults<HostInfo> results = getPageResults(pagelist, urlQuery);

            foreach (HostInfo host in results.Results)
            {
                loadExtra(host);
                /*
                                IEnumerable<HostInfoIp> list = this._context.HostInfoIp.Where(hostinfoip => hostinfoip.IdHostInfo == host.IdHostInfo);
                                foreach (HostInfoIp hip in list)
                                {
                                    hip.IdHostInfoNavigation = null;
                                    host.HostInfoIp.Add(hip);
                                }
                */
            }

            /*
            {
            }

            foreach (AppInfo ai in results.Results)
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

            /*

             */

            return Ok(results);
        }


        protected override IEnumerable<HostInfo> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<HostInfo> pagelist = null;

            switch (urlQuery.SearchBy.ToLower())
            {
                /*
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
                */
                case "ip_i":
                case "ipi":
                    try
                    {
                        List<HostInfoIp> hilist = new List<HostInfoIp>();
                        long ip = Int64.Parse(urlQuery.SearchValue);
                        IEnumerable<HostInfoIp> hiiList = this._context.HostInfoIp.Where(hostinfoip => hostinfoip.IpI == ip).OrderBy(hostinfoip => hostinfoip.IpI);
                        foreach (HostInfoIp hip in hiiList)
                        {
                            hilist.Add(hip);
                        }
                        hiiList = null;
                        List<HostInfo> list = new List<HostInfo>();

                        foreach (HostInfoIp hip in hilist)
                        {
                            pagelist = this._context.HostInfo.Where(hostinfo => hostinfo.IdHostInfo == hip.IdHostInfo).OrderBy(hostinfo => hostinfo.HostSource).OrderBy(hostinfo => hostinfo.HostSourceId); ;
                            foreach (HostInfo hi in pagelist)
                            {
                                hi.HostInfoIp = null;
                                list.Add(hi);
                            }
                            pagelist = null;

                        }
                        return list;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex.ToString());
                    }
                    break;
                case "hostname":
                case "name":
                default:
                    if (urlQuery.SearchType == "contains")
                    {
                        // pagelist = this._context.HostInfo.Where(hostinfo => hostinfo.Name.Contains(urlQuery.SearchValue, StringComparison.OrdinalIgnoreCase)).OrderBy(hostinfo => hostinfo.HostSource).OrderBy(hostinfo => hostinfo.HostSourceId);
                        pagelist = this._context.HostInfo.Where(hostinfo => hostinfo.Name.ToLower().Contains(urlQuery.SearchValue.ToLower())).OrderBy(hostinfo => hostinfo.HostSource).OrderBy(hostinfo => hostinfo.HostSourceId);
                    }
                    else
                    {
                        pagelist = this._context.HostInfo.Where(hostinfo => hostinfo.Name == urlQuery.SearchValue).OrderBy(hostinfo => hostinfo.HostSource).OrderBy(hostinfo => hostinfo.HostSourceId);
                    }
                    break;
            }
            return pagelist;
        }
    }
}
