using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace netbehave_wwwv2.Models
{
    public class AppInfoReference
    {
        public int IdAppInfo { get; set; }
        public string AppSource { get; set; }
        public string AppSourceId { get; set; }
        public string AppName { get; set; }

    }
    public partial class HostInfo
    {
        public HostInfo()
        {
            HostInfoIp = new HashSet<HostInfoIp>();
            HostInfoName = new HashSet<HostInfoName>();
            AppInfo = new HashSet<AppInfo>();
        }

        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdHostInfo { get; set; }
        public string HostSource { get; set; }
        public string HostSourceId { get; set; }
        public string Name { get; set; }
        public string JsonData { get; set; }

        public virtual ICollection<HostInfoIp> HostInfoIp { get; set; }
        public virtual ICollection<HostInfoName> HostInfoName { get; set; }

        [NotMapped]
        public virtual ICollection<AppInfo> AppInfo { get; set; }

    }
}
