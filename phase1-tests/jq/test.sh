#!/bin/bash
# Phase 1 Test Script for Hummingbird jq image
# Tests basic JSON processing functionality

set -euo pipefail

IMAGE="quay.io/hummingbird/jq:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: jq Image Tests"
echo "=================================="
echo ""

# Test 1: Extract simple field from JSON
echo "[TEST 1] Extract field from JSON object"
echo "Command: echo '{\"name\":\"test\"}' | ${TEST_ENGINE} run --rm -i ${IMAGE} '.name'"
OUTPUT=$(echo '{"name":"test"}' | ${TEST_ENGINE} run --rm -i ${IMAGE} '.name')
EXPECTED='"test"'
if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASSED - Extracted field correctly: $OUTPUT"
else
    echo "✗ FAILED - Expected $EXPECTED, got $OUTPUT"
    exit 1
fi
echo ""

# Test 2: Verify jq version
echo "[TEST 2] Verify jq version command works"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} jq --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} jq --version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"jq-"* ]]; then
    echo "✓ PASSED - jq version detected"
else
    echo "✗ FAILED - Could not detect jq version"
    exit 1
fi
echo ""

# Test 3: Array processing
echo "[TEST 3] Process JSON array"
echo "Command: echo '[1,2,3]' | ${TEST_ENGINE} run --rm -i ${IMAGE} '.[1]'"
ARRAY_OUTPUT=$(echo '[1,2,3]' | ${TEST_ENGINE} run --rm -i ${IMAGE} '.[1]')
if [ "$ARRAY_OUTPUT" = "2" ]; then
    echo "✓ PASSED - Array index access works: $ARRAY_OUTPUT"
else
    echo "✗ FAILED - Expected 2, got $ARRAY_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Complex filtering
echo "[TEST 4] Filter nested JSON structure"
TEST_JSON='{"users":[{"name":"alice","age":30},{"name":"bob","age":25}]}'
echo "Command: echo '${TEST_JSON}' | ${TEST_ENGINE} run --rm -i ${IMAGE} '.users[0].name'"
FILTER_OUTPUT=$(echo "${TEST_JSON}" | ${TEST_ENGINE} run --rm -i ${IMAGE} '.users[0].name')
if [ "$FILTER_OUTPUT" = '"alice"' ]; then
    echo "✓ PASSED - Nested JSON filtering works: $FILTER_OUTPUT"
else
    echo "✗ FAILED - Expected \"alice\", got $FILTER_OUTPUT"
    exit 1
fi
echo ""

echo "=================================="
echo "All jq tests PASSED!"
echo "=================================="
