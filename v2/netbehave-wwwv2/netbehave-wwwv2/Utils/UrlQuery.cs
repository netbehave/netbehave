using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace netbehave_wwwv2.Utils
{
    public class UrlQuery
    {
        private const int maxPageSize = 1024;
        public int? PageNumber { get; set; }
        public string? OrderBy { get; set; }

        private int _pageSize = 20;
        public int PageSize
        {
            get
            {
                return _pageSize;
            }
            set
            {
                _pageSize = (value < maxPageSize) ? value : maxPageSize;
            }
        }

    }
}
