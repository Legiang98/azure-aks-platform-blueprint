import type { DeploymentStatus } from "../api/client";

interface Props {
  deployment: DeploymentStatus;
}

export default function DeploymentTimeline({ deployment }: Props) {
  return (
    <div className="timeline">
      <div className="summary-row">
        <span>Version: {deployment.version}</span>
        <span>Environment: {deployment.environment}</span>
        <span>Status: {deployment.status}</span>
      </div>
      {deployment.steps.map((step) => (
        <div className="timeline-item" key={step.name}>
          <span className="timeline-dot" />
          <div>
            <strong>{step.name}</strong>
            <span className="badge compact">{step.status}</span>
            <p>{step.details}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
