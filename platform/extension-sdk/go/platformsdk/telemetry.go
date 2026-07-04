package platformsdk

import "encoding/json"

type TelemetryClient struct {
	Enabled     bool
	ServiceName string
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
	return string(payload)
}
