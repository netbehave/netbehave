using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class DnsInfo
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Ip { get; set; }
        public long IpI { get; set; }
        public string Name { get; set; }
    }
}
