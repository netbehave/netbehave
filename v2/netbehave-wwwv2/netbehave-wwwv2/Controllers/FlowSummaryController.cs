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
    public class FlowSummaryController :  NetBehaveController<FlowSummary>
    {
        public FlowSummaryController(ILogger<FlowSummaryController> logger, nbv2Context context) : base(logger, context)
        {
            // _logger = logger;
            // _context = context;
        }



        // https://localhost:32772/api/ip/element?ip=192.168.0.10
        // https://localhost:32772/api/ip/element?SearchBy=ip&SearchValue=192.168.0.10
        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult Element([FromQuery] string srcip, string dstip, string cat, string subcat)
        {
            string []qparams = new string[] { srcip, dstip, cat, subcat };
            FlowSummary fs = _context.FlowSummary.Find(qparams);

            if (fs == null)
            {
                return NotFound();
            }
            loadExtra(fs);
            return Ok(fs);
        }

        private void loadExtra(FlowSummary fs)
        {
            var uniqueDays =
               (from fsd in this._context.FlowSummaryDaily
                where (fsd.Cat == fs.Cat && fsd.Subcat == fs.Subcat && fsd.Srcip == fs.Srcip && fsd.Dstip == fs.Dstip)
                select fsd.Datestr).Distinct().OrderBy(datestr => datestr);

            //                 where (fsd.Cat, fsd.Subcat, fsd.Srcip, fsd.Dstip) equals (fs.Cat, fs.Subcat, fs.Srcip, fs.Dstip)

            foreach (string datestr in uniqueDays)
            {
                fs.Days.Add(datestr);
            }

            /*
            IEnumerable<FlowSummaryDaily> list = this._context.FlowSummaryDaily.Where(fsd=> fsd.Cat == fs.Cat && fsd.Subcat == fs.Subcat && fsd.Srcip == fs.Srcip && fsd.Dstip == fs.Dstip);
            foreach (FlowSummaryDaily fsd in list)
            {
                fs.Days.Add(fsd.Datestr);
            }
            */

        }


        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<FlowSummary> pagelist = this._context.Set<FlowSummary>().OrderBy(fs => fs.Srcip);
            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<FlowSummary> results = getPageResults(pagelist, urlQuery);
            foreach (FlowSummary fs in results.Results)
            {
                loadExtra(fs);
            }
            return Ok(results);
        }

        // https://localhost:32772/api/host/search?SearchBy=ip1&SearchValue=.0.1&SearchType=contains
        // https://localhost:32772/api/host/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlSearchQuery)
        {
            IEnumerable<FlowSummary> pagelist = pagelistSearch(urlSearchQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<FlowSummary> results = getPageResults(pagelist, urlSearchQuery);
            foreach (FlowSummary fs in results.Results)
            {
                loadExtra(fs);
            }

            return Ok(results);
        }

        protected override IEnumerable<FlowSummary> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<FlowSummary> pagelist = null;
            long intvalue = -1;
            try
            {
                intvalue = Int64.Parse(urlQuery.SearchValue);
            } catch (Exception /* ex */)
            {

            }

            switch (urlQuery.SearchBy.ToLower())
            {
                case "srcidhostinfo":
                    pagelist = this._context.FlowSummary.Where(fs => fs.SrcIdHostInfo == intvalue).OrderBy(fs => fs.Srcip);
                    break;
                case "dstidhostinfo":
                    pagelist = this._context.FlowSummary.Where(fs => fs.DstIdHostInfo == intvalue).OrderBy(fs => fs.Dstip);
                    break;
                case "ip":
                    pagelist = this._context.FlowSummary.Where(fs => fs.Srcip == urlQuery.SearchValue || fs.Dstip == urlQuery.SearchValue).OrderBy(fs => fs.Cat).OrderBy(fs => fs.Subcat); /// .OrderBy(fs => fs.Srcip).OrderBy(fs => fs.Dstip);
                    break;
                case "srcip":
                    pagelist = this._context.FlowSummary.Where(fs => fs.Srcip == urlQuery.SearchValue).OrderBy(fs => fs.Srcip);
                    break;
                case "dstip":
                    pagelist = this._context.FlowSummary.Where(fs => fs.Dstip == urlQuery.SearchValue).OrderBy(fs => fs.Dstip);
                    break;
                case "cat":
                    pagelist = this._context.FlowSummary.Where(fs => fs.Cat == urlQuery.SearchValue).OrderBy(fs => fs.Srcip);
                    break;
                case "idflowcategories":
                    pagelist = this._context.FlowSummary.Where(fs => fs.IdFlowCategories == intvalue).OrderBy(fs => fs.Srcip);
                    break;

                // case "ip1":
                default:
                    break;
            }
            return pagelist;
        }
    }
}
