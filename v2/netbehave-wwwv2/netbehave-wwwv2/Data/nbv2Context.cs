using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using netbehave_wwwv2.Models;

namespace netbehave_wwwv2.Data
{
    public partial class nbv2Context : DbContext
    {
        public nbv2Context()
        {
        }

        public nbv2Context(DbContextOptions<nbv2Context> options)
            : base(options)
        {
        }

        public virtual DbSet<Acl> Acl { get; set; }
        public virtual DbSet<AppComponent> AppComponent { get; set; }
        public virtual DbSet<AppComponentHost> AppComponentHost { get; set; }
        public virtual DbSet<AppInfo> AppInfo { get; set; }
        public virtual DbSet<BmcHostInterface> BmcHostInterface { get; set; }
        public virtual DbSet<DnsInfo> DnsInfo { get; set; }
        public virtual DbSet<FlowCategories> FlowCategories { get; set; }
        public virtual DbSet<FlowCombined> FlowCombined { get; set; }
        public virtual DbSet<FlowDetail20200930> FlowDetail20200930 { get; set; }
        public virtual DbSet<FlowDetail20201017> FlowDetail20201017 { get; set; }
        public virtual DbSet<FlowRules> FlowRules { get; set; }
        public virtual DbSet<FlowSummary> FlowSummary { get; set; }
        public virtual DbSet<FlowSummaryDaily> FlowSummaryDaily { get; set; }
        public virtual DbSet<HostInfo> HostInfo { get; set; }
        public virtual DbSet<HostInfoIp> HostInfoIp { get; set; }
        public virtual DbSet<HostInfoIpName> HostInfoIpName { get; set; }
        public virtual DbSet<HostInfoName> HostInfoName { get; set; }
        public virtual DbSet<Ip> Ip { get; set; }
        public virtual DbSet<IpListen> IpListen { get; set; }
        public virtual DbSet<Label> Label { get; set; }
        public virtual DbSet<LabelObj> LabelObj { get; set; }
        public virtual DbSet<NetBlock> NetBlock { get; set; }
        public virtual DbSet<Service> Service { get; set; }
        public virtual DbSet<TimestampObject> TimestampObject { get; set; }
        public virtual DbSet<Unknown> Unknown { get; set; }
        public virtual DbSet<V2Log> V2Log { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Acl>(entity =>
            {
                entity.HasNoKey();

                entity.ToTable("acl");

                entity.Property(e => e.Rulecsv)
                    .IsRequired()
                    .HasColumnName("rulecsv");

                entity.Property(e => e.Rulename)
                    .IsRequired()
                    .HasColumnName("rulename");
            });

            modelBuilder.Entity<AppComponent>(entity =>
            {
                entity.HasKey(e => new { e.IdAppInfo, e.ComponentId })
                    .HasName("app_component_pkey");

                entity.ToTable("app_component");

                entity.Property(e => e.IdAppInfo).HasColumnName("id_app_info");

                entity.Property(e => e.ComponentId).HasColumnName("component_id");

                entity.Property(e => e.ComponentType).HasColumnName("component_type");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.HasOne(d => d.IdAppInfoNavigation)
                    .WithMany(p => p.AppComponent)
                    .HasForeignKey(d => d.IdAppInfo)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("app_component_id_app_info_fkey");
            });

            modelBuilder.Entity<AppComponentHost>(entity =>
            {
                entity.HasKey(e => new { e.IdAppInfo, e.ComponentId, e.IdHostInfo })
                    .HasName("app_component_host_pkey");

                entity.ToTable("app_component_host");

                entity.Property(e => e.IdAppInfo).HasColumnName("id_app_info");

                entity.Property(e => e.ComponentId).HasColumnName("component_id");

                entity.Property(e => e.IdHostInfo).HasColumnName("id_host_info");

                entity.Property(e => e.ComponentType).HasColumnName("component_type");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.HasOne(d => d.AppComponent)
                    .WithMany(p => p.AppComponentHost)
                    .HasForeignKey(d => new { d.IdAppInfo, d.ComponentId })
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("app_component_host_id_app_info_component_id_fkey");
            });

            modelBuilder.Entity<AppInfo>(entity =>
            {
                entity.HasKey(e => e.IdAppInfo)
                    .HasName("app_info_pkey");

                entity.ToTable("app_info");

                entity.HasIndex(e => new { e.AppSource, e.AppSourceId })
                    .HasName("app_info_app_source_app_source_id_key")
                    .IsUnique();

                entity.Property(e => e.IdAppInfo).HasColumnName("id_app_info");

                entity.Property(e => e.AppDescription).HasColumnName("app_description");

                entity.Property(e => e.AppName).HasColumnName("app_name");

                entity.Property(e => e.AppSource).HasColumnName("app_source");

                entity.Property(e => e.AppSourceId).HasColumnName("app_source_id");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");
            });

            modelBuilder.Entity<BmcHostInterface>(entity =>
            {
                entity.HasKey(e => e.NodeId)
                    .HasName("bmc_host_interface_pkey");

                entity.ToTable("bmc_host_interface");

                entity.Property(e => e.NodeId).HasColumnName("node_id");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");
            });

            modelBuilder.Entity<DnsInfo>(entity =>
            {
                entity.HasKey(e => new { e.Ip, e.IpI, e.Name })
                    .HasName("dns_info_pkey");

                entity.ToTable("dns_info");

                entity.Property(e => e.Ip).HasColumnName("ip");

                entity.Property(e => e.IpI).HasColumnName("ip_i");

                entity.Property(e => e.Name).HasColumnName("name");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");
            });

            modelBuilder.Entity<FlowCategories>(entity =>
            {
                entity.HasKey(e => e.IdFlowCategories)
                    .HasName("flow_categories_pkey");

                entity.ToTable("flow_categories");

                entity.Property(e => e.IdFlowCategories).HasColumnName("id_flow_categories");

                entity.Property(e => e.Cat)
                    .IsRequired()
                    .HasColumnName("cat");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Rulecsv)
                    .IsRequired()
                    .HasColumnName("rulecsv");

                entity.Property(e => e.Subcat)
                    .IsRequired()
                    .HasColumnName("subcat");
            });

