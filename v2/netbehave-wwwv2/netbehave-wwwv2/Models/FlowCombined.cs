using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class FlowCombined
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Srcips { get; set; }
        public string Dstips { get; set; }
        public string Protos { get; set; }
        public string Srcports { get; set; }
        public string Dstports { get; set; }
        public string MatchKey { get; set; }
        public string JsonData { get; set; }
    }
}
