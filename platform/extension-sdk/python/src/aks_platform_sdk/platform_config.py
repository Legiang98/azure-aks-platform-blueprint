import os
from dataclasses import dataclass


@dataclass(frozen=True)
class PlatformConfig:
    environment: str = "local"
    service_name: str = "app"
    key_vault_url: str | None = None
    application_insights_connection_string: str | None = None
    sql_server_host: str | None = None
    sql_database_name: str | None = None


def _env(name: str) -> str | None:
    value = os.getenv(name)
    return value.strip() if value and value.strip() else None


def create_platform_config_from_env(**overrides: str | None) -> PlatformConfig:
    return PlatformConfig(
        environment=overrides.get("environment") or _env("PLATFORM_ENVIRONMENT") or "local",
        service_name=overrides.get("service_name")
        or _env("OTEL_SERVICE_NAME")
        or _env("PLATFORM_SERVICE_NAME")
        or "app",
        key_vault_url=overrides.get("key_vault_url") or _env("PLATFORM_KEY_VAULT_URL"),
        application_insights_connection_string=overrides.get("application_insights_connection_string")
        or _env("APPLICATIONINSIGHTS_CONNECTION_STRING")
        or _env("APPLICATION_INSIGHTS_CONNECTION_STRING"),
        sql_server_host=overrides.get("sql_server_host") or _env("PLATFORM_SQL_SERVER_HOST"),
        sql_database_name=overrides.get("sql_database_name") or _env("PLATFORM_SQL_DATABASE_NAME"),
    )
