using Microsoft.Data.SqlClient;

namespace AksPlatform.Sdk;

public static class SqlDatabase
{
    public static string CreateEntraConnectionString(string server, string database)
    {
        if (string.IsNullOrWhiteSpace(server))
        {
            throw new ArgumentException("Azure SQL server host is required.", nameof(server));
        }

        if (string.IsNullOrWhiteSpace(database))
        {
            throw new ArgumentException("Azure SQL database name is required.", nameof(database));
        }

        var builder = new SqlConnectionStringBuilder
        {
            DataSource = $"tcp:{server.Trim()},1433",
            InitialCatalog = database.Trim(),
            Encrypt = true,
            TrustServerCertificate = false,
            ConnectTimeout = 30,
            Authentication = SqlAuthenticationMethod.ActiveDirectoryDefault
        };

        return builder.ConnectionString;
    }
}
