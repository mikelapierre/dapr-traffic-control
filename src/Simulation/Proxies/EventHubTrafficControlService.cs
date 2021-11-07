using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Simulation.Events;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Simulation.Proxies
{
    public class EventHubTrafficControlService : ITrafficControlService
    {
        private EventHubProducerClient entryProducerClient;
        private EventHubProducerClient exitProducerClient;

        public EventHubTrafficControlService(int camNumber)
        {
            var connectionString = Environment.GetEnvironmentVariable("EH_CONNECTIONSTRING");
            entryProducerClient = new EventHubProducerClient(connectionString, "entrycam", new EventHubProducerClientOptions() { Identifier = $"camerasim{camNumber}" });
            exitProducerClient = new EventHubProducerClient(connectionString, "exitcam", new EventHubProducerClientOptions() { Identifier = $"camerasim{camNumber}" });
        }

        public async Task SendVehicleEntryAsync(VehicleRegistered vehicleRegistered)
        {
            var eventJson = JsonSerializer.Serialize(vehicleRegistered);
            await entryProducerClient.SendAsync(new EventData[] { new EventData(Encoding.UTF8.GetBytes(eventJson)) });
        }

        public async Task SendVehicleExitAsync(VehicleRegistered vehicleRegistered)
        {
            var eventJson = JsonSerializer.Serialize(vehicleRegistered);
            await exitProducerClient.SendAsync(new EventData[] { new EventData(Encoding.UTF8.GetBytes(eventJson)) });
        }
    }
}
