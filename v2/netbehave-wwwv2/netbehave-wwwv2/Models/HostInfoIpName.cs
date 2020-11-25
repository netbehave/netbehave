using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class HostInfoIpName
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdHostInfo { get; set; }
        public string HostSource { get; set; }
        public string HostSourceId { get; set; }
        public string Ip { get; set; }
        public long? IpI { get; set; }
        public string Name { get; set; }
    }
}
