using MySql.Data.MySqlClient;

namespace CleanupManager;

public class CleanupManager
{
    private readonly string _connectionString;
    private readonly AppConfig _config;

    public CleanupManager(string connectionString, AppConfig config)
    {
        _connectionString = connectionString;
        _config = config;
    }

    public async Task StartCleanupAsync()
    {
        foreach (var tableConfig in _config.Tables)
        {
            Console.WriteLine($"Starting cleanup for table: {tableConfig.TableName}");

            string deleteSql = $@"
                DELETE FROM {tableConfig.TableName} 
                WHERE {tableConfig.Condition} 
                LIMIT {_config.BatchSize};
            ";

            int rowsAffected;
            do
            {
                rowsAffected = await ExecuteDeleteBatchAsync(deleteSql);
                Console.WriteLine(deleteSql);
                Console.WriteLine($"Deleted {rowsAffected} rows from {tableConfig.TableName}.");

                // Delay between batches to reduce I/O impact
                await Task.Delay(_config.DelayBetweenBatches);
            } while (rowsAffected > 0);
        }
    }

    private async Task<int> ExecuteDeleteBatchAsync(string sql)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        using var command = connection.CreateCommand();
        command.CommandText = sql;

        return await command.ExecuteNonQueryAsync();
    }
}
