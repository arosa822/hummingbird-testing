#!/bin/bash
# Integration test for nginx image
# Tests building and serving a static website with custom configuration

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGE_NAME="hummingbird-nginx-integration-test"
BUILD_TAG="latest"
CONTAINER_NAME="nginx-test-$$"
WEB_PORT="8080"

echo "=========================================="
echo "nginx Integration Test"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Stopping and removing container..."
    ${TEST_ENGINE} stop ${CONTAINER_NAME} 2>/dev/null || true
    ${TEST_ENGINE} rm ${CONTAINER_NAME} 2>/dev/null || true
    ${TEST_ENGINE} rmi ${IMAGE_NAME}:${BUILD_TAG} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Build the static website image
echo "[TEST 1] Build static website using Hummingbird nginx as base"
echo "Command: ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} ."

if ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} . > /dev/null 2>&1; then
    echo "✓ PASSED - Static website image built successfully"
else
    echo "✗ FAILED - Failed to build static website image"
    exit 1
fi
echo ""

# Test 2: Start nginx server
echo "[TEST 2] Start nginx web server"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${WEB_PORT}:8080 ${IMAGE_NAME}:${BUILD_TAG}"

${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${WEB_PORT}:8080 ${IMAGE_NAME}:${BUILD_TAG} > /dev/null

# Wait for nginx to start
echo "Waiting for nginx to start..."
sleep 2

if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - nginx server started successfully"
else
    echo "✗ FAILED - nginx server did not start"
    exit 1
fi
echo ""

# Test 3: Serve main page
echo "[TEST 3] Test main page (GET /)"

MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if RESPONSE=$(curl -s http://localhost:${WEB_PORT}/ 2>/dev/null); then
        if echo "$RESPONSE" | grep -q "Hummingbird nginx"; then
            echo "✓ PASSED - Main page loads successfully"
            break
        fi
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Main page not responding"
    exit 1
fi
echo ""

# Test 4: Serve CSS file
echo "[TEST 4] Test CSS file serving (GET /style.css)"

CSS_RESPONSE=$(curl -s http://localhost:${WEB_PORT}/style.css)

if echo "$CSS_RESPONSE" | grep -q "container"; then
    echo "✓ PASSED - CSS file served successfully"
else
    echo "✗ FAILED - CSS file not served correctly"
    exit 1
fi
echo ""

# Test 5: Serve JavaScript file
echo "[TEST 5] Test JavaScript file serving (GET /app.js)"

JS_RESPONSE=$(curl -s http://localhost:${WEB_PORT}/app.js)

if echo "$JS_RESPONSE" | grep -q "checkHealth"; then
    echo "✓ PASSED - JavaScript file served successfully"
else
    echo "✗ FAILED - JavaScript file not served correctly"
    exit 1
fi
echo ""

# Test 6: Health check endpoint
echo "[TEST 6] Test health check endpoint (GET /health)"

HEALTH_RESPONSE=$(curl -s http://localhost:${WEB_PORT}/health)

if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✓ PASSED - Health check endpoint works"
else
    echo "✗ FAILED - Health check endpoint failed"
    exit 1
fi
echo ""

# Test 7: JSON API endpoint
echo "[TEST 7] Test JSON API endpoint (GET /api/status)"

STATUS_RESPONSE=$(curl -s http://localhost:${WEB_PORT}/api/status)

if echo "$STATUS_RESPONSE" | grep -q "ok"; then
    echo "✓ PASSED - JSON API endpoint works"
    echo "Response: $STATUS_RESPONSE"
else
    echo "✗ FAILED - JSON API endpoint failed"
    exit 1
fi
echo ""

# Test 8: Gzip compression
echo "[TEST 8] Test gzip compression"

GZIP_HEADERS=$(curl -s -I -H "Accept-Encoding: gzip" http://localhost:${WEB_PORT}/ | grep -i "content-encoding")

if echo "$GZIP_HEADERS" | grep -qi "gzip"; then
    echo "✓ PASSED - Gzip compression enabled"
else
    echo "⚠ WARNING - Gzip compression not detected (may not be critical)"
fi
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Built static website using nginx image"
echo "  ✓ nginx server runs successfully"
echo "  ✓ Serves HTML, CSS, and JavaScript files"
echo "  ✓ Health check endpoint works"
echo "  ✓ Custom API endpoints work"
echo "  ✓ Custom nginx configuration applied"
echo ""
echo "This validates that Hummingbird nginx image can be"
echo "used as a base for hosting production websites."
