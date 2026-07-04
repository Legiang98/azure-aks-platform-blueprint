import type { PlatformComponent } from "../api/client";

interface Props {
  component: PlatformComponent;
}

export default function StatusCard({ component }: Props) {
  return (
    <article className="status-card">
      <div>
        <h3>{component.name}</h3>
        <p>{component.description}</p>
      </div>
      <div className="card-footer">
        <span className={`badge ${component.status.toLowerCase()}`}>{component.status}</span>
        <span className="managed-by">{component.managedBy}</span>
      </div>
    </article>
  );
}
