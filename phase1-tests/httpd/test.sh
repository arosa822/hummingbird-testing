#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/httpd:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-httpd-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))

echo "=================================="
echo "Phase 1: httpd Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Start httpd container
echo "[TEST 1] Start httpd container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:8080 ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:8080 ${IMAGE} > /dev/null
sleep 2
if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - httpd container started successfully"
else
    echo "✗ FAILED - httpd container did not start"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 || true
    exit 1
fi
echo ""

# Test 2: Verify httpd is serving content
echo "[TEST 2] Verify httpd is serving content"
echo "Command: curl -s http://127.0.0.1:${HOST_PORT}/"
MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if HTTP_RESPONSE=$(curl -s http://127.0.0.1:${HOST_PORT}/ 2>/dev/null); then
        if [[ "$HTTP_RESPONSE" == *"It works"* ]] || [[ "$HTTP_RESPONSE" == *"html"* ]]; then
            echo "✓ PASSED - httpd is serving content"
            break
        fi
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Could not reach httpd after $MAX_RETRIES attempts"
    exit 1
fi
echo ""

# Test 3: Check HTTP status code
echo "[TEST 3] Verify HTTP 200 status code"
echo "Command: curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${HOST_PORT}/"
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${HOST_PORT}/)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ PASSED - Got HTTP 200 response"
else
    echo "✗ FAILED - Expected 200, got ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test 4: Verify no critical errors in logs
echo "[TEST 4] Verify no critical errors in httpd logs"
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
echo "All httpd tests PASSED!"
echo "=================================="
