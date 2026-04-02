#!/bin/bash
# Integration test for Hummingbird curl image
# Tests the image as a drop-in replacement in a real service stack
#
# Approach: The Hummingbird curl image is used UNTOUCHED — no custom
# Dockerfile, no modifications. We spin up a target service and use
# the curl image to interact with it, just like you would in a real
# automation pipeline or sidecar pattern.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

TEST_ENGINE="${TEST_ENGINE:-podman}"
COMPOSE_CMD="${TEST_ENGINE}-compose"

echo "=========================================="
echo "curl Integration Test (compose-based)"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Tearing down services..."
    ${COMPOSE_CMD} down --volumes --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Compose stack comes up and curl can reach the target service
echo "[TEST 1] Start compose stack and verify curl can reach target"
echo "Command: ${COMPOSE_CMD} up --abort-on-container-exit"

OUTPUT=$(${COMPOSE_CMD} up --abort-on-container-exit 2>&1)

if echo "$OUTPUT" | grep -q "200"; then
    echo "✓ PASSED - Hummingbird curl successfully reached target service (HTTP 200)"
else
    echo "✗ FAILED - curl could not reach target service"
    echo "Output: $OUTPUT"
    exit 1
fi
echo ""

# Test 2: Verify curl version works
echo "[TEST 2] Verify curl --version works"
echo "Command: ${COMPOSE_CMD} run --rm curl --version"

VERSION_OUTPUT=$(${COMPOSE_CMD} run --rm curl --version 2>&1)

if echo "$VERSION_OUTPUT" | grep -q "curl"; then
    echo "✓ PASSED - curl version detected"
    echo "Version: $(echo "$VERSION_OUTPUT" | head -n1)"
else
    echo "✗ FAILED - Could not detect curl version"
    echo "Output: $VERSION_OUTPUT"
    exit 1
fi
echo ""

# Test 3: HTTPS support (fetch from external endpoint)
echo "[TEST 3] Verify HTTPS/TLS support"
echo "Command: ${COMPOSE_CMD} run --rm curl -k -s -o /dev/null -w '%{http_code}' https://example.com"

HTTPS_CODE=$(${COMPOSE_CMD} run --rm curl -k -s -o /dev/null -w '%{http_code}' https://example.com 2>&1 | tail -1)

if [ "$HTTPS_CODE" = "200" ] || [ "$HTTPS_CODE" = "301" ] || [ "$HTTPS_CODE" = "302" ]; then
    echo "✓ PASSED - HTTPS connection successful (HTTP ${HTTPS_CODE})"
else
    echo "✗ FAILED - HTTPS connection failed: ${HTTPS_CODE}"
    exit 1
fi
echo ""

# Test 4: Fetch JSON from API (proves curl works for real API automation)
echo "[TEST 4] Fetch JSON from API endpoint"
echo "Command: ${COMPOSE_CMD} run --rm curl -k -s https://httpbin.org/json"

JSON_OUTPUT=$(${COMPOSE_CMD} run --rm curl -k -s https://httpbin.org/json 2>&1)

if echo "$JSON_OUTPUT" | grep -q "slideshow"; then
    echo "✓ PASSED - Successfully fetched JSON response"
else
    echo "✗ FAILED - Did not receive expected JSON content"
    echo "Output: $JSON_OUTPUT"
    exit 1
fi
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Hummingbird curl used as drop-in replacement (untouched image)"
echo "  ✓ Successfully reached services within compose network"
echo "  ✓ HTTPS/TLS support works"
echo "  ✓ JSON API fetching works"
echo ""
echo "This validates that Hummingbird curl can replace"
echo "mainstream curl images in automation and service stacks."
