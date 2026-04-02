#!/bin/bash
# Validate a batch of images
# Usage: ./validate-batch.sh image1 image2 image3 image4 image5

set -euo pipefail

PHASE1_DIR="/workspace/artifacts/hummingbird-testing/phase1-tests"
TEST_ENGINE="${TEST_ENGINE:-podman}"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <image1> [image2] [image3] [image4] [image5]"
    echo ""
    echo "Example: $0 git httpd memcached postgresql valkey"
    exit 1
fi

IMAGES=("$@")
TOTAL=${#IMAGES[@]}

echo "=========================================="
echo "Batch Validation"
echo "=========================================="
echo "Images: ${IMAGES[*]}"
echo "Total: $TOTAL"
echo "Engine: $TEST_ENGINE"
echo ""

BASIC_PASSED=0
BASIC_FAILED=0
BASIC_FAILED_IMAGES=()

INTEGRATION_PASSED=0
INTEGRATION_FAILED=0
INTEGRATION_FAILED_IMAGES=()

echo "=========================================="
echo "Phase 1: Basic Tests"
echo "=========================================="
echo ""

for image in "${IMAGES[@]}"; do
    echo "Testing: $image"
    echo "----------------------------------------"

    TEST_DIR="${PHASE1_DIR}/${image}"

    if [ ! -d "$TEST_DIR" ]; then
        echo "❌ ERROR: Test directory not found: $TEST_DIR"
        BASIC_FAILED=$((BASIC_FAILED + 1))
        BASIC_FAILED_IMAGES+=("$image (missing)")
        echo ""
        continue
    fi

    if [ ! -f "${TEST_DIR}/test.sh" ]; then
        echo "❌ ERROR: test.sh not found in $TEST_DIR"
        BASIC_FAILED=$((BASIC_FAILED + 1))
        BASIC_FAILED_IMAGES+=("$image (no test.sh)")
        echo ""
        continue
    fi

    cd "$TEST_DIR"
    chmod +x test.sh

    if TEST_ENGINE="$TEST_ENGINE" ./test.sh > /tmp/${image}-basic-test.log 2>&1; then
        echo "✓ PASSED"
        BASIC_PASSED=$((BASIC_PASSED + 1))
    else
        echo "✗ FAILED"
        BASIC_FAILED=$((BASIC_FAILED + 1))
        BASIC_FAILED_IMAGES+=("$image")
        echo "  Log: /tmp/${image}-basic-test.log"
        echo "  Last 10 lines:"
        tail -10 "/tmp/${image}-basic-test.log" | sed 's/^/    /'
    fi

    echo ""
done

echo "=========================================="
echo "Phase 2: Integration Tests"
echo "=========================================="
echo ""

for image in "${IMAGES[@]}"; do
    echo "Testing: $image (integration)"
    echo "----------------------------------------"

    INTEGRATION_DIR="${PHASE1_DIR}/${image}/integration"

    if [ ! -d "$INTEGRATION_DIR" ]; then
        echo "⚠️  No integration tests (ok)"
        echo ""
        continue
    fi

    if [ ! -f "${INTEGRATION_DIR}/test-integration.sh" ]; then
        echo "⚠️  integration/ exists but no test-integration.sh"
        echo ""
        continue
    fi

    cd "$INTEGRATION_DIR"
    chmod +x test-integration.sh

    if TEST_ENGINE="$TEST_ENGINE" ./test-integration.sh > /tmp/${image}-integration-test.log 2>&1; then
        echo "✓ PASSED"
        INTEGRATION_PASSED=$((INTEGRATION_PASSED + 1))
    else
        echo "✗ FAILED"
        INTEGRATION_FAILED=$((INTEGRATION_FAILED + 1))
        INTEGRATION_FAILED_IMAGES+=("$image")
        echo "  Log: /tmp/${image}-integration-test.log"
        echo "  Last 10 lines:"
        tail -10 "/tmp/${image}-integration-test.log" | sed 's/^/    /'
    fi

    echo ""
done

echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo ""
echo "Basic Tests:"
echo "  Total: $TOTAL"
echo "  Passed: $BASIC_PASSED"
echo "  Failed: $BASIC_FAILED"

if [ $BASIC_FAILED -gt 0 ]; then
    echo "  Failed Images:"
    for img in "${BASIC_FAILED_IMAGES[@]}"; do
        echo "    - $img"
    done
fi

echo ""
echo "Integration Tests:"
echo "  Passed: $INTEGRATION_PASSED"
echo "  Failed: $INTEGRATION_FAILED"

if [ $INTEGRATION_FAILED -gt 0 ]; then
    echo "  Failed Images:"
    for img in "${INTEGRATION_FAILED_IMAGES[@]}"; do
        echo "    - $img"
    done
fi

echo ""

# Failure Analysis
if [ $BASIC_FAILED -gt 0 ] || [ $INTEGRATION_FAILED -gt 0 ]; then
    echo "=========================================="
    echo "Failure Analysis"
    echo "=========================================="
    echo ""
    echo "Check logs in /tmp/<image>-*-test.log for details"
    echo ""
    echo "Common Issues:"
    echo "  - Wrong image name → Check properties.yml"
    echo "  - SSL certificate → Add -k flag or use HTTP"
    echo "  - Missing entrypoint → Add explicit command"
    echo "  - Permission denied → Check user 0 vs 1001"
    echo "  - Connection refused → Add sleep/retry logic"
    echo ""
    echo "Decision Matrix:"
    echo "  1. Is it a test infrastructure issue? → Fix the test"
    echo "  2. Is it an image issue? → Document and report"
    echo "  3. Unclear? → Investigate further"
    echo ""
    exit 1
else
    echo "✅ All tests PASSED!"
    echo ""
    echo "Batch is ready to commit."
    exit 0
fi
