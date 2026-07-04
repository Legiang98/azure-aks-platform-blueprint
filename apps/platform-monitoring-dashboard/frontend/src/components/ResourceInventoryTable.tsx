import type { ResourceInventoryItem } from "../api/client";

interface Props {
  resources: ResourceInventoryItem[];
}

export default function ResourceInventoryTable({ resources }: Props) {
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Layer</th>
            <th>Resource</th>
            <th>Status</th>
            <th>Managed By</th>
            <th>Purpose</th>
          </tr>
        </thead>
        <tbody>
          {resources.map((item) => (
            <tr key={`${item.layer}-${item.resource}`}>
              <td>{item.layer}</td>
              <td>{item.resource}</td>
              <td><span className="badge compact">{item.status}</span></td>
              <td>{item.managedBy}</td>
              <td>{item.purpose}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
