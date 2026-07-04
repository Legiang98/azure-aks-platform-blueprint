import type { SecurityControls as Controls } from "../api/client";

interface Props {
  controls: Controls;
}

export default function SecurityControls({ controls }: Props) {
  return (
    <div className="checklist">
      {controls.controls.map((control) => (
        <div className="check-item" key={control.name}>
          <span className="checkmark">✓</span>
          <div>
            <strong>{control.name}</strong>
            <p>{control.category} - {control.evidence}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
