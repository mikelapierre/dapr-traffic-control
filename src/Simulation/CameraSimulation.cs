using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Simulation.Events;
using Simulation.Proxies;

namespace Simulation
{
    public class CameraSimulation
    {
        private readonly ITrafficControlService _trafficControlService;
        private Random _rnd;
        private int _camNumber;
        private int _minEntryDelayInMS = 50;
        private int _maxEntryDelayInMS = 5000;
        private int _minExitDelayInS = 4;
        private int _maxExitDelayInS = 10;
        private ILogger _logger;

        public CameraSimulation(int camNumber, ITrafficControlService trafficControlService, ILogger logger)
        {
            _camNumber = camNumber;
            _trafficControlService = trafficControlService;
            _logger = logger;
        }

        public Task Start()
        {
            Log($"Start camera {_camNumber} simulation.");

            // initialize state
            _rnd = new Random();

            while (true)
            {
                try
                {
                    // simulate entry
                    TimeSpan entryDelay = TimeSpan.FromMilliseconds(_rnd.Next(_minEntryDelayInMS, _maxEntryDelayInMS) + _rnd.NextDouble());
                    Task.Delay(entryDelay).Wait();

                    Task.Run(async () =>
                    {
                        // simulate entry
                        DateTime entryTimestamp = DateTime.Now;
                        var vehicleRegistered = new VehicleRegistered
                        {
                            Lane = _camNumber,
                            LicenseNumber = GenerateRandomLicenseNumber(),
                            Timestamp = entryTimestamp
                        };
                        await _trafficControlService.SendVehicleEntryAsync(vehicleRegistered);
                        Log($"Simulated ENTRY of vehicle with license-number {vehicleRegistered.LicenseNumber} in lane {vehicleRegistered.Lane}");

                        // simulate exit
                        TimeSpan exitDelay = TimeSpan.FromSeconds(_rnd.Next(_minExitDelayInS, _maxExitDelayInS) + _rnd.NextDouble());
                        Task.Delay(exitDelay).Wait();
                        vehicleRegistered.Timestamp = DateTime.Now;
                        vehicleRegistered.Lane = _rnd.Next(1, 4);
                        await _trafficControlService.SendVehicleExitAsync(vehicleRegistered);
<<<<<<< HEAD
                        Log($"Simulated EXIT of vehicle with license-number {vehicleRegistered.LicenseNumber} in lane {vehicleRegistered.Lane}");
=======
                        Console.WriteLine($"Simulated EXIT of vehicle with license-number {vehicleRegistered.LicenseNumber} in lane {vehicleRegistered.Lane}");
>>>>>>> 44b83a582d35d208b98a0c48f876b107434369ad
                    }).Wait();
                }
                catch (Exception ex)
                {
<<<<<<< HEAD
                    Log($"Camera {_camNumber} error: {ex.Message}"); 
=======
                    Console.WriteLine($"Camera {_camNumber} error: {ex.Message}");
>>>>>>> 44b83a582d35d208b98a0c48f876b107434369ad
                }
            }
        }

        #region Private helper methods

        private string _validLicenseNumberChars = "DFGHJKLNPRSTXYZ";

        private string GenerateRandomLicenseNumber()
        {
            int type = _rnd.Next(1, 9);
            string kenteken = null;
            switch (type)
            {
                case 1: // 99-AA-99
                    kenteken = string.Format("{0:00}-{1}-{2:00}", _rnd.Next(1, 99), GenerateRandomCharacters(2), _rnd.Next(1, 99));
                    break;
                case 2: // AA-99-AA
                    kenteken = string.Format("{0}-{1:00}-{2}", GenerateRandomCharacters(2), _rnd.Next(1, 99), GenerateRandomCharacters(2));
                    break;
                case 3: // AA-AA-99
                    kenteken = string.Format("{0}-{1}-{2:00}", GenerateRandomCharacters(2), GenerateRandomCharacters(2), _rnd.Next(1, 99));
                    break;
                case 4: // 99-AA-AA
                    kenteken = string.Format("{0:00}-{1}-{2}", _rnd.Next(1, 99), GenerateRandomCharacters(2), GenerateRandomCharacters(2));
                    break;
                case 5: // 99-AAA-9
                    kenteken = string.Format("{0:00}-{1}-{2}", _rnd.Next(1, 99), GenerateRandomCharacters(3), _rnd.Next(1, 10));
                    break;
                case 6: // 9-AAA-99
                    kenteken = string.Format("{0}-{1}-{2:00}", _rnd.Next(1, 9), GenerateRandomCharacters(3), _rnd.Next(1, 10));
                    break;
                case 7: // AA-999-A
                    kenteken = string.Format("{0}-{1:000}-{2}", GenerateRandomCharacters(2), _rnd.Next(1, 999), GenerateRandomCharacters(1));
                    break;
                case 8: // A-999-AA
                    kenteken = string.Format("{0}-{1:000}-{2}", GenerateRandomCharacters(1), _rnd.Next(1, 999), GenerateRandomCharacters(2));
                    break;
            }

            return kenteken;
        }

        private string GenerateRandomCharacters(int aantal)
        {
            char[] chars = new char[aantal];
            for (int i = 0; i < aantal; i++)
            {
                chars[i] = _validLicenseNumberChars[_rnd.Next(_validLicenseNumberChars.Length - 1)];
            }
            return new string(chars);
        }

        private void Log(string log)
        {            
            _logger.LogInformation(log);
            Console.WriteLine(log);
        }

        #endregion
    }
}
