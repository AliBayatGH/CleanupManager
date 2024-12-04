using System.Text.Json;

namespace CleanupManager
{
    public static class Program
    {
        public static async Task Main(string[] args)
        {
            string connectionString = "Server=localhost;Port=3306;Database=TestCleanupDb;User=root;Password=alibayat;";
            string configFilePath = "appsettings.json";

            if (!File.Exists(configFilePath))
            {
                Console.WriteLine($"Configuration file not found: {configFilePath}");
                return;
            }

            var configContent = File.ReadAllText(configFilePath);
            var config = JsonSerializer.Deserialize<AppConfig>(configContent);

            if (config == null)
            {
                Console.WriteLine("Invalid configuration format.");
                return;
            }

            var cleanupManager = new CleanupManager(connectionString, config);

            try
            {
                await cleanupManager.StartCleanupAsync();
                Console.WriteLine("All cleanups completed!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }
        }
    }

    public class AppConfig
    {
        public int BatchSize { get; set; }
        public int DelayBetweenBatches { get; set; }
        public TableConfig[] Tables { get; set; }
    }

    public class TableConfig
    {
        public string TableName { get; set; }
        public string Condition { get; set; }
    }
}
