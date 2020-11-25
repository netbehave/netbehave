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
    public class SpaController : Controller
    {
        protected readonly ILogger<SpaController> _logger;

        public SpaController(ILogger<SpaController> logger)
        {
            _logger = logger;
        }

        // Enumerate all SPA urls so we boot the Vue app correctly
        // Alternatively, use this as the 404 page so any unhandled url will boot the vue app
        //        
        // 
        // [HttpGet("/clientapp")]
        // [HttpGet("/app")]
        [HttpGet("/about")]
        public ActionResult Index(string id)
        // => File("/clientapp/index.html", "text/html");
        {
            // Console.WriteLine("SpaController:Index id=[" + id + "]");
            _logger.LogInformation("SpaController:Index id=[" + id + "]");
            return File("/clientapp/index.html", "text/html");
        }
        /*

        */
        // 
        [HttpGet("/clientapp")]
        // [HttpGet("/app")]
        public ActionResult Index2(string id)
        {
            // Console.WriteLine("SpaController:Index id=[" + id + "]");
            _logger.LogInformation("SpaController:Index2 id=[" + id + "]");
            return File("/clientapp/index.html", "text/html");
            // return File("/index.html", "text/html");
        }

    }
}
