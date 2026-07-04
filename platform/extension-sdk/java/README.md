# Java Platform SDK

Java package skeleton for the AKS platform SDK.

It mirrors the platform SDK contract used by Node/Python:

- Default Azure credential setup
- Key Vault secret access
- Azure SQL Database connection strings using Microsoft Entra authentication
- Lightweight telemetry event wrapper

Publish this package to a private Maven feed such as Azure Artifacts or GitHub Packages before using it from application repositories.
