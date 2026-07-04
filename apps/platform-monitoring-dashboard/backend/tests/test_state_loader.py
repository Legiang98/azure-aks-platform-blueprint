from pathlib import Path

from app.models.platform import PlatformSnapshot
from app.services.state_loader import StateLoader


def test_state_loader_reads_platform_snapshot() -> None:
    data_dir = Path(__file__).resolve().parents[1] / "data"
    snapshot = StateLoader(data_dir).load("platform-snapshot.json", PlatformSnapshot)

    assert snapshot.platformName == "Azure AKS Platform Blueprint"
    assert snapshot.components