            modelBuilder.Entity<FlowCombined>(entity =>
            {
                entity.HasKey(e => new { e.Srcips, e.Dstips, e.Protos, e.Srcports, e.Dstports })
                    .HasName("flow_combined_pkey");

                entity.ToTable("flow_combined");

                entity.Property(e => e.Srcips).HasColumnName("srcips");

                entity.Property(e => e.Dstips).HasColumnName("dstips");

                entity.Property(e => e.Protos).HasColumnName("protos");

                entity.Property(e => e.Srcports).HasColumnName("srcports");

                entity.Property(e => e.Dstports).HasColumnName("dstports");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.MatchKey)
                    .HasColumnName("match_key")
                    .HasMaxLength(200);
            });

            modelBuilder.Entity<FlowDetail20200930>(entity =>
            {
                entity.HasKey(e => new { e.Srcip, e.Dstip, e.Proto, e.Srcport, e.Dstport })
                    .HasName("flow_detail_20200930_pkey");

                entity.ToTable("flow_detail_20200930");

                entity.Property(e => e.Srcip)
                    .HasColumnName("srcip")
                    .HasMaxLength(20);

                entity.Property(e => e.Dstip)
                    .HasColumnName("dstip")
                    .HasMaxLength(20);

                entity.Property(e => e.Proto)
                    .HasColumnName("proto")
                    .HasMaxLength(10);

                entity.Property(e => e.Srcport).HasColumnName("srcport");

                entity.Property(e => e.Dstport).HasColumnName("dstport");

                entity.Property(e => e.BytesIn).HasColumnName("bytes_in");

                entity.Property(e => e.BytesOut).HasColumnName("bytes_out");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Dstdns)
                    .HasColumnName("dstdns")
                    .HasMaxLength(200);

                entity.Property(e => e.Dstnetblock)
                    .HasColumnName("dstnetblock")
                    .HasMaxLength(200);

                entity.Property(e => e.Hits).HasColumnName("hits");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.MatchKey)
                    .HasColumnName("match_key")
                    .HasMaxLength(200);

                entity.Property(e => e.MatchType)
                    .HasColumnName("match_type")
                    .HasMaxLength(200);

                entity.Property(e => e.Servicename)
                    .HasColumnName("servicename")
                    .HasMaxLength(200);

                entity.Property(e => e.Srcdns)
                    .HasColumnName("srcdns")
                    .HasMaxLength(200);

