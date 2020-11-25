using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class AppInfo
    {
        public AppInfo()
        {
            AppComponent = new HashSet<AppComponent>();
        }

        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdAppInfo { get; set; }
        public string AppSource { get; set; }
        public string AppSourceId { get; set; }
        public string AppName { get; set; }
        public string AppDescription { get; set; }
        public string JsonData { get; set; }

        public virtual ICollection<AppComponent> AppComponent { get; set; }
    }
}
