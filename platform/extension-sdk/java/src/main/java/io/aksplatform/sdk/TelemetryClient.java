package io.aksplatform.sdk;

import java.util.Map;

public record TelemetryClient(boolean enabled, String serviceName) {
    public String trackEvent(String name, Map<String, String> properties) {
        if (!enabled) {
            return "";
        }

        return "{\"type\":\"platform.telemetry.event\",\"serviceName\":\""
            + serviceName
            + "\",\"name\":\""
            + name
            + "\",\"properties\":"
            + properties
            + "}";
    }
}
