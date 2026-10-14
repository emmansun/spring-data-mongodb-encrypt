#!/usr/bin/env bash
# Release script for spring-data-mongodb-encrypt
# Usage:
#   ./scripts/release.sh 2.9.3        # create and push v2.9.3
#   ./scripts/release.sh v2.9.3       # same (v prefix is optional)
#   ./scripts/release.sh 2.9.3 --recreate  # delete existing tag first, then recreate
set -euo pipefail

VERSION="${1:-}"
RECREATE=false

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version> [--recreate]"
  echo "  version   : release version (e.g. 2.9.3 or v2.9.3)"
  echo "  --recreate: delete existing remote/local tag before creating"
  exit 1
fi

# Strip leading 'v' if present
VERSION="${VERSION#v}"
TAG="v${VERSION}"

# Check for --recreate flag
for arg in "$@"; do
  if [[ "$arg" == "--recreate" ]]; then
    RECREATE=true
  fi
done

echo "==> Preparing release ${TAG}"

# Refuse to tag from a dirty working tree (the tag would not match what you are looking at)
if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: working tree is not clean; commit or stash before releasing:"
  git status --short
  exit 1
fi

if [[ "$RECREATE" == true ]]; then
  # Delete local tag if exists
  if git tag -l | grep -q "^${TAG}$"; then
    echo "  Deleting local tag ${TAG}..."
    git tag -d "$TAG"
  fi
  # Delete remote tag if exists
  if git ls-remote --tags origin | grep -q "refs/tags/${TAG}$"; then
    echo "  Deleting remote tag ${TAG}..."
    git push origin ":refs/tags/${TAG}"
  fi
fi

# Create tag
echo "  Creating tag ${TAG}..."
git tag "$TAG"

# Push tag
echo "  Pushing tag ${TAG} to origin..."
git push origin "$TAG"

echo ""
echo "==> Release ${TAG} triggered!"
echo "    Monitor: https://github.com/emmansun/spring-data-mongodb-encrypt/actions/workflows/release.yml"
