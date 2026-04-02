#!/bin/bash
# Run all Phase 1 integration tests
# Tests building real applications using Hummingbird images

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGES=("curl" "jq" "nginx" "python-3-13" "nodejs-22")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASSED=0
FAILED=0
FAILED_TESTS=()

echo "=========================================="
echo "Running All Phase 1 Integration Tests"
echo "Container Engine: ${TEST_ENGINE}"
echo "=========================================="
echo ""

for image in "${IMAGES[@]}"; do
    echo "=========================================="
    echo "Testing: $image (Integration)"
    echo "=========================================="

    integration_dir="${SCRIPT_DIR}/${image}/integration"

    if [ ! -d "$integration_dir" ]; then
        echo "⊘ SKIPPED - No integration tests for $image"
        echo ""
        continue
    fi

    cd "$integration_dir"

    # Make script executable
    chmod +x test-integration.sh 2>/dev/null || true

    # Run test
    if TEST_ENGINE="${TEST_ENGINE}" ./test-integration.sh; then
        echo ""
        echo "✓ ${image} integration - ALL TESTS PASSED"
        PASSED=$((PASSED + 1))
    else
        echo ""
        echo "✗ ${image} integration - TESTS FAILED"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$image")
    fi

    echo ""
    cd "${SCRIPT_DIR}"
done

echo "=========================================="
echo "Integration Test Summary"
echo "=========================================="
echo "Total Images: ${#IMAGES[@]}"
echo "Passed: ${PASSED}"
echo "Failed: ${FAILED}"

if [ ${FAILED} -gt 0 ]; then
    echo ""
    echo "Failed Integration Tests:"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo "  - ${failed_test}"
    done
    echo ""
    echo "❌ Integration tests FAILED"
    exit 1
else
    echo ""
    echo "✅ All integration tests PASSED!"
    echo ""
    echo "What this validates:"
    echo "  • Hummingbird images work as base images"
    echo "  • Real applications can be built on them"
    echo "  • Dependencies (pip, npm) install correctly"
    echo "  • Applications run successfully in containers"
    echo "  • Images are production-ready"
    exit 0
fi
