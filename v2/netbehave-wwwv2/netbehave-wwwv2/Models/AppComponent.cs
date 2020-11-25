using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class AppComponent
    {
        public AppComponent()
        {
            AppComponentHost = new HashSet<AppComponentHost>();
        }

        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdAppInfo { get; set; }
        public string ComponentId { get; set; }
        public string ComponentType { get; set; }
        public string JsonData { get; set; }

        public virtual AppInfo IdAppInfoNavigation { get; set; }
        public virtual ICollection<AppComponentHost> AppComponentHost { get; set; }
    }
}
