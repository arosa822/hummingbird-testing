#!/bin/bash
# Integration test for Hummingbird nginx image
# Tests the image as a drop-in replacement for a production web server
#
# Approach: The Hummingbird nginx image is used UNTOUCHED — no custom
# Dockerfile, no modifications. Configuration and static files are
# volume-mounted, just like you would deploy nginx in production
# with Kubernetes ConfigMaps or Docker Compose volumes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

TEST_ENGINE="${TEST_ENGINE:-podman}"
COMPOSE_CMD="${TEST_ENGINE}-compose"

echo "=========================================="
echo "nginx Integration Test (compose-based)"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Tearing down services..."
    ${COMPOSE_CMD} down --volumes --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

# Start nginx in the background
echo "[SETUP] Starting Hummingbird nginx service..."
${COMPOSE_CMD} up -d 2>&1

# Wait for nginx to be ready
echo "Waiting for nginx to start..."
MAX_RETRIES=10
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -sf http://localhost:8080/ > /dev/null 2>&1; then
        echo "nginx is ready."
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - nginx did not start within ${MAX_RETRIES} seconds"
    ${COMPOSE_CMD} logs web 2>&1
    exit 1
fi
echo ""

# Test 1: Main page loads
echo "[TEST 1] Test main page (GET /)"

RESPONSE=$(curl -s http://localhost:8080/)

if echo "$RESPONSE" | grep -q "Hummingbird nginx"; then
    echo "✓ PASSED - Main page loads successfully"
else
    echo "✗ FAILED - Main page not serving expected content"
    echo "Response: ${RESPONSE:0:200}"
    exit 1
fi
echo ""

# Test 2: HTTP status code
echo "[TEST 2] Verify HTTP 200 status code"

HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ PASSED - Got HTTP 200 response"
else
    echo "✗ FAILED - Expected 200, got ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test 3: CSS file serving
echo "[TEST 3] Test CSS file serving (GET /style.css)"

CSS_RESPONSE=$(curl -s http://localhost:8080/style.css)

if echo "$CSS_RESPONSE" | grep -q "container"; then
    echo "✓ PASSED - CSS file served successfully"
else
    echo "✗ FAILED - CSS file not served correctly"
    exit 1
fi
echo ""

# Test 4: JavaScript file serving
echo "[TEST 4] Test JavaScript file serving (GET /app.js)"

JS_RESPONSE=$(curl -s http://localhost:8080/app.js)

if echo "$JS_RESPONSE" | grep -q "checkHealth"; then
    echo "✓ PASSED - JavaScript file served successfully"
else
    echo "✗ FAILED - JavaScript file not served correctly"
    exit 1
fi
echo ""

# Test 5: Health check endpoint
echo "[TEST 5] Test health check endpoint (GET /health)"

HEALTH_RESPONSE=$(curl -s http://localhost:8080/health)

if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✓ PASSED - Health check endpoint works"
else
    echo "✗ FAILED - Health check endpoint failed"
    exit 1
fi
echo ""

# Test 6: JSON API endpoint
echo "[TEST 6] Test JSON API endpoint (GET /api/status)"

STATUS_RESPONSE=$(curl -s http://localhost:8080/api/status)

if echo "$STATUS_RESPONSE" | grep -q "ok"; then
    echo "✓ PASSED - JSON API endpoint works"
    echo "Response: $STATUS_RESPONSE"
else
    echo "✗ FAILED - JSON API endpoint failed"
    exit 1
fi
echo ""

# Test 7: Gzip compression
echo "[TEST 7] Test gzip compression"

GZIP_HEADERS=$(curl -s -I -H "Accept-Encoding: gzip" http://localhost:8080/ | grep -i "content-encoding" || true)

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
echo "  ✓ Hummingbird nginx used as drop-in replacement (untouched image)"
echo "  ✓ Custom config applied via volume mount"
echo "  ✓ Serves HTML, CSS, and JavaScript files"
echo "  ✓ Health check endpoint works"
echo "  ✓ Custom API endpoints work"
echo ""
echo "This validates that Hummingbird nginx can replace"
echo "mainstream nginx images for hosting production websites."
