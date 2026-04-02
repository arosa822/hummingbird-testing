#!/bin/bash
# Integration test for Hummingbird Node.js image
# Tests the image as a drop-in replacement for a production Node.js runtime
#
# Approach: The Hummingbird Node.js image is used UNTOUCHED — no custom
# Dockerfile, no modifications. A builder init service installs npm
# dependencies into a shared volume, then the Hummingbird image runs
# the Express app with those deps mounted. This mirrors how you'd deploy
# Node.js apps in production with pre-built dependency layers.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

TEST_ENGINE="${TEST_ENGINE:-podman}"
COMPOSE_CMD="${TEST_ENGINE}-compose"

echo "=========================================="
echo "Node.js Integration Test (compose-based)"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Tearing down services..."
    ${COMPOSE_CMD} down --volumes --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

# Start services (deps builder runs first, then app)
echo "[SETUP] Installing dependencies and starting Express app..."
${COMPOSE_CMD} up -d 2>&1

# Wait for Express to be ready
echo "Waiting for Express app to start..."
MAX_RETRIES=15
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -sf http://localhost:8080/ > /dev/null 2>&1; then
        echo "Express app is ready."
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Express app did not start within ${MAX_RETRIES} seconds"
    ${COMPOSE_CMD} logs app 2>&1
    exit 1
fi
echo ""

# Test 1: Health check endpoint
echo "[TEST 1] Test health check endpoint (GET /)"

HEALTH_RESPONSE=$(curl -s http://localhost:8080/)

if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✓ PASSED - Health check endpoint working"
else
    echo "✗ FAILED - Health check endpoint not responding"
    echo "Response: $HEALTH_RESPONSE"
    exit 1
fi
echo ""

# Test 2: Create a user (POST /api/users)
echo "[TEST 2] Create user via API (POST /api/users)"

CREATE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"John Doe","email":"john@example.com"}' \
    http://localhost:8080/api/users)

if echo "$CREATE_RESPONSE" | grep -q "John Doe"; then
    echo "✓ PASSED - User created successfully"
    USER_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
    echo "Created user ID: $USER_ID"
else
    echo "✗ FAILED - Could not create user"
    echo "Response: $CREATE_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Get all users (GET /api/users)
echo "[TEST 3] Retrieve all users (GET /api/users)"

GET_ALL_RESPONSE=$(curl -s http://localhost:8080/api/users)

if echo "$GET_ALL_RESPONSE" | grep -q "John Doe"; then
    echo "✓ PASSED - Retrieved users successfully"
else
    echo "✗ FAILED - Could not retrieve users"
    echo "Response: $GET_ALL_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get specific user (GET /api/users/:id)
echo "[TEST 4] Retrieve specific user (GET /api/users/${USER_ID})"

GET_ONE_RESPONSE=$(curl -s http://localhost:8080/api/users/${USER_ID})

if echo "$GET_ONE_RESPONSE" | grep -q "John Doe"; then
    echo "✓ PASSED - Retrieved specific user successfully"
else
    echo "✗ FAILED - Could not retrieve specific user"
    exit 1
fi
echo ""

# Test 5: Update user (PUT /api/users/:id)
echo "[TEST 5] Update user (PUT /api/users/${USER_ID})"

UPDATE_RESPONSE=$(curl -s -X PUT \
    -H "Content-Type: application/json" \
    -d '{"name":"Jane Doe"}' \
    http://localhost:8080/api/users/${USER_ID})

if echo "$UPDATE_RESPONSE" | grep -q "Jane Doe"; then
    echo "✓ PASSED - User updated successfully"
else
    echo "✗ FAILED - Could not update user"
    exit 1
fi
echo ""

# Test 6: Delete user (DELETE /api/users/:id)
echo "[TEST 6] Delete user (DELETE /api/users/${USER_ID})"

DELETE_RESPONSE=$(curl -s -X DELETE http://localhost:8080/api/users/${USER_ID})

if echo "$DELETE_RESPONSE" | grep -q "deleted"; then
    echo "✓ PASSED - User deleted successfully"
else
    echo "✗ FAILED - Could not delete user"
    exit 1
fi
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Hummingbird Node.js used as drop-in replacement (untouched image)"
echo "  ✓ Dependencies installed via builder init service"
echo "  ✓ Express REST API runs successfully"
echo "  ✓ Full CRUD operations work (POST/GET/PUT/DELETE)"
echo ""
echo "This validates that Hummingbird Node.js can replace"
echo "mainstream Node.js images for production web applications."
