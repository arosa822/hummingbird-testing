#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/haproxy:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-haproxy-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))
STATS_PORT=$(( HOST_PORT + 1 ))
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=================================="
echo "Phase 1: haproxy Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Verify haproxy version
echo "[TEST 1] Verify haproxy version"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} haproxy -v"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} haproxy -v 2>&1 | head -1)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"HAProxy"* ]]; then
    echo "✓ PASSED - HAProxy version detected"
else
    echo "✗ FAILED - Could not detect HAProxy version"
    exit 1
fi
echo ""

# Test 2: Validate configuration file
echo "[TEST 2] Validate haproxy configuration"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z --entrypoint '' ${IMAGE} haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg"
if ${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z" --entrypoint '' ${IMAGE} haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg 2>&1; then
    echo "✓ PASSED - Configuration is valid"
else
    echo "✗ FAILED - Configuration validation failed"
    exit 1
fi
echo ""

# Test 3: Start haproxy with test config
echo "[TEST 3] Start haproxy container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:8080 -p ${STATS_PORT}:8404 -v ${SCRIPT_DIR}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:8080 \
    -p ${STATS_PORT}:8404 \
    -v "${SCRIPT_DIR}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z" \
    ${IMAGE} > /dev/null
sleep 2
if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - haproxy container started successfully"
else
    echo "✗ FAILED - haproxy container did not start"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 || true
    exit 1
fi
echo ""

# Test 4: Check stats endpoint responds
echo "[TEST 4] Verify haproxy stats endpoint"
echo "Command: curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${STATS_PORT}/stats"
MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${STATS_PORT}/stats 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ PASSED - Stats endpoint returned HTTP 200"
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Stats endpoint did not return HTTP 200 (got ${HTTP_CODE})"
    exit 1
fi
echo ""

echo "=================================="
echo "All haproxy tests PASSED!"
echo "=================================="
