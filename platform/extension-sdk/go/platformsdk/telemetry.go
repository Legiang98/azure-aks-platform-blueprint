package platformsdk

import (
	"encoding/json"
	"strings"

	"github.com/microsoft/ApplicationInsights-Go/appinsights"
)

type TelemetryClient struct {
	Enabled             bool
	ServiceName         string
	applicationInsights appinsights.TelemetryClient
}

func (client TelemetryClient) TrackEvent(name string, properties map[string]string) string {
	if !client.Enabled {
		return ""
	}

	payload, _ := json.Marshal(map[string]any{
		"type":        "platform.telemetry.event",
		"serviceName": client.ServiceName,
		"name":        name,
		"properties":  properties,
	})
	if client.applicationInsights != nil {
		event := appinsights.NewEventTelemetry(name)
		event.Properties["serviceName"] = client.ServiceName
		for key, value := range properties {
			event.Properties[key] = value
		}
		client.applicationInsights.Track(event)
	}

	return string(payload)
}

func (client TelemetryClient) Flush() {
	if client.applicationInsights != nil {
		client.applicationInsights.Channel().Flush()
	}
}

func ConfigureApplicationInsights(serviceName string, connectionString string, enabled bool) TelemetryClient {
	if !enabled || connectionString == "" {
		return TelemetryClient{Enabled: false, ServiceName: serviceName}
	}

	instrumentationKey := instrumentationKeyFromConnectionString(connectionString)
	if instrumentationKey == "" {
		return TelemetryClient{Enabled: false, ServiceName: serviceName}
	}

	return TelemetryClient{
		Enabled:             true,
		ServiceName:         serviceName,
		applicationInsights: appinsights.NewTelemetryClient(instrumentationKey),
	}
}

func instrumentationKeyFromConnectionString(connectionString string) string {
	for _, part := range strings.Split(connectionString, ";") {
		key, value, found := strings.Cut(part, "=")
		if found && strings.EqualFold(strings.TrimSpace(key), "InstrumentationKey") {
			return strings.TrimSpace(value)
		}
	}
	return ""
}
