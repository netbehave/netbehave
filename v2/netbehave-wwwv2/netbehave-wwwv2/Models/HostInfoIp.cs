using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class HostInfoIp
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdHostInfo { get; set; }
        public string HostSource { get; set; }
        public string HostSourceId { get; set; }
        public string Ip { get; set; }
        public long? IpI { get; set; }
        public string Intf { get; set; }
        public string Netmask { get; set; }

        public virtual HostInfo IdHostInfoNavigation { get; set; }
    }
}
