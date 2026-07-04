# SRE Agent Observability Stack

This folder contains the local observability pipeline used by the SRE Agent lab.

Current components:

- `logstash/pipeline/otel.conf` normalizes OpenTelemetry logs and traces before writing to Elasticsearch.
- `otel/config.yaml` receives OTLP traffic and forwards logs to Logstash and traces to APM Server.

The root `docker-compose.yml` still starts Elasticsearch, Kibana, Logstash, OpenTelemetry Collector, and APM Server. Its volume mounts point here so observability config belongs to the SRE Agent project boundary.
