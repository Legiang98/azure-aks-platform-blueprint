#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

ACR_NAME="${ACR_NAME:-craksplatformsea001}"
CHART_DIR="${CHART_DIR:-helm/platform-app-service}"
CHART_REPOSITORY="${CHART_REPOSITORY:-helm}"
PACKAGE_DIR="${PACKAGE_DIR:-.artifacts/helm}"

ACR_LOGIN_SERVER="$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)"

az acr login --name "$ACR_NAME"

mkdir -p "$PACKAGE_DIR"

echo "Packaging Helm chart from $CHART_DIR"
package_output="$(helm package "$CHART_DIR" --destination "$PACKAGE_DIR")"
chart_package="$(printf '%s\n' "$package_output" | awk -F': ' '/Successfully packaged chart and saved it to:/ {print $2}')"

if [ -z "$chart_package" ]; then
  echo "Could not detect packaged chart path from helm output:"
  printf '%s\n' "$package_output"
  exit 1
fi

echo "Pushing $chart_package to oci://$ACR_LOGIN_SERVER/$CHART_REPOSITORY"
helm push "$chart_package" "oci://$ACR_LOGIN_SERVER/$CHART_REPOSITORY"
