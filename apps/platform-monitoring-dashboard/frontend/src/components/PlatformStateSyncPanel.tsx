import type { SyncResult } from "../api/client";

interface Props {
  loading: boolean;
  result?: SyncResult;
  onSync: () => void;
}

export default function PlatformStateSyncPanel({ loading, result, onSync }: Props) {
  return (
    <div className="sync-panel">
      <div>
        <h3>Demo-safe platform sync</h3>
        <p>This action reads local demo state only. It does not run Terraform, Pulumi, kubectl, Azure CLI, or GitHub CLI.</p>
      </div>
      <button type="button" onClick={onSync} disabled={loading}>
        {loading ? "Syncing..." : "Sync Platform State"}
      </button>
      {result && (
        <div className="sync-result">
          <strong>{result.status} ({result.mode})</strong>
          <p>{result.message}</p>
          <code>{result.generatedFiles.join(", ")}</code>
        </div>
      )}
    </div>
  );
}
