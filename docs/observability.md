# Observability

## Intent

Observability for this blueprint should make platform behavior inspectable across Azure infrastructure, AKS, ingress, workloads, and database security dependencies.

## Signals

- Metrics for AKS nodes, pods, ingress, and platform services.
- Logs for control plane, workloads, ingress, and security-relevant events.
- Traces where application examples support distributed tracing.
- Alerts for availability, saturation, error rate, certificate expiration, and identity or secret access failures.

## Azure Platform Pattern

Use Azure-native monitoring services where appropriate, including diagnostic settings, Log Analytics, Container Insights, Azure Monitor alerts, and dashboards.

## Kubernetes Pattern

Document namespace, workload, ingress, and platform component observability requirements as Kubernetes examples are added.

## Public Demo Boundary

Do not include real workspace IDs, tenant IDs, subscription IDs, private hostnames, or production alert destinations.

## Future Improvements

- Add dashboard examples.
- Add alert rule examples.
- Add log query examples with generic resource names.
