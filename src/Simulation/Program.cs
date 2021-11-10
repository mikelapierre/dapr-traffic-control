using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Simulation.Proxies;

namespace Simulation
{
    class Program
    {
        static void Main(string[] args)
        {
            IServiceCollection services = new ServiceCollection();
            services.AddLogging(loggingBuilder => loggingBuilder.AddFilter<Microsoft.Extensions.Logging.ApplicationInsights.ApplicationInsightsLoggerProvider>("Category", LogLevel.Information));
            services.AddApplicationInsightsTelemetryWorkerService(Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY"));
            IServiceProvider serviceProvider = services.BuildServiceProvider();
            ILogger<CameraSimulation> logger = serviceProvider.GetRequiredService<ILogger<CameraSimulation>>();

            int lanes = 3;
            CameraSimulation[] cameras = new CameraSimulation[lanes];            
            for (var i = 0; i < lanes; i++)
            {
                int camNumber = i + 1;
                var trafficControlService = new EventHubTrafficControlService(camNumber);
                cameras[i] = new CameraSimulation(camNumber, trafficControlService, logger);
            }
            Parallel.ForEach(cameras, cam => cam.Start());

            Task.Run(() => Thread.Sleep(Timeout.Infinite)).Wait();
        }
    }
}
