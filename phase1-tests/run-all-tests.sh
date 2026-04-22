#!/bin/bash
# Run all Phase 1 tests for Hummingbird images

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGES=("curl" "jq" "nginx" "python-3-13" "nodejs-22" "git" "httpd" "caddy" "haproxy" "python-3-11" "python-3-12" "nodejs-20" "go-1-25" "postgresql" "valkey")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASSED=0
FAILED=0
FAILED_TESTS=()

echo "=========================================="
echo "Running Phase 1 Tests for All Images"
echo "Container Engine: ${TEST_ENGINE}"
echo "=========================================="
echo ""

for image in "${IMAGES[@]}"; do
    echo "=========================================="
    echo "Testing: $image"
    echo "=========================================="

    cd "${SCRIPT_DIR}/${image}"

    # Make script executable
    chmod +x test.sh

    # Run test
    if TEST_ENGINE="${TEST_ENGINE}" ./test.sh; then
        echo ""
        echo "✓ ${image} - ALL TESTS PASSED"
        PASSED=$((PASSED + 1))
    else
        echo ""
        echo "✗ ${image} - TESTS FAILED"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$image")
    fi

    echo ""
    cd "${SCRIPT_DIR}"
done

echo "=========================================="
echo "Phase 1 Test Summary"
echo "=========================================="
echo "Total Images: ${#IMAGES[@]}"
echo "Passed: ${PASSED}"
echo "Failed: ${FAILED}"

if [ ${FAILED} -gt 0 ]; then
    echo ""
    echo "Failed Tests:"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo "  - ${failed_test}"
    done
    echo ""
    echo "❌ Phase 1 tests FAILED"
    exit 1
else
    echo ""
    echo "✅ Phase 1 tests PASSED - All images verified!"
    exit 0
fi
