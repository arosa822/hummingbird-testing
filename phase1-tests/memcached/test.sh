#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/memcached:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-memcached-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))

echo "=================================="
echo "Phase 1: memcached Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Verify memcached version
echo "[TEST 1] Verify memcached version"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} memcached -V"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} memcached -V 2>&1)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"memcached"* ]]; then
    echo "✓ PASSED - memcached version detected"
else
    echo "✗ FAILED - Could not detect memcached version"
    exit 1
fi
echo ""

# Test 2: Start memcached container
echo "[TEST 2] Start memcached container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:11211 ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:11211 ${IMAGE} > /dev/null
sleep 2
if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - memcached container started successfully"
else
    echo "✗ FAILED - memcached container did not start"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 || true
    exit 1
fi
echo ""

# Test 3: Store and retrieve a value
echo "[TEST 3] Store and retrieve a value"
echo "Command: printf 'set testkey 0 60 11\\r\\nhummingbird\\r\\n' | nc 127.0.0.1 ${HOST_PORT}"
MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    SET_RESULT=$(printf 'set testkey 0 60 11\r\nhummingbird\r\n' | nc -w 2 127.0.0.1 ${HOST_PORT} 2>/dev/null || true)
    if [[ "$SET_RESULT" == *"STORED"* ]]; then
        GET_RESULT=$(printf 'get testkey\r\n' | nc -w 2 127.0.0.1 ${HOST_PORT} 2>/dev/null || true)
        if [[ "$GET_RESULT" == *"hummingbird"* ]]; then
            echo "✓ PASSED - Key-value operations work"
            break
        fi
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Could not store/retrieve value"
    exit 1
fi
echo ""

# Test 4: Check stats command
echo "[TEST 4] Verify memcached stats"
echo "Command: printf 'stats\\r\\n' | nc 127.0.0.1 ${HOST_PORT}"
STATS_OUTPUT=$(printf 'stats\r\nquit\r\n' | nc -w 2 127.0.0.1 ${HOST_PORT} 2>/dev/null || true)
if [[ "$STATS_OUTPUT" == *"STAT pid"* ]]; then
    echo "✓ PASSED - Stats command works"
else
    echo "✗ FAILED - Stats command did not return expected output"
    exit 1
fi
echo ""

echo "=================================="
echo "All memcached tests PASSED!"
echo "=================================="
