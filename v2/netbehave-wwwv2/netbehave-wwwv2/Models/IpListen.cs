using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class IpListen
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Ip { get; set; }
        public long IpI { get; set; }
        public string Protocol { get; set; }
        public int Port { get; set; }
        public int? IpVersion { get; set; }
        public string ServiceName { get; set; }
        public int? IdHostInfo { get; set; }
        public string JsonData { get; set; }
    }
}
