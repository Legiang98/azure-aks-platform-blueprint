package platformsdk

import "os"

type Config struct {
	Environment                         string
	ServiceName                         string
	KeyVaultURL                         string
	ApplicationInsightsConnectionString string
	SQLServerHost                       string
	SQLDatabaseName                     string
}

func ConfigFromEnv() Config {
	return Config{
		Environment:                         env("PLATFORM_ENVIRONMENT", "local"),
		ServiceName:                         firstEnv("PLATFORM_SERVICE_NAME", "APPLICATIONINSIGHTS_ROLE_NAME", "app"),
		KeyVaultURL:                         os.Getenv("PLATFORM_KEY_VAULT_URL"),
		ApplicationInsightsConnectionString: firstEnv("APPLICATIONINSIGHTS_CONNECTION_STRING", "APPLICATION_INSIGHTS_CONNECTION_STRING", ""),
		SQLServerHost:                       os.Getenv("PLATFORM_SQL_SERVER_HOST"),
		SQLDatabaseName:                     os.Getenv("PLATFORM_SQL_DATABASE_NAME"),
	}
}

func env(name string, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func firstEnv(first string, second string, fallback string) string {
	if value := os.Getenv(first); value != "" {
		return value
	}
	return env(second, fallback)
}
