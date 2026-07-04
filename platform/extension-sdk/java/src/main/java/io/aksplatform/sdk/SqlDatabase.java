package io.aksplatform.sdk;

public final class SqlDatabase {
    private SqlDatabase() {}

    public static String entraConnectionString(String server, String database) {
        if (server == null || server.isBlank()) {
            throw new IllegalArgumentException("Azure SQL server host is required.");
        }
        if (database == null || database.isBlank()) {
            throw new IllegalArgumentException("Azure SQL database name is required.");
        }

        return String.join(";",
            "jdbc:sqlserver://" + server.trim() + ":1433",
            "database=" + database.trim(),
            "authentication=ActiveDirectoryDefault",
            "encrypt=true",
            "trustServerCertificate=false",
            "loginTimeout=30"
        );
    }
}
