using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using netbehave_wwwv2.Data;
using VueCliMiddleware;

namespace netbehave_wwwv2
{
    public class Startup
    {
        private ILogger<Startup> _logger;

        private void LogInformation(string msg)
        {
            if (_logger != null) { 
                _logger.LogInformation("*** (I):Startup::" + msg); 
            } else
            {
                Console.WriteLine("*** c/(I):Startup::" + msg);
            }
        }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
            _logger = null;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.

        public void ConfigureServices(IServiceCollection services)
        {
            LogInformation("ConfigureServices()");
            services.AddControllers();

            services.AddDbContext<nbv2Context>(options => options.UseNpgsql(Configuration.GetConnectionString("nbv2"))
                //.UseLazyLoadingProxies()
                );

            if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                ConfigureServices_WindowsVisualStudio(services);
            }
            else
            {
                ConfigureServices_LinuxDocker(services);
            }

        }


        private void ConfigureServices_WindowsVisualStudio(IServiceCollection services)
        {
            LogInformation("ConfigureServices_WindowsVisualStudio()"); 
            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath  = "ClientApp";

            });
        }

        private void ConfigureServices_LinuxDocker(IServiceCollection services)
        {
            LogInformation("ConfigureServices_LinuxDocker()");
            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "/";
            });
        }





        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILogger<Startup> logger)
        {
            _logger = logger;
            LogInformation("Configure()");
            LogInformation("... env.ApplicationName=" + env.ApplicationName + ")");
            // LogInformation("... env.ContentRootFileProvider=" + env.ContentRootFileProvider + ")");
            LogInformation("... env.ContentRootPath=" + env.ContentRootPath + ")");
            LogInformation("... env.EnvironmentName=" + env.EnvironmentName + ")");
            // LogInformation("... env.WebRootFileProvider=" + env.WebRootFileProvider + ")");
            LogInformation("... env.WebRootPath=" + env.WebRootPath + ")");
            LogInformation("... Environment.OSVersion=" + Environment.OSVersion + ")");

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();
            app.UseAuthorization();

            if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                Configure_WindowsVisualStudio(app, env);
            }
            else
            {
                Configure_LinuxDocker(app, env);
            }
        }

        public void Configure_WindowsVisualStudio(IApplicationBuilder app, IWebHostEnvironment env)
        {
            LogInformation("Configure_WindowsVisualStudio()");

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });


            // app.UseSpaStaticFiles();
            app.UseSpa(spa =>
            {
                if (env.IsDevelopment()) { 
                    spa.Options.SourcePath = "ClientApp";
                } else { 
                    spa.Options.SourcePath = "ClientApp";
                    // spa.Options.SourcePath = "/src/dist";
                }

                if (env.IsDevelopment())
                {
                    spa.UseVueCli(npmScript: "serve");
                }
                else
                {
                    // spa.UseVueCli(npmScript: "serve");
                }

            });
            /*
            /* */

        }
        public void Configure_LinuxDocker(IApplicationBuilder app, IWebHostEnvironment env)
        {
            LogInformation("Configure_LinuxDocker()");
            string WebRootPath = Configuration["WebRootPath"];  // from config/CommandLine/Env
            if (string.IsNullOrEmpty(WebRootPath))
            {
                // 
                // WebRootPath = Environment.CurrentDirectory; // dist"; // env.CurrentPath;
                // 
                WebRootPath += "/app";
            }
            LogInformation("WebRootPath=[" + WebRootPath + "]");

            app.UseSpaStaticFiles();

            if (string.IsNullOrEmpty(WebRootPath))
            {
                app.UseStaticFiles();
            }
            else
            {
                app.UseStaticFiles(new StaticFileOptions
                {
                    FileProvider = new PhysicalFileProvider(WebRootPath),
                    RequestPath = new PathString("")
                });
            }


            /*
                app.UseStaticFiles(new StaticFileOptions
                {
                    FileProvider = new PhysicalFileProvider(
                        Path.Combine(WebRootPath, "")),
                    RequestPath = "index.html"
                });
            */


            app.UseSpa(spa =>
            {
                if (env.IsDevelopment())
                {
                    spa.Options.SourcePath = "ClientApp";
                }
                else
                {
                    //                    
                    spa.Options.SourcePath = "wwwroot";
                    // spa.Options.SourcePath = "ClientApp";
                }

                if (env.IsDevelopment())
                {
                    spa.UseVueCli(npmScript: "serve");
                }
                else
                {
                    // spa.UseVueCli(npmScript: "serve");
                }

            });

            /*
                        if (env.IsDevelopment()) {
                        } else {
                            app.UseDefaultFiles();
                            // app.UseStaticFiles();

                        }
            */

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }

    }
}
