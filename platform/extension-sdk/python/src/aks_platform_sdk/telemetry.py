import json
import os
from dataclasses import dataclass


@dataclass(frozen=True)
class PlatformTelemetryClient:
    enabled: bool
    service_name: str

    def track_event(self, name: str, properties: dict[str, str] | None = None) -> None:
        if not self.enabled:
            return

        print(json.dumps({
            "type": "platform.telemetry.event",
            "serviceName": self.service_name,
            "name": name,
            "properties": properties or {},
        }))


def configure_platform_telemetry(
    service_name: str,
    connection_string: str | None = None,
    enabled: bool = True,
) -> PlatformTelemetryClient:
    if not enabled or not connection_string:
        return PlatformTelemetryClient(enabled=False, service_name=service_name)

    os.environ["APPLICATIONINSIGHTS_CONNECTION_STRING"] = connection_string
    os.environ["OTEL_SERVICE_NAME"] = service_name

    from azure.monitor.opentelemetry import configure_azure_monitor

    configure_azure_monitor(connection_string=connection_string)
    return PlatformTelemetryClient(enabled=True, service_name=service_name)
