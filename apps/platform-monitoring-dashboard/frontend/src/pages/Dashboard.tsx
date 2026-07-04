import { useEffect, useState } from "react";
import {
  api,
  type DatabaseAccessModel,
  type DeploymentStatus,
  type ObservabilitySnapshot,
  type PlatformSnapshot,
  type ResourceInventory,
  type SecurityControls as SecurityControlsType,
  type SyncResult
} from "../api/client";
import DatabaseAccessModelTable from "../components/DatabaseAccessModelTable";
import DeploymentTimeline from "../components/DeploymentTimeline";
import ObservabilitySnapshotView from "../components/ObservabilitySnapshot";
import PlatformStateSyncPanel from "../components/PlatformStateSyncPanel";
import ResourceInventoryTable from "../components/ResourceInventoryTable";
import SecurityControls from "../components/SecurityControls";
import StatusCard from "../components/StatusCard";

export default function Dashboard() {
  const [platform, setPlatform] = useState<PlatformSnapshot>();
  const [resources, setResources] = useState<ResourceInventory>();
  const [databaseAccess, setDatabaseAccess] = useState<DatabaseAccessModel>();
  const [deployment, setDeployment] = useState<DeploymentStatus>();
  const [observability, setObservability] = useState<ObservabilitySnapshot>();
  const [security, setSecurity] = useState<SecurityControlsType>();
  const [syncResult, setSyncResult] = useState<SyncResult>();
  const [loading, setLoading] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [error, setError] = useState<string>();

  useEffect(() => {
    async function load() {
      try {
        const [
          platformSnapshot,
          resourceInventory,
          databaseAccessModel,
          latestDeployment,
          observabilitySnapshot,
          securityControls
        ] = await Promise.all([
          api.platformSnapshot(),
          api.resourceInventory(),
          api.databaseAccessModel(),
          api.latestDeployment(),
          api.observabilitySnapshot(),
          api.securityControls()
        ]);

        setPlatform(platformSnapshot);
        setResources(resourceInventory);
        setDatabaseAccess(databaseAccessModel);
        setDeployment(latestDeployment);
        setObservability(observabilitySnapshot);
        setSecurity(securityControls);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to load platform state.");
      } finally {
        setLoading(false);
      }
    }

    void load();
  }, []);

  async function handleSync() {
    setSyncing(true);
    setError(undefined);
    try {
      setSyncResult(await api.syncPlatformState());
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to sync platform state.");
    } finally {
      setSyncing(false);
    }
  }

  if (loading) {
    return <main className="shell"><p>Loading platform state...</p></main>;
  }

  return (
    <main className="shell">
      <header className="hero">
        <span className="eyebrow">Internal platform service demo</span>
        <h1>Azure Platform Monitoring Center</h1>
        <p>
          A demo-safe dashboard/API for visualizing AKS platform health, resource inventory, database access,
          deployments, observability, and security controls.
        </p>
      </header>

      {error && <div className="error">{error}</div>}

      <section className="panel">
        <div className="section-heading">
          <h2>Platform Snapshot</h2>
          <span>{platform?.platformName} / {platform?.environment} / {platform?.region}</span>
        </div>
        <div className="card-grid">
          {platform?.components.map((component) => <StatusCard key={component.name} component={component} />)}
        </div>
      </section>

      <section className="panel">
        <h2>Resource Inventory</h2>
        {resources && <ResourceInventoryTable resources={resources.resources} />}
      </section>

      <section className="panel">
        <h2>Database Access Model</h2>
        {databaseAccess && <DatabaseAccessModelTable model={databaseAccess} />}
      </section>

      <section className="panel">
        <h2>Deployment Pipeline</h2>
        {deployment && <DeploymentTimeline deployment={deployment} />}
      </section>

      <section className="panel">
        <h2>Observability Snapshot</h2>
        {observability && <ObservabilitySnapshotView snapshot={observability} />}
      </section>

      <section className="panel">
        <h2>Security Controls</h2>
        {security && <SecurityControls controls={security} />}
      </section>

      <section className="panel">
        <h2>Platform State Sync</h2>
        <PlatformStateSyncPanel loading={syncing} result={syncResult} onSync={handleSync} />
      </section>
    </main>
  );
}
