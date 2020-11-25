using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class Unknown
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
        public string UnknownType { get; set; }
        public string UnknownKey { get; set; }
        public string JsonData { get; set; }
        public string Status { get; set; }
    }
}
