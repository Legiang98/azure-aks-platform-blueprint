from dataclasses import dataclass
from typing import Any

from .credential import create_default_credential


@dataclass
class KeyVaultClient:
    vault_url: str
    credential: Any | None = None

    def __post_init__(self) -> None:
        if not self.vault_url.strip():
            raise ValueError("Key Vault URL is required.")

        from azure.keyvault.secrets import SecretClient

        self._client = SecretClient(
            vault_url=self.vault_url,
            credential=self.credential or create_default_credential(),
        )

    def get_secret(self, name: str) -> str | None:
        return self._client.get_secret(name).value

    def get_required_secret(self, name: str) -> str:
        value = self.get_secret(name)
        if not value:
            raise ValueError(f"Secret '{name}' was found but has no value.")
        return value
