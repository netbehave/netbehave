using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class NetBlock
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public long IpStartI { get; set; }
        public long IpEndI { get; set; }
        public string IpStart { get; set; }
        public string IpEnd { get; set; }
        public string NetBlockSource { get; set; }
        public string NetBlockName { get; set; }
        public string NetBlockMask { get; set; }
        public string NetBlockSubnet { get; set; }
        public int? NetBlockBits { get; set; }
        public int? NetBlockSize { get; set; }
        public string JsonData { get; set; }
    }
}
