using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace netbehave_wwwv2.Models
{
    public partial class Ip
    {
        public Ip()
        {
            HostInfo = new HashSet<HostInfo>();
            Categories = new HashSet<string[]>();
        }

        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Ip1 { get; set; }
        public long IpI { get; set; }
        public int IpVersion { get; set; }
        public int? IdHostInfo { get; set; }
        public string NetBlockSource { get; set; }
        public string NetBlockName { get; set; }
        public string JsonData { get; set; }

        [NotMapped]
        public virtual ICollection<HostInfo> HostInfo { get; set; }
        [NotMapped]
        public virtual ICollection<string[]> Categories { get; set; }

    }
}
