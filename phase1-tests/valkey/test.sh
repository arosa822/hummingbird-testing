#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/valkey:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-valkey-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))

echo "=================================="
echo "Phase 1: valkey Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Start Valkey container
echo "[TEST 1] Start Valkey container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:6379 ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:6379 ${IMAGE} > /dev/null
sleep 2
if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - Valkey container started successfully"
else
    echo "✗ FAILED - Valkey container did not start"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 || true
    exit 1
fi
echo ""

# Test 2: Verify Valkey is responding to PING
echo "[TEST 2] Verify Valkey responds to PING"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli PING"
MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    PING_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli PING 2>&1)
    if [ "$PING_OUTPUT" = "PONG" ]; then
        echo "✓ PASSED - Valkey responded: $PING_OUTPUT"
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Valkey did not respond to PING"
    exit 1
fi
echo ""

# Test 3: Set and get a key
echo "[TEST 3] Set and retrieve a key-value pair"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli SET test_key 'hummingbird'"
${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli SET test_key 'hummingbird' > /dev/null
GET_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli GET test_key)
if [ "$GET_OUTPUT" = "hummingbird" ]; then
    echo "✓ PASSED - Key-value operations work: $GET_OUTPUT"
else
    echo "✗ FAILED - Expected 'hummingbird', got $GET_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Check server info
echo "[TEST 4] Verify Valkey server info"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli INFO server"
INFO_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} valkey-cli INFO server 2>&1)
if echo "$INFO_OUTPUT" | grep -q "valkey_version"; then
    VERSION=$(echo "$INFO_OUTPUT" | grep "valkey_version" | head -1)
    echo "✓ PASSED - Valkey server info accessible: $VERSION"
else
    echo "✗ FAILED - Could not retrieve Valkey server info"
    exit 1
fi
echo ""

echo "=================================="
echo "All valkey tests PASSED!"
echo "=================================="
