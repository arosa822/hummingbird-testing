#!/bin/bash
# Phase 1 Test Script for Hummingbird nginx image
# Tests basic web server functionality

set -euo pipefail

IMAGE="quay.io/hummingbird/nginx:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-nginx-test-$$"

echo "=================================="
echo "Phase 1: nginx Image Tests"
echo "=================================="
echo ""

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Start nginx container
echo "[TEST 1] Start nginx container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE} > /dev/null
sleep 2  # Give nginx time to start
if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - nginx container started successfully"
else
    echo "✗ FAILED - nginx container did not start"
    exit 1
fi
echo ""

# Test 2: Check nginx is listening
echo "[TEST 2] Verify nginx is serving content"
echo "Command: curl -s http://localhost:8080/"
MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if HTTP_RESPONSE=$(curl -s http://localhost:8080/ 2>/dev/null); then
        if [[ "$HTTP_RESPONSE" == *"nginx"* ]] || [[ "$HTTP_RESPONSE" == *"Welcome"* ]]; then
            echo "✓ PASSED - nginx is serving content"
            echo "Response snippet: ${HTTP_RESPONSE:0:100}..."
            break
        fi
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Could not reach nginx after $MAX_RETRIES attempts"
    exit 1
fi
echo ""

# Test 3: Check HTTP status code
echo "[TEST 3] Verify HTTP 200 status code"
echo "Command: curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/"
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ PASSED - Got HTTP 200 response"
else
    echo "✗ FAILED - Expected 200, got ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test 4: Check container logs for errors
echo "[TEST 4] Verify no critical errors in nginx logs"
echo "Command: ${TEST_ENGINE} logs ${CONTAINER_NAME}"
LOGS=$(${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1)
if echo "$LOGS" | grep -qi "error\|failed\|critical"; then
    echo "⚠ WARNING - Found error messages in logs:"
    echo "$LOGS" | grep -i "error\|failed\|critical" | head -5
else
    echo "✓ PASSED - No critical errors in logs"
fi
echo ""

echo "=================================="
echo "All nginx tests PASSED!"
echo "=================================="
