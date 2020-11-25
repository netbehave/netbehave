using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class FlowRules
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int IdFlowRules { get; set; }
        public string Rulename { get; set; }
        public string Rulecsv { get; set; }
        public string JsonData { get; set; }
    }
}
