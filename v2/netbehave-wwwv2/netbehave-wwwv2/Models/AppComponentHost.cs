using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class AppComponentHost
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdAppInfo { get; set; }
        public string ComponentId { get; set; }
        public int IdHostInfo { get; set; }
        public string ComponentType { get; set; }
        public string JsonData { get; set; }

        public virtual AppComponent AppComponent { get; set; }
    }
}
