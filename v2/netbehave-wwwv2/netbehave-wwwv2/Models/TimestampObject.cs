using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class TimestampObject
    {
        public DateTime? DateAdded { get; set; }
        public DateTime? LastSeen { get; set; }
        public DateTime? LastModified { get; set; }
    }
}
