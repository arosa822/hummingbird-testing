#!/bin/bash
# Integration test for curl image
# Tests building and running a real application using curl as base

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGE_NAME="hummingbird-curl-integration-test"
BUILD_TAG="latest"

echo "=========================================="
echo "curl Integration Test"
echo "=========================================="
echo ""

# Test 1: Build the application image
echo "[TEST 1] Build application using Hummingbird curl as base"
echo "Command: ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} ."

if ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} .; then
    echo "✓ PASSED - Application image built successfully"
else
    echo "✗ FAILED - Failed to build application image"
    exit 1
fi
echo ""

# Test 2: Run the application (default location)
echo "[TEST 2] Run application with default parameters"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE_NAME}:${BUILD_TAG}"

OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE_NAME}:${BUILD_TAG} 2>&1)

if echo "$OUTPUT" | grep -q "Application completed successfully"; then
    echo "✓ PASSED - Application ran successfully"
    echo "Sample output:"
    echo "$OUTPUT" | grep -A 2 "Current Weather:"
else
    echo "✗ FAILED - Application did not complete successfully"
    echo "Output: $OUTPUT"
    exit 1
fi
echo ""

# Test 3: Run application with custom parameter
echo "[TEST 3] Run application with custom location"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE_NAME}:${BUILD_TAG} London"

LONDON_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE_NAME}:${BUILD_TAG} London 2>&1)

if echo "$LONDON_OUTPUT" | grep -q "Fetching weather for: London"; then
    echo "✓ PASSED - Application accepts custom parameters"
else
    echo "✗ FAILED - Application did not accept custom parameters"
    echo "Output: $LONDON_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Verify application fetches multiple data sources
echo "[TEST 4] Verify application fetches from multiple APIs"

if echo "$OUTPUT" | grep -q "IP Data:"; then
    echo "✓ PASSED - Application successfully fetches from multiple sources"
else
    echo "✗ FAILED - Application did not fetch from all expected sources"
    exit 1
fi
echo ""

# Cleanup
echo "[CLEANUP] Removing test image"
${TEST_ENGINE} rmi ${IMAGE_NAME}:${BUILD_TAG} > /dev/null 2>&1 || true
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Built real application using curl image"
echo "  ✓ Application runs successfully"
echo "  ✓ Accepts custom parameters"
echo "  ✓ Fetches data from multiple APIs"
echo ""
echo "This validates that Hummingbird curl image can be"
echo "used as a base for building production applications."
