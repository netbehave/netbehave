using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
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
    public class NetblockController : NetBehaveController<NetBlock>
    {

        public NetblockController(ILogger<NetblockController> logger, nbv2Context context) : base(logger, context)
        {
            // _logger = logger;
            // _context = context;
        }

        [Microsoft.AspNetCore.Mvc.HttpGet("element")] // /{ip:alpha}
        public IActionResult ElementByName([FromQuery] string value)
        {
            // object[] searchQuery = new object[] { urlElementQuery.SearchBy, urlElementQuery.SearchValue };
            // Ip ipa = _context.Ip.Find(ip); // ["ip",
            /*
            Ip
            var ipa = await _context.Ip.FindAsync(ip);  //(ip);


            */
            IEnumerable<NetBlock> pagelist = null;
            NetBlock block = null;
            try
            {
                long ipI = Int64.Parse(value);
                pagelist = this._context.NetBlock.Where(netblock => netblock.IpStartI <= ipI && netblock.IpEndI >= ipI);
            }
            catch (Exception)
            {
                pagelist = _context.NetBlock.Where(netblock => netblock.NetBlockName == value);

            }
            if (pagelist.Count() > 0)
            {
                block = pagelist.First<NetBlock>();  // .Find(value);
            }

            if (block == null)
            {
                return NotFound();
            }
            return Ok(block);
        }

        // https://localhost:32772/api/ip/search?SearchBy=ip1&SearchValue=.0.1&SearchType=contains
        // https://localhost:32772/api/ip/searcg?SearchBy=ip1&SearchValue=192.168.0.11
        [Microsoft.AspNetCore.Mvc.HttpGet("search")]
        public IActionResult Search([FromQuery] UrlSearchQuery urlQuery)
        {
            IEnumerable<NetBlock> pagelist = pagelistSearch(urlQuery);

            if (pagelist == null)
            {
                return NotFound();
            }

            PagedResults<NetBlock> results = getPageResults(pagelist, urlQuery);

            return Ok(results);
        }


        [Microsoft.AspNetCore.Mvc.HttpGet("list")]
        public IActionResult List([FromQuery] UrlQuery urlQuery)
        {
            IEnumerable<NetBlock> pagelist = this._context.Set<NetBlock>().OrderBy(netblock => netblock.IpStartI);
            if (pagelist == null)
            {
                return NotFound();
            }


            PagedResults<NetBlock> results = getPageResults(pagelist, urlQuery);

            return Ok(results);
        }

        static long ToInt(string addr)
        {
            // careful of sign extension: convert to uint first;
            // unsigned NetworkToHostOrder ought to be provided.
            return (long)(uint)IPAddress.NetworkToHostOrder(
                 (int)IPAddress.Parse(addr).Address);
        }
        protected override IEnumerable<NetBlock> pagelistSearch(UrlSearchQuery urlQuery)
        {
            IEnumerable<NetBlock> pagelist = null;

            switch (urlQuery.SearchBy.ToLower())
            {
                case "ip":
                    // Convert IP address to int
                    try
                    {
                        long ip = Int64.Parse(urlQuery.SearchValue);
                        pagelist = this._context.NetBlock.Where(netblock => netblock.IpStartI <= ip && netblock.IpEndI >= ip).OrderBy(netblock => netblock.IpStartI);
                    }
                    catch (Exception)
                    {

                    }
                    break;
                case "ip_i":
                    // TODO
                    if (urlQuery.SearchType == "contains")
                    {
                        // pagelist = this._context.NetBlock.Where(netblock => netblock.Ip1.Contains(urlQuery.SearchValue));

                    }
                    else
                    {
                    }
                    try
                    {
                        long ip = Int64.Parse(urlQuery.SearchValue);
                        pagelist = this._context.NetBlock.Where(netblock => netblock.IpStartI <= ip && netblock.IpEndI >= ip).OrderBy(netblock => netblock.IpStartI);
                    }
                    catch (Exception)
                    {

                    }
                    break;
                case "ipstarti":
                    try
                    {
                        long ip = Int64.Parse(urlQuery.SearchValue);
                        pagelist = this._context.NetBlock.Where(netblock => netblock.IpStartI == ip).OrderBy(netblock => netblock.IpStartI);
                    }
                    catch (Exception)
                    {

                    }
                    break;
                case "netblockname":
                    if (urlQuery.SearchType == "contains")
                    {
                        // pagelist = this._context.NetBlock.Where(netblock => netblock.NetBlockName.Contains(urlQuery.SearchValue, StringComparison.OrdinalIgnoreCase)).OrderBy(netblock => netblock.IpStartI);
                        pagelist = this._context.NetBlock.Where(netblock => netblock.NetBlockName.ToLower().Contains(urlQuery.SearchValue.ToLower())).OrderBy(netblock => netblock.IpStartI);

                    }
                    else
                    {
                        pagelist = this._context.NetBlock.Where(netblock => netblock.NetBlockName == urlQuery.SearchValue).OrderBy(netblock => netblock.IpStartI); ;
                    }
                    break;
                default:
                    break;
            }
            return pagelist;
        }

    }

}
