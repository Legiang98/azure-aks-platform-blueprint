#!/usr/bin/env bash
set -euo pipefail

# Bootstrap GitHub repository variables required by the portfolio CI/CD workflows.
#
# Usage:
#   .github/scripts/github_repo_bootsrap.sh
#   .github/scripts/github_repo_bootsrap.sh --repo owner/repository
#
# The values below are lab defaults for this portfolio repository. Subscription
# and tenant IDs are intentionally not hardcoded; pass them through environment
# variables or let Azure CLI provide them from the active account where possible.

REPO="${GITHUB_REPOSITORY:-Legiang98/azure-aks-platform-blueprint}"
ALLOW_PLACEHOLDERS="false"
STATIC_SITE_ONLY="false"
TERRAFORM_DIR="${TERRAFORM_DIR:-platform/infrastructure/environments/dev}"

AZURE_CLIENT_ID="${AZURE_CLIENT_ID:-}"
AZURE_TENANT_ID="${AZURE_TENANT_ID:-CHANGE_ME_AZURE_TENANT_ID}"
AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-CHANGE_ME_AZURE_SUBSCRIPTION_ID}"
AZURE_ACR_NAME="${AZURE_ACR_NAME:-craksplatformdemo001}"
AZURE_STATIC_WEB_APP_NAME="${AZURE_STATIC_WEB_APP_NAME:-swa-aks-platform-portfolio}"
AZURE_STATIC_WEB_APP_RESOURCE_GROUP="${AZURE_STATIC_WEB_APP_RESOURCE_GROUP:-portfolio-static-rg}"

usage() {
  cat <<'EOF'
Bootstrap GitHub repository variables for AKS platform blueprint workflows.

Options:
  --repo owner/repository     Target GitHub repository. Defaults to current gh repo.
  --static-site-only          Bootstrap only Static Web App variables and deployment token.
  --allow-placeholders        Allow CHANGE_ME_* placeholder values to be written.
  -h, --help                  Show this help.

Environment overrides:
  AZURE_CLIENT_ID
  AZURE_TENANT_ID
  AZURE_SUBSCRIPTION_ID
  AZURE_ACR_NAME
  AZURE_STATIC_WEB_APP_NAME
  AZURE_STATIC_WEB_APP_RESOURCE_GROUP
  TERRAFORM_DIR

Required GitHub CLI auth:
  gh auth login

Required Azure/GitHub setup outside this script:
  - Azure federated credential for GitHub OIDC.
  - AcrPush role assigned to the GitHub Actions identity for the target ACR.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --allow-placeholders)
      ALLOW_PLACEHOLDERS="true"
      shift
      ;;
    --static-site-only)
      STATIC_SITE_ONLY="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

try_set_from_terraform_output() {
  output_name="$1"

  if ! command -v terraform >/dev/null 2>&1; then
    return 1
  fi

  if [ ! -d "$TERRAFORM_DIR" ]; then
    return 1
  fi

  terraform -chdir="$TERRAFORM_DIR" output -raw "$output_name" 2>/dev/null || true
}

try_set_tenant_from_azure_cli() {
  if ! command -v az >/dev/null 2>&1; then
    return 1
  fi

  az account show --query tenantId -o tsv 2>/dev/null || true
}

try_set_subscription_from_azure_cli() {
  if ! command -v az >/dev/null 2>&1; then
    return 1
  fi

  az account show --query id -o tsv 2>/dev/null || true
}

try_get_static_web_app_token() {
  if ! command -v az >/dev/null 2>&1; then
    return 1
  fi

  az staticwebapp secrets list \
    --name "$AZURE_STATIC_WEB_APP_NAME" \
    --resource-group "$AZURE_STATIC_WEB_APP_RESOURCE_GROUP" \
    --query "properties.apiKey" \
    -o tsv 2>/dev/null || true
}

is_placeholder() {
  case "$1" in
    CHANGE_ME_*|"")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_value() {
  name="$1"
  value="$2"

  if [ "$ALLOW_PLACEHOLDERS" = "true" ]; then
    return 0
  fi

  if is_placeholder "$value"; then
    echo "Missing value for $name. Set it in the script or export $name before running." >&2
    return 1
  fi
}

set_repo_variable() {
  name="$1"
  value="$2"

  validate_value "$name" "$value"
  echo "Setting GitHub repository variable: $name"
  gh variable set "$name" --body "$value" --repo "$REPO"
}

set_repo_secret() {
  name="$1"
  value="$2"

  if [ -z "$value" ]; then
    echo "Skipping GitHub repository secret: $name is empty"
    return 0
  fi

  echo "Setting GitHub repository secret: $name"
  printf '%s' "$value" | gh secret set "$name" --repo "$REPO"
}

require_command gh

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

if [ "$STATIC_SITE_ONLY" != "true" ]; then
  if is_placeholder "$AZURE_CLIENT_ID"; then
    AZURE_CLIENT_ID=""
  fi

  if [ -z "$AZURE_CLIENT_ID" ]; then
    AZURE_CLIENT_ID="$(try_set_from_terraform_output github_actions_client_id)"
  fi
fi

if is_placeholder "$AZURE_TENANT_ID"; then
  detected_tenant_id="$(try_set_tenant_from_azure_cli)"
  if [ -n "$detected_tenant_id" ]; then
    AZURE_TENANT_ID="$detected_tenant_id"
  fi
fi

if is_placeholder "$AZURE_SUBSCRIPTION_ID"; then
  detected_subscription_id="$(try_set_subscription_from_azure_cli)"
  if [ -n "$detected_subscription_id" ]; then
    AZURE_SUBSCRIPTION_ID="$detected_subscription_id"
  fi
fi

if [ -z "$REPO" ]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

echo "Bootstrapping repository variables for: $REPO"

if [ "$STATIC_SITE_ONLY" != "true" ]; then
  set_repo_variable "AZURE_CLIENT_ID" "$AZURE_CLIENT_ID"
  set_repo_variable "AZURE_TENANT_ID" "$AZURE_TENANT_ID"
  set_repo_variable "AZURE_SUBSCRIPTION_ID" "$AZURE_SUBSCRIPTION_ID"
  set_repo_variable "AZURE_ACR_NAME" "$AZURE_ACR_NAME"
fi

set_repo_variable "AZURE_STATIC_WEB_APP_NAME" "$AZURE_STATIC_WEB_APP_NAME"
set_repo_variable "AZURE_STATIC_WEB_APP_RESOURCE_GROUP" "$AZURE_STATIC_WEB_APP_RESOURCE_GROUP"

static_web_app_token="$(try_get_static_web_app_token)"
set_repo_secret "AZURE_STATIC_WEB_APPS_API_TOKEN" "$static_web_app_token"

echo "GitHub repository bootstrap completed."
