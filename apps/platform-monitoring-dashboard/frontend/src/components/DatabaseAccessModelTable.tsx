import type { DatabaseAccessModel } from "../api/client";

interface Props {
  model: DatabaseAccessModel;
}

export default function DatabaseAccessModelTable({ model }: Props) {
  return (
    <div className="stack">
      <div className="summary-row">
        <span>Infrastructure: {model.infrastructureManagedBy}</span>
        <span>Access: {model.managedBy}</span>
        <span>Schema: {model.schemaMigrationManagedBy}</span>
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Principal</th>
              <th>Type</th>
              <th>Role</th>
              <th>Purpose</th>
              <th>Managed By</th>
            </tr>
          </thead>
          <tbody>
            {model.principals.map((principal) => (
              <tr key={principal.name}>
                <td>{principal.name}</td>
                <td>{principal.type}</td>
                <td>{principal.role}</td>
                <td>{principal.purpose}</td>
                <td>{principal.managedBy}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <ul className="notes">
        {model.notes.map((note) => <li key={note}>{note}</li>)}
      </ul>
    </div>
  );
}
