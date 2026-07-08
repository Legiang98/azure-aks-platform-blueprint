#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

ACR_NAME="${ACR_NAME:-craksplatformsea001}"
TAG="${TAG:-demo}"
IMAGE_SCOPE="${IMAGE_SCOPE:-monitoring-dashboard}"

ACR_LOGIN_SERVER="$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)"

az acr login --name "$ACR_NAME"

build_and_push() {
  dockerfile="$1"
  context_dir="$(dirname "$dockerfile")"
  image_name="$(basename "$context_dir")"

  # cartservice Dockerfile is under cartservice/src
  if [ "$image_name" = "src" ]; then
    image_name="$(basename "$(dirname "$context_dir")")"
  fi

  image="$ACR_LOGIN_SERVER/$image_name:$TAG"

  echo "Building $image"
  docker build -t "$image" -f "$dockerfile" "$context_dir"

  echo "Pushing $image"
  docker push "$image"
}

if [ "$IMAGE_SCOPE" = "all" ]; then
  find apps -name Dockerfile ! -name Dockerfile.debug | sort | while read -r dockerfile; do
    build_and_push "$dockerfile"
  done
else
  build_and_push "apps/platform-monitoring-dashboard/backend/Dockerfile"
  build_and_push "apps/platform-monitoring-dashboard/frontend/Dockerfile"
fi
