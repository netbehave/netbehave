using System;
using System.Collections.Generic;

namespace netbehave_wwwv2.Models
{
    public partial class V2Log
    {
        public string TableName { get; set; }
        public string TableField { get; set; }
        public string OldValue { get; set; }
        public string NewValue { get; set; }
        public DateTime? DateAdded { get; set; }
    }
}
