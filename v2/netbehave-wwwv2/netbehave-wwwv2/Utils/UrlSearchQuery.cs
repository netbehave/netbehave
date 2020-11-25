using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace netbehave_wwwv2.Utils
{
    public class UrlSearchQuery : UrlQuery
    {
        // SearchType == "contains"
        public string SearchBy { get; set; }
        public string SearchValue { get; set; }
        public string SearchType { get; set; }

    }
}
