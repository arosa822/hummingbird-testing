#!/bin/bash
# Phase 1 Test Script for Hummingbird curl image
# Tests basic curl functionality

set -euo pipefail

IMAGE="quay.io/hummingbird/curl:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: curl Image Tests"
echo "=================================="
echo ""

# Test 1: Basic HTTP GET request
echo "[TEST 1] Basic HTTP GET to example.com"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -s -o /dev/null -w '%{http_code}' https://example.com"
HTTP_CODE=$(${TEST_ENGINE} run --rm ${IMAGE} -s -o /dev/null -w '%{http_code}' https://example.com)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ PASSED - Got HTTP 200 response"
else
    echo "✗ FAILED - Expected 200, got ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test 2: Verify curl version is available
echo "[TEST 2] Verify curl version command works"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --version | head -n1)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"curl"* ]]; then
    echo "✓ PASSED - curl version detected"
else
    echo "✗ FAILED - Could not detect curl version"
    exit 1
fi
echo ""

# Test 3: HTTPS support
echo "[TEST 3] Verify HTTPS/TLS support"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -s -o /dev/null -w '%{http_code}' https://www.google.com"
HTTPS_CODE=$(${TEST_ENGINE} run --rm ${IMAGE} -s -o /dev/null -w '%{http_code}' https://www.google.com)
if [ "$HTTPS_CODE" = "200" ] || [ "$HTTPS_CODE" = "301" ] || [ "$HTTPS_CODE" = "302" ]; then
    echo "✓ PASSED - HTTPS connection successful (HTTP ${HTTPS_CODE})"
else
    echo "✗ FAILED - HTTPS connection failed with code ${HTTPS_CODE}"
    exit 1
fi
echo ""

# Test 4: JSON API response (using httpbin.org)
echo "[TEST 4] Fetch JSON from API endpoint"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -s https://httpbin.org/json"
JSON_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -s https://httpbin.org/json)
if [[ "$JSON_OUTPUT" == *"slideshow"* ]]; then
    echo "✓ PASSED - Successfully fetched JSON response"
else
    echo "✗ FAILED - Did not receive expected JSON content"
    exit 1
fi
echo ""

echo "=================================="
echo "All curl tests PASSED!"
echo "=================================="
