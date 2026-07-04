from typing import Any


def create_default_credential() -> Any:
    from azure.identity import DefaultAzureCredential

    return DefaultAzureCredential()
