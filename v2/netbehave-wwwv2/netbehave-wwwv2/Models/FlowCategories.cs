using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class FlowCategories
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdFlowCategories { get; set; }
        public string Cat { get; set; }
        public string Subcat { get; set; }
        public string Rulecsv { get; set; }
        public string JsonData { get; set; }
    }
}
