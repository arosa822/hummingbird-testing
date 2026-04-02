#!/bin/bash
# Show batch progress and suggest next batch
# Usage: ./batch-progress.sh

set -euo pipefail

PHASE1_DIR="/workspace/artifacts/hummingbird-testing/phase1-tests"
TOTAL_IMAGES=44

echo "=========================================="
echo "Phase 1 Batch Progress"
echo "=========================================="
echo ""

# Count tested images (those with test.sh)
TESTED_IMAGES=()
for dir in "$PHASE1_DIR"/*/; do
    if [ -f "${dir}test.sh" ]; then
        IMAGE_NAME=$(basename "$dir")
        TESTED_IMAGES+=("$IMAGE_NAME")
    fi
done

TESTED_COUNT=${#TESTED_IMAGES[@]}
REMAINING=$((TOTAL_IMAGES - TESTED_COUNT))
PROGRESS=$((TESTED_COUNT * 100 / TOTAL_IMAGES))

echo "Total Images: $TOTAL_IMAGES"
echo "Tested: $TESTED_COUNT"
echo "Remaining: $REMAINING"
echo "Progress: $PROGRESS%"
echo ""

# Count with integration tests
INTEGRATION_COUNT=0
for img in "${TESTED_IMAGES[@]}"; do
    if [ -d "${PHASE1_DIR}/${img}/integration" ]; then
        INTEGRATION_COUNT=$((INTEGRATION_COUNT + 1))
    fi
done

echo "With Integration Tests: $INTEGRATION_COUNT / $TESTED_COUNT"
echo ""

echo "Tested Images:"
for img in "${TESTED_IMAGES[@]}"; do
    if [ -d "${PHASE1_DIR}/${img}/integration" ]; then
        echo "  ✓ $img (with integration)"
    else
        echo "  ⊘ $img (basic only)"
    fi
done

echo ""
echo "=========================================="
echo "Batch Recommendations"
echo "=========================================="
echo ""

# Get all available images from containers repo
CONTAINERS_DIR="/workspace/artifacts/containers/images"
ALL_IMAGES=()

if [ -d "$CONTAINERS_DIR" ]; then
    for dir in "$CONTAINERS_DIR"/*/; do
        IMAGE_NAME=$(basename "$dir")
        ALL_IMAGES+=("$IMAGE_NAME")
    done

    # Find untested images
    UNTESTED=()
    for img in "${ALL_IMAGES[@]}"; do
        if [[ ! " ${TESTED_IMAGES[@]} " =~ " ${img} " ]]; then
            UNTESTED+=("$img")
        fi
    done

    echo "Untested Images (${#UNTESTED[@]}):"
    for img in "${UNTESTED[@]}"; do
        echo "  - $img"
    done | head -20

    if [ ${#UNTESTED[@]} -gt 20 ]; then
        echo "  ... and $((${#UNTESTED[@]} - 20)) more"
    fi

    echo ""
    echo "Suggested Next Batch (Utilities):"
    echo "  1. git (version control - very popular)"
    echo "  2. httpd (Apache web server)"
    echo "  3. postgresql (database - widely used)"
    echo "  4. valkey (Redis alternative)"
    echo "  5. memcached (caching)"
    echo ""
    echo "Alternative Batches:"
    echo ""
    echo "More Languages:"
    echo "  - python-3-12, nodejs-20, go-1-26, ruby-3-4, rust"
    echo ""
    echo ".NET Stack:"
    echo "  - dotnet-sdk-10-0, dotnet-runtime-10-0, aspnet-runtime-10-0"
    echo "  - dotnet-sdk-9-0, dotnet-runtime-9-0"
    echo ""
    echo "Databases & Servers:"
    echo "  - mariadb-11-8, tomcat-11, php, openjdk-21, caddy"
else
    echo "Note: Cannot suggest batches - containers repo not found at:"
    echo "  $CONTAINERS_DIR"
fi

echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "To start Batch $(((TESTED_COUNT / 5) + 1)):"
echo ""
echo "1. Select 5 images from recommendations above"
echo ""
echo "2. Generate templates:"
echo "   ./scripts/generate-test-template.sh <image-name> <category>"
echo ""
echo "3. Check correct image names:"
echo "   ./scripts/check-image-name.sh <image-name>"
echo ""
echo "4. Customize tests for each image"
echo ""
echo "5. Validate batch:"
echo "   ./scripts/validate-batch.sh img1 img2 img3 img4 img5"
echo ""
echo "6. Create integration tests"
echo ""
echo "7. Commit batch:"
echo "   git add phase1-tests/"
echo "   git commit -m 'Add Batch N: img1, img2, img3, img4, img5'"
echo "   git push"
