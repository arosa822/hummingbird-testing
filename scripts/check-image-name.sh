#!/bin/bash
# Check correct Hummingbird image name from properties.yml
# Usage: ./check-image-name.sh <image-directory-name>

set -euo pipefail

CONTAINERS_REPO="/workspace/artifacts/containers"
IMAGE_DIR_NAME="${1:-}"

if [ -z "$IMAGE_DIR_NAME" ]; then
    echo "Usage: $0 <image-directory-name>"
    echo "Example: $0 python-3-13"
    exit 1
fi

PROPERTIES_FILE="${CONTAINERS_REPO}/images/${IMAGE_DIR_NAME}/properties.yml"

if [ ! -f "$PROPERTIES_FILE" ]; then
    echo "❌ ERROR: Properties file not found: $PROPERTIES_FILE"
    echo ""
    echo "Available images:"
    ls -1 "${CONTAINERS_REPO}/images/" | head -20
    exit 1
fi

echo "Checking image: $IMAGE_DIR_NAME"
echo "Properties file: $PROPERTIES_FILE"
echo ""

# Extract repository and stream
REPOSITORY=$(grep "^repository:" "$PROPERTIES_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")
STREAM=$(grep "^stream:" "$PROPERTIES_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")

if [ -z "$REPOSITORY" ] || [ -z "$STREAM" ]; then
    echo "❌ ERROR: Could not extract repository or stream"
    echo ""
    echo "File contents:"
    head -20 "$PROPERTIES_FILE"
    exit 1
fi

echo "Repository: $REPOSITORY"
echo "Stream: $STREAM"
echo ""
echo "✓ Correct image name:"
echo "  quay.io/hummingbird/${REPOSITORY}:${STREAM}"
echo ""
echo "Also available:"
echo "  quay.io/hummingbird/${REPOSITORY}:latest (may be same)"
echo ""

# Check if there are variants
if grep -q "^variants:" "$PROPERTIES_FILE"; then
    echo "Variants found:"
    grep "^variants:" -A 5 "$PROPERTIES_FILE" | grep "  -" | sed 's/  - /  - quay.io\/hummingbird\/'${REPOSITORY}':${STREAM}-/g'
fi