                entity.Property(e => e.Srcnetblock)
                    .HasColumnName("srcnetblock")
                    .HasMaxLength(200);
            });

            modelBuilder.Entity<FlowDetail20201017>(entity =>
            {
                entity.HasKey(e => new { e.Srcip, e.Dstip, e.Proto, e.Srcport, e.Dstport })
                    .HasName("flow_detail_20201017_pkey");

                entity.ToTable("flow_detail_20201017");

                entity.Property(e => e.Srcip)
                    .HasColumnName("srcip")
                    .HasMaxLength(20);

                entity.Property(e => e.Dstip)
                    .HasColumnName("dstip")
                    .HasMaxLength(20);

                entity.Property(e => e.Proto)
                    .HasColumnName("proto")
                    .HasMaxLength(10);

                entity.Property(e => e.Srcport).HasColumnName("srcport");

                entity.Property(e => e.Dstport).HasColumnName("dstport");

                entity.Property(e => e.BytesIn).HasColumnName("bytes_in");

                entity.Property(e => e.BytesOut).HasColumnName("bytes_out");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Dstdns)
                    .HasColumnName("dstdns")
                    .HasMaxLength(200);

                entity.Property(e => e.Dstnetblock)
                    .HasColumnName("dstnetblock")
                    .HasMaxLength(200);

                entity.Property(e => e.Hits).HasColumnName("hits");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.MatchKey)
                    .HasColumnName("match_key")
                    .HasMaxLength(200);

                entity.Property(e => e.MatchType)
                    .HasColumnName("match_type")
                    .HasMaxLength(200);

                entity.Property(e => e.Servicename)
                    .HasColumnName("servicename")
                    .HasMaxLength(200);

                entity.Property(e => e.Srcdns)
                    .HasColumnName("srcdns")
                    .HasMaxLength(200);

                entity.Property(e => e.Srcnetblock)
                    .HasColumnName("srcnetblock")
                    .HasMaxLength(200);
            });

            modelBuilder.Entity<FlowRules>(entity =>
            {
                entity.HasKey(e => e.IdFlowRules)
                    .HasName("flow_rules_pkey");

                entity.ToTable("flow_rules");

                entity.Property(e => e.IdFlowRules).HasColumnName("id_flow_rules");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Rulecsv)
                    .IsRequired()
                    .HasColumnName("rulecsv");

                entity.Property(e => e.Rulename)
                    .IsRequired()
                    .HasColumnName("rulename");
            });

            modelBuilder.Entity<FlowSummary>(entity =>
            {
                entity.HasKey(e => new { e.Srcip, e.Dstip, e.Cat, e.Subcat })
                    .HasName("flow_summary_pkey");

                entity.ToTable("flow_summary");

                entity.Property(e => e.Srcip)
                    .HasColumnName("srcip")
                    .HasMaxLength(200);

                entity.Property(e => e.Dstip)
                    .HasColumnName("dstip")
                    .HasMaxLength(200);

                entity.Property(e => e.Cat).HasColumnName("cat");

                entity.Property(e => e.Subcat).HasColumnName("subcat");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.DstIdHostInfo).HasColumnName("dst_id_host_info");

                entity.Property(e => e.IdFlowCategories).HasColumnName("id_flow_categories");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.SrcIdHostInfo).HasColumnName("src_id_host_info");
            });

            modelBuilder.Entity<FlowSummaryDaily>(entity =>
            {
                entity.HasKey(e => new { e.Srcip, e.Dstip, e.Cat, e.Subcat, e.Datestr })
                    .HasName("flow_summary_daily_pkey");

                entity.ToTable("flow_summary_daily");

                entity.Property(e => e.Srcip)
                    .HasColumnName("srcip")
                    .HasMaxLength(200);

                entity.Property(e => e.Dstip)
                    .HasColumnName("dstip")
                    .HasMaxLength(200);

                entity.Property(e => e.Cat).HasColumnName("cat");

                entity.Property(e => e.Subcat).HasColumnName("subcat");

                entity.Property(e => e.Datestr)
                    .HasColumnName("datestr")
                    .HasMaxLength(8)
                    .IsFixedLength();

                entity.Property(e => e.BytesIn).HasColumnName("bytes_in");

                entity.Property(e => e.BytesOut).HasColumnName("bytes_out");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.DstIdHostInfo).HasColumnName("dst_id_host_info");

                entity.Property(e => e.Hits).HasColumnName("hits");

                entity.Property(e => e.IdFlowCategories).HasColumnName("id_flow_categories");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.SrcIdHostInfo).HasColumnName("src_id_host_info");
            });

            modelBuilder.Entity<HostInfo>(entity =>
            {
                entity.HasKey(e => e.IdHostInfo)
                    .HasName("host_info_pkey");

                entity.ToTable("host_info");

                entity.HasIndex(e => new { e.HostSource, e.HostSourceId })
                    .HasName("host_info_host_source_host_source_id_key")
                    .IsUnique();

                entity.Property(e => e.IdHostInfo).HasColumnName("id_host_info");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.HostSource).HasColumnName("host_source");

                entity.Property(e => e.HostSourceId).HasColumnName("host_source_id");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Name).HasColumnName("name");
            });

            modelBuilder.Entity<HostInfoIp>(entity =>
            {
                entity.HasKey(e => new { e.IdHostInfo, e.HostSource, e.HostSourceId, e.Ip })
                    .HasName("host_info_ip_pkey");

                entity.ToTable("host_info_ip");

                entity.HasIndex(e => new { e.HostSource, e.HostSourceId, e.Ip })
                    .HasName("host_info_ip_host_source_host_source_id_ip_key")
                    .IsUnique();

                entity.Property(e => e.IdHostInfo).HasColumnName("id_host_info");

                entity.Property(e => e.HostSource).HasColumnName("host_source");

                entity.Property(e => e.HostSourceId).HasColumnName("host_source_id");

                entity.Property(e => e.Ip).HasColumnName("ip");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Intf).HasColumnName("intf");

                entity.Property(e => e.IpI).HasColumnName("ip_i");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Netmask).HasColumnName("netmask");

                entity.HasOne(d => d.IdHostInfoNavigation)
                    .WithMany(p => p.HostInfoIp)
                    .HasForeignKey(d => d.IdHostInfo)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("host_info_ip_id_host_info_fkey");
            });

            modelBuilder.Entity<HostInfoIpName>(entity =>
            {
                entity.HasKey(e => e.IdHostInfo)
                    .HasName("host_info_ip_name_pkey");

                entity.ToTable("host_info_ip_name");

                entity.HasIndex(e => new { e.HostSource, e.HostSourceId, e.Ip, e.Name })
                    .HasName("host_info_ip_name_host_source_host_source_id_ip_name_key")
                    .IsUnique();

                entity.Property(e => e.IdHostInfo)
                    .HasColumnName("id_host_info")
                    .ValueGeneratedNever();

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.HostSource).HasColumnName("host_source");

                entity.Property(e => e.HostSourceId).HasColumnName("host_source_id");

                entity.Property(e => e.Ip).HasColumnName("ip");

                entity.Property(e => e.IpI).HasColumnName("ip_i");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Name).HasColumnName("name");
            });

            modelBuilder.Entity<HostInfoName>(entity =>
            {
                entity.HasKey(e => new { e.IdHostInfo, e.HostSource, e.HostSourceId, e.Name })
                    .HasName("host_info_name_pkey");

                entity.ToTable("host_info_name");

                entity.Property(e => e.IdHostInfo).HasColumnName("id_host_info");

                entity.Property(e => e.HostSource).HasColumnName("host_source");

                entity.Property(e => e.HostSourceId).HasColumnName("host_source_id");

                entity.Property(e => e.Name).HasColumnName("name");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.HasOne(d => d.IdHostInfoNavigation)
                    .WithMany(p => p.HostInfoName)
                    .HasForeignKey(d => d.IdHostInfo)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("host_info_name_id_host_info_fkey");
            });

            modelBuilder.Entity<Ip>(entity =>
            {
                entity.HasKey(e => e.Ip1)
                    .HasName("ip_pkey");

                entity.ToTable("ip");

                entity.Property(e => e.Ip1).HasColumnName("ip");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.IdHostInfo).HasColumnName("id_host_info");

                entity.Property(e => e.IpI).HasColumnName("ip_i");

                entity.Property(e => e.IpVersion).HasColumnName("ip_version");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.NetBlockName).HasColumnName("net_block_name");

                entity.Property(e => e.NetBlockSource).HasColumnName("net_block_source");
            });

            modelBuilder.Entity<IpListen>(entity =>
            {
                entity.HasKey(e => new { e.Ip, e.Protocol, e.Port })
                    .HasName("ip_listen_pkey");

                entity.ToTable("ip_listen");

                entity.Property(e => e.Ip).HasColumnName("ip");

                entity.Property(e => e.Protocol).HasColumnName("protocol");

                entity.Property(e => e.Port).HasColumnName("port");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.IdHostInfo).HasColumnName("id_host_info");

                entity.Property(e => e.IpI).HasColumnName("ip_i");

                entity.Property(e => e.IpVersion).HasColumnName("ip_version");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.ServiceName).HasColumnName("service_name");
            });

            modelBuilder.Entity<Label>(entity =>
            {
                entity.HasKey(e => e.Idlabel)
                    .HasName("label_pkey");

                entity.ToTable("label");

                entity.Property(e => e.Idlabel).HasColumnName("idlabel");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Desc).HasColumnName("desc");

                entity.Property(e => e.Idparent).HasColumnName("idparent");

                entity.Property(e => e.Label1)
                    .IsRequired()
                    .HasColumnName("label");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");
            });

            modelBuilder.Entity<LabelObj>(entity =>
            {
                entity.HasKey(e => new { e.Idlabel, e.Objtype, e.Key })
                    .HasName("label_obj_pkey");

                entity.ToTable("label_obj");

                entity.Property(e => e.Idlabel).HasColumnName("idlabel");

                entity.Property(e => e.Objtype).HasColumnName("objtype");

                entity.Property(e => e.Key).HasColumnName("key");

                entity.Property(e => e.Desc).HasColumnName("desc");
            });



            modelBuilder.Entity<NetBlock>(entity =>
            {
                entity.HasKey(e => new { e.IpStartI, e.IpEndI })
                    .HasName("net_block_pkey");

                entity.ToTable("net_block");

                entity.Property(e => e.IpStartI).HasColumnName("ip_start_i");

                entity.Property(e => e.IpEndI).HasColumnName("ip_end_i");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.IpEnd).HasColumnName("ip_end");

                entity.Property(e => e.IpStart).HasColumnName("ip_start");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.NetBlockBits).HasColumnName("net_block_bits");

                entity.Property(e => e.NetBlockMask).HasColumnName("net_block_mask");

                entity.Property(e => e.NetBlockName).HasColumnName("net_block_name");

                entity.Property(e => e.NetBlockSize).HasColumnName("net_block_size");

                entity.Property(e => e.NetBlockSource).HasColumnName("net_block_source");

                entity.Property(e => e.NetBlockSubnet).HasColumnName("net_block_subnet");
            });

            modelBuilder.Entity<Service>(entity =>
            {
                entity.HasKey(e => e.Protoport)
                    .HasName("service_pkey");

                entity.ToTable("service");

                entity.Property(e => e.Protoport).HasColumnName("protoport");

                entity.Property(e => e.Servicedescription)
                    .IsRequired()
                    .HasColumnName("servicedescription");

                entity.Property(e => e.Servicename)
                    .IsRequired()
                    .HasColumnName("servicename");
            });

            modelBuilder.Entity<TimestampObject>(entity =>
            {
                entity.HasNoKey();

                entity.ToTable("timestamp_object");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");
            });

            modelBuilder.Entity<Unknown>(entity =>
            {
                entity.HasKey(e => new { e.UnknownType, e.UnknownKey })
                    .HasName("unknown_pkey");

                entity.ToTable("unknown");

                entity.Property(e => e.UnknownType).HasColumnName("unknown_type");

                entity.Property(e => e.UnknownKey).HasColumnName("unknown_key");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.JsonData)
                    .HasColumnName("json_data")
                    .HasColumnType("jsonb");

                entity.Property(e => e.LastModified)
                    .HasColumnName("last_modified")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.LastSeen)
                    .HasColumnName("last_seen")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.Status).HasColumnName("status");
            });

            modelBuilder.Entity<V2Log>(entity =>
            {
                entity.HasNoKey();

                entity.ToTable("v2_log");

                entity.Property(e => e.DateAdded)
                    .HasColumnName("date_added")
                    .HasDefaultValueSql("now()");

                entity.Property(e => e.NewValue).HasColumnName("new_value");

                entity.Property(e => e.OldValue).HasColumnName("old_value");

                entity.Property(e => e.TableField).HasColumnName("table_field");

                entity.Property(e => e.TableName).HasColumnName("table_name");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
