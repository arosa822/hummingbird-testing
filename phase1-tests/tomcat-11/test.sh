#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/tomcat:11"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-tomcat-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))

echo "=================================="
echo "Phase 1: tomcat-11 Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Start Tomcat container
echo "[TEST 1] Start Tomcat container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:8080 ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:8080 ${IMAGE} > /dev/null
sleep 5
if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - Tomcat container started successfully"
else
    echo "✗ FAILED - Tomcat container did not start"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 || true
    exit 1
fi
echo ""

# Test 2: Verify Tomcat is serving content
echo "[TEST 2] Verify Tomcat is serving content"
echo "Command: curl -s http://127.0.0.1:${HOST_PORT}/"
MAX_RETRIES=10
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${HOST_PORT}/ 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "404" ]; then
        echo "✓ PASSED - Tomcat is responding (HTTP ${HTTP_CODE})"
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 2
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Could not reach Tomcat after $MAX_RETRIES attempts"
    exit 1
fi
echo ""

# Test 3: Check Tomcat version from logs
echo "[TEST 3] Verify Tomcat version in logs"
echo "Command: ${TEST_ENGINE} logs ${CONTAINER_NAME}"
LOGS=$(${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1)
if echo "$LOGS" | grep -qi "Tomcat\|catalina\|VersionLoggerListener"; then
    TOMCAT_VER=$(echo "$LOGS" | grep -i "Server version name" | head -1 || true)
    echo "✓ PASSED - Tomcat detected: ${TOMCAT_VER:-found in logs}"
else
    echo "✗ FAILED - Could not verify Tomcat in logs"
    echo "Logs:"
    echo "$LOGS" | head -10
    exit 1
fi
echo ""

# Test 4: Verify no critical errors in logs
echo "[TEST 4] Verify no critical errors in Tomcat logs"
if echo "$LOGS" | grep -qi "SEVERE.*fatal\|SEVERE.*crash\|Error.*startup"; then
    echo "✗ FAILED - Found critical errors in logs:"
    echo "$LOGS" | grep -i "SEVERE\|Error.*startup" | head -5
    exit 1
else
    echo "✓ PASSED - No critical errors in logs"
fi
echo ""

echo "=================================="
echo "All tomcat-11 tests PASSED!"
echo "=================================="
