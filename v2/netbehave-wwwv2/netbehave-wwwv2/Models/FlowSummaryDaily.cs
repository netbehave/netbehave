using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class FlowSummaryDaily
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Srcip { get; set; }
        public string Dstip { get; set; }
        public string Cat { get; set; }
        public string Subcat { get; set; }
        public string Datestr { get; set; }
        public int? SrcIdHostInfo { get; set; }
        public int? DstIdHostInfo { get; set; }
        public int? IdFlowCategories { get; set; }
        public string JsonData { get; set; }
        public int? Hits { get; set; }
        public long? BytesIn { get; set; }
        public long? BytesOut { get; set; }
    }
}
