using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class FlowDetail20200930
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Srcip { get; set; }
        public string Dstip { get; set; }
        public string Proto { get; set; }
        public int Srcport { get; set; }
        public int Dstport { get; set; }
        public string Servicename { get; set; }
        public string Srcnetblock { get; set; }
        public string Dstnetblock { get; set; }
        public string Srcdns { get; set; }
        public string Dstdns { get; set; }
        public string MatchType { get; set; }
        public string MatchKey { get; set; }
        public int? Hits { get; set; }
        public int? BytesIn { get; set; }
        public int? BytesOut { get; set; }
        public string JsonData { get; set; }
    }
}
