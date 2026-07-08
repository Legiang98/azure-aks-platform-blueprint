#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

GIT_URL="${GIT_URL:-}"
GIT_BRANCH="${GIT_BRANCH:-main}"
GIT_PATH="${GIT_PATH:-./k8s/flux/clusters/aks-platform}"
ACR_NAME="${ACR_NAME:-craksplatformsea001}"

if [ -z "$GIT_URL" ]; then
  echo "GIT_URL is required."
  echo "Example: GIT_URL=https://github.com/<owner>/<repo>.git ./scripts/bootstrap-flux.sh"
  exit 1
fi

command -v flux >/dev/null 2>&1 || {
  echo "flux CLI is required. Install it first, then rerun this script."
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is required."
  exit 1
}

command -v az >/dev/null 2>&1 || {
  echo "Azure CLI is required."
  exit 1
}

echo "Installing Flux controllers"
flux install

echo "Creating ACR OCI auth secret for Flux source-controller"
ACR_LOGIN_SERVER="$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)"
ACR_ACCESS_TOKEN="$(az acr login --name "$ACR_NAME" --expose-token --query accessToken -o tsv)"

kubectl create secret docker-registry acr-oci-auth \
  --namespace flux-system \
  --docker-server="$ACR_LOGIN_SERVER" \
  --docker-username="00000000-0000-0000-0000-000000000000" \
  --docker-password="$ACR_ACCESS_TOKEN" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

echo "Applying Flux Git source and root kustomization"
cat <<EOF | kubectl apply -f -
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: platform-blueprint
  namespace: flux-system
spec:
  interval: 1m
  ref:
    branch: ${GIT_BRANCH}
  url: "${GIT_URL}"
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: platform-root
  namespace: flux-system
spec:
  interval: 5m
  prune: true
  sourceRef:
    kind: GitRepository
    name: platform-blueprint
  path: ${GIT_PATH}
  wait: true
  timeout: 3m
EOF

echo "Requesting initial reconciliation"
flux reconcile source git platform-blueprint --namespace flux-system
flux reconcile kustomization platform-root --namespace flux-system

echo "Flux bootstrap complete."
echo "Check status with:"
echo "  flux get sources oci -A"
echo "  flux get helmreleases -A"
echo "  kubectl get pods -n platform-monitoring"
