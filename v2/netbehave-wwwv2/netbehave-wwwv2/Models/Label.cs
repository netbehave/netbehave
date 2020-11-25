using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace netbehave_wwwv2.Models
{
    public partial class Label
    {
        public Label()
        {
            Children = new HashSet<Label>();
            Counts = new Dictionary<string, int>();
            Hosts = new HashSet<HostInfo>();
            Apps = new HashSet<AppInfo>();
            Flows = new HashSet<FlowSummary>();
        }
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public int Idlabel { get; set; }
        public string Label1 { get; set; }
        public long? Idparent { get; set; }
        public string Desc { get; set; }

        [NotMapped]
        public virtual ICollection<Label> Children { get; set; }
        [NotMapped]
        public virtual IDictionary<string,int> Counts { get; set; }

        [NotMapped]
        public virtual ICollection<HostInfo> Hosts { get; set; }
        [NotMapped]
        public virtual ICollection<AppInfo> Apps { get; set; }
        [NotMapped]
        public virtual ICollection<FlowSummary> Flows { get; set; }
    }
}
