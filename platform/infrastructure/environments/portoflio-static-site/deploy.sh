#!/usr/bin/env bash
set -euo pipefail

STATIC_WEB_APP_NAME="${STATIC_WEB_APP_NAME:-swa-aks-platform-portfolio}"
STATIC_WEB_APP_RESOURCE_GROUP="${STATIC_WEB_APP_RESOURCE_GROUP:-portfolio-static-rg}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STATIC_SITE_ROOT="${STATIC_SITE_ROOT:-$SCRIPT_DIR}"
SITE_DIR="${SITE_DIR:-$STATIC_SITE_ROOT/site}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$STATIC_SITE_ROOT/.artifacts/static-site}"
DEPLOY_ENVIRONMENT="${DEPLOY_ENVIRONMENT:-production}"

if ! command -v az >/dev/null 2>&1; then
  echo "Missing Azure CLI. Install az and run az login first." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Missing npm. Install Node.js/npm to run the Azure Static Web Apps CLI through npx." >&2
  exit 1
fi

if [ ! -d "$SITE_DIR" ]; then
  echo "Static site directory does not exist: $SITE_DIR" >&2
  exit 1
fi

mkdir -p "$ARTIFACT_DIR"
zip_path="$ARTIFACT_DIR/portfolio-static-site.zip"

echo "Creating local artifact: $zip_path"
(cd "$SITE_DIR" && zip -qr "$zip_path" .)

echo "Reading Azure Static Web Apps deployment token for $STATIC_WEB_APP_NAME"
deployment_token="$(
  az staticwebapp secrets list \
    --name "$STATIC_WEB_APP_NAME" \
    --resource-group "$STATIC_WEB_APP_RESOURCE_GROUP" \
    --query "properties.apiKey" \
    -o tsv
)"

if [ -z "$deployment_token" ]; then
  echo "Could not read Static Web Apps deployment token." >&2
  exit 1
fi

echo "Deploying $SITE_DIR to Azure Static Web Apps environment: $DEPLOY_ENVIRONMENT"
npx -y @azure/static-web-apps-cli deploy "$SITE_DIR" \
  --deployment-token "$deployment_token" \
  --env "$DEPLOY_ENVIRONMENT"

echo "Deployment completed."
