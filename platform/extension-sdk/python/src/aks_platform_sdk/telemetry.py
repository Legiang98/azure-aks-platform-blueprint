import json
import os
from dataclasses import dataclass
from typing import Any


@dataclass
class PlatformTelemetryClient:
    enabled: bool
    service_name: str
    _client: Any | None = None

    def track_event(self, name: str, properties: dict[str, str] | None = None) -> None:
        if not self.enabled:
            return

        event_properties = {"serviceName": self.service_name, **(properties or {})}
        if self._client:
            self._client.track_event(name, event_properties)
            return

        print(json.dumps({
            "type": "platform.telemetry.event",
            "serviceName": self.service_name,
            "name": name,
            "properties": event_properties,
        }))

    def flush(self) -> None:
        if self._client:
            self._client.flush()


def configure_platform_telemetry(
    service_name: str,
    connection_string: str | None = None,
    enabled: bool = True,
) -> PlatformTelemetryClient:
    if not enabled or not connection_string:
        return PlatformTelemetryClient(enabled=False, service_name=service_name)

    os.environ["APPLICATIONINSIGHTS_CONNECTION_STRING"] = connection_string
    os.environ["APPLICATIONINSIGHTS_ROLE_NAME"] = service_name

    instrumentation_key = _read_instrumentation_key(connection_string)
    if not instrumentation_key:
        return PlatformTelemetryClient(enabled=False, service_name=service_name)

    from applicationinsights import TelemetryClient

    return PlatformTelemetryClient(
        enabled=True,
        service_name=service_name,
        _client=TelemetryClient(instrumentation_key),
    )


def _read_instrumentation_key(connection_string: str) -> str | None:
    for part in connection_string.split(";"):
        key, _, value = part.partition("=")
        if key.strip().lower() == "instrumentationkey" and value.strip():
            return value.strip()
    return None
