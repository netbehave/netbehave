using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using netbehave_wwwv2.Data;
using netbehave_wwwv2.Models;
using netbehave_wwwv2.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace netbehave_wwwv2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LabelController : NetBehaveController<Label>
    {
        public LabelController(ILogger<LabelController> logger, nbv2Context context) : base(logger, context)
        {
            // _logger = logger;
            // _context = context;
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<Label> pagelist = null;

            if (pagelist == null)
            {
                pagelist = this._context.Set<Label>().Where(label => label.Idparent == null);
            }


            if (pagelist == null)
            {
                return NotFound();
            }


            PagedResults<Label> results = getPageResults(pagelist, urlQuery);
            loadExtra(results);

            return Ok(results);
        }

        private void loadExtra(PagedResults<Label> results)
        {
            foreach (Label label in results.Results)
            {
                loadCounts(label);
                loadChildren(label);
            }

        }

        // https://localhost:32772/api/label/element?id=192.168.0.10
        // https://localhost:32772/api/ip/element?SearchBy=ip&SearchValue=192.168.0.10
        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult Element([FromQuery] string value)
        {

            Label label = null;
            try
            {
                long idlabel = Int64.Parse(value);
                IEnumerable<Label> pagelist = this._context.Label.Where(l => l.Idlabel == idlabel);
                if (pagelist.Count() > 0)
                {
                    label = pagelist.First<Label>();
                }
            }
            catch (Exception)
            {
                label = _context.Label.Find(value);

            }
            if (label == null)
            {
                IEnumerable<Label> pagelist = this._context.Label.Where(l => l.Label1 == value);
                if (pagelist.Count() > 0)
                {
                    label = pagelist.First<Label>();
                }

            }
            // Ip ipa = _context.Ip.Find(value);
            if (label == null)
            {
                return NotFound();
            }
            // loadExtra(label);
            loadCounts(label);
            loadChildren(label);

            loadLabelChildren(label);
            return Ok(label);
        }


        // https://localhost:32772/api/ip/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlSearchQuery)
        {
            IEnumerable<Label> pagelist = pagelistSearch(urlSearchQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<Label> results = getPageResults(pagelist, urlSearchQuery);
            loadExtra(results);
            return Ok(results);
        }

        protected override IEnumerable<Label> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<Label> pagelist = null;

            switch (urlQuery.SearchBy.ToLower())
            {
                case "label":
                default:
                    if (urlQuery.SearchType == "contains")
                    {
                        // 
                        pagelist = this._context.Set<Label>().Where(label => label.Label1.ToLower().Contains(urlQuery.SearchValue.ToLower()));
                    }
                    else
                    {
                        pagelist = this._context.Set<Label>().Where(label => label.Label1.ToLower() ==  urlQuery.SearchValue.ToLower());
                    }
                    break;
            }
            return pagelist;

        }

        private void loadCounts(Label label)
        {

            //                .OrderBy(lo => lo.Objtype)


            var queryObjCount =
            _context.LabelObj
            .GroupBy(lo => lo.Objtype)
                        .Select(group => new
                        {
                            CountType = group.Key,
                            Count = group.Count()
                        })
                        .OrderBy(x => x.CountType);
            foreach (var ObjCount in queryObjCount)
            {
                label.Counts.Add(ObjCount.CountType.ToLower(), ObjCount.Count);
            }
        }

        private void loadLabelChildren(Label label)
        {
            Dictionary<int, AppInfo> loadedApps = new Dictionary<int, AppInfo>();
            // 1st: Host & integrated apps
            var queryHost =
                from lo in _context.LabelObj
                join host in _context.HostInfo on lo.Key equals host.IdHostInfo.ToString()
                where (lo.Idlabel == label.Idlabel && lo.Objtype == "host_info")
                select host;

            foreach (HostInfo host in queryHost)
            {
                label.Hosts.Add(host);
            }
            //
            foreach (HostInfo hi in label.Hosts)
            {
                var queryAppHost =
                    from appcohost in _context.AppComponentHost
                    join appco in _context.AppComponent on appcohost.ComponentId equals appco.ComponentId
                    join app in _context.AppInfo on appco.IdAppInfo equals app.IdAppInfo
                    where appcohost.IdHostInfo == hi.IdHostInfo
                    select app;

                foreach (AppInfo app in queryAppHost)
                {
                    if (!loadedApps.ContainsKey(app.IdAppInfo))
                    {
                        loadedApps.Add(app.IdAppInfo, app);
                        label.Apps.Add(app);
                    }
                    hi.AppInfo.Add(app);
                }
            }

            // 2nd: apps not already added
            var queryApp =
                from lo in _context.LabelObj
                join app in _context.AppInfo on lo.Key equals app.IdAppInfo.ToString()
                where (lo.Idlabel == label.Idlabel && lo.Objtype == "app_info")
                select app;

            foreach (AppInfo app in queryApp)
            {
                if (!loadedApps.ContainsKey(app.IdAppInfo))
                {
                    label.Apps.Add(app);
                }
            }

            // 3rd: flows

            var queryFlow =
                from lo in _context.LabelObj
                join flow in _context.FlowSummary on lo.Key equals flow.IdFlowCategories.ToString()
                where (lo.Idlabel == label.Idlabel && lo.Objtype == "flow_summary")
                select flow;

            foreach (FlowSummary flow in queryFlow)
            {
                label.Flows.Add(flow);
            }
        }

        private void loadChildren(Label parent)
        {
            IEnumerable<Label> children = this._context.Set<Label>().Where(label => label.Idparent == parent.Idlabel);
            foreach (Label child in children)
            {
                parent.Children.Add(child);
            }
            children = null;

            foreach (Label child in parent.Children)
            {
                loadCounts(child);
                loadChildren(child);
            }


        }

        /*
        public IActionResult Index()
        {
            return View();
        }
        */

    }
}
