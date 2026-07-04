from dataclasses import dataclass
from typing import Any

from .credential import create_default_credential
from .key_vault import KeyVaultClient
from .platform_config import PlatformConfig, create_platform_config_from_env
from .sql_database import SqlDatabaseClient
from .telemetry import PlatformTelemetryClient, configure_platform_telemetry


@dataclass
class PlatformClient:
    config: PlatformConfig
    credential: Any
    key_vault: KeyVaultClient | None = None
    sql_database: SqlDatabaseClient | None = None

    def initialize_telemetry(self, enabled: bool = True) -> PlatformTelemetryClient:
        return configure_platform_telemetry(
            service_name=self.config.service_name,
            connection_string=self.config.application_insights_connection_string,
            enabled=enabled,
        )


def create_platform_client(config: PlatformConfig | None = None, credential: Any | None = None) -> PlatformClient:
    resolved_config = config or create_platform_config_from_env()
    resolved_credential = credential or create_default_credential()

    key_vault = (
        KeyVaultClient(resolved_config.key_vault_url, resolved_credential)
        if resolved_config.key_vault_url
        else None
    )
    sql_database = (
        SqlDatabaseClient(resolved_config.sql_server_host, resolved_config.sql_database_name, resolved_credential)
        if resolved_config.sql_server_host and resolved_config.sql_database_name
        else None
    )

    return PlatformClient(
        config=resolved_config,
        credential=resolved_credential,
        key_vault=key_vault,
        sql_database=sql_database,
    )
