import type { ObservabilitySnapshot as Snapshot } from "../api/client";

interface Props {
  snapshot: Snapshot;
}

export default function ObservabilitySnapshot({ snapshot }: Props) {
  const metrics = [
    ["API Health", snapshot.apiHealth],
    ["P95 Latency", `${snapshot.p95LatencyMs}ms`],
    ["Error Rate", `${(snapshot.errorRate * 100).toFixed(2)}%`],
    ["Pod Readiness", snapshot.podReadiness],
    ["DB Connectivity", snapshot.dbConnectivity],
    ["Last Alert", snapshot.lastAlert],
    ["Metrics", snapshot.metricsEnabled ? "Enabled" : "Disabled"],
    ["Logs", snapshot.logsEnabled ? "Enabled" : "Disabled"],
    ["Traces", snapshot.tracesEnabled ? "Enabled" : "Disabled"]
  ];

  return (
    <div className="metric-grid">
      {metrics.map(([label, value]) => (
        <div className="metric-card" key={label}>
          <span>{label}</span>
          <strong>{value}</strong>
        </div>
      ))}
    </div>
  );
}
