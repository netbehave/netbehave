using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace netbehave_wwwv2.Models
{
    public partial class FlowSummary
    {
        public FlowSummary()
        {
            Days = new HashSet<string>();
        }


        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string Srcip { get; set; }
        public string Dstip { get; set; }
        public string Cat { get; set; }
        public string Subcat { get; set; }
        public int? SrcIdHostInfo { get; set; }
        public int? DstIdHostInfo { get; set; }
        public int? IdFlowCategories { get; set; }
        public string JsonData { get; set; }

        //         public string Datestr { get; set; }
        [NotMapped]
        public virtual ICollection<string> Days { get; set; }


    }
}
