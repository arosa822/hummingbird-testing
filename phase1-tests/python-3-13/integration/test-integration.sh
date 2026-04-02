#!/bin/bash
# Integration test for Hummingbird Python image
# Tests the image as a drop-in replacement for a production Python runtime
#
# Approach: The Hummingbird Python image is used UNTOUCHED — no custom
# Dockerfile, no modifications. A builder init service installs
# dependencies into a shared volume, then the Hummingbird image runs
# the Flask app with those deps mounted. This mirrors how you'd deploy
# Python apps in production with pre-built dependency layers.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

TEST_ENGINE="${TEST_ENGINE:-podman}"
COMPOSE_CMD="${TEST_ENGINE}-compose"

echo "=========================================="
echo "Python Integration Test (compose-based)"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Tearing down services..."
    ${COMPOSE_CMD} down --volumes --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

# Start services (deps builder runs first, then app)
echo "[SETUP] Installing dependencies and starting Flask app..."
${COMPOSE_CMD} up -d 2>&1

# Wait for Flask to be ready
echo "Waiting for Flask app to start..."
MAX_RETRIES=15
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -sf http://localhost:8080/ > /dev/null 2>&1; then
        echo "Flask app is ready."
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Flask app did not start within ${MAX_RETRIES} seconds"
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

# Test 2: Create a task (POST /api/tasks)
echo "[TEST 2] Create task via API (POST /api/tasks)"

CREATE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Task","description":"Integration test task"}' \
    http://localhost:8080/api/tasks)

if echo "$CREATE_RESPONSE" | grep -q "Test Task"; then
    echo "✓ PASSED - Task created successfully"
    TASK_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
    echo "Created task ID: $TASK_ID"
else
    echo "✗ FAILED - Could not create task"
    echo "Response: $CREATE_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Get all tasks (GET /api/tasks)
echo "[TEST 3] Retrieve all tasks (GET /api/tasks)"

GET_ALL_RESPONSE=$(curl -s http://localhost:8080/api/tasks)

if echo "$GET_ALL_RESPONSE" | grep -q "Test Task"; then
    echo "✓ PASSED - Retrieved tasks successfully"
else
    echo "✗ FAILED - Could not retrieve tasks"
    echo "Response: $GET_ALL_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get specific task (GET /api/tasks/:id)
echo "[TEST 4] Retrieve specific task (GET /api/tasks/${TASK_ID})"

GET_ONE_RESPONSE=$(curl -s http://localhost:8080/api/tasks/${TASK_ID})

if echo "$GET_ONE_RESPONSE" | grep -q "Test Task"; then
    echo "✓ PASSED - Retrieved specific task successfully"
else
    echo "✗ FAILED - Could not retrieve specific task"
    exit 1
fi
echo ""

# Test 5: Update task (PUT /api/tasks/:id)
echo "[TEST 5] Update task (PUT /api/tasks/${TASK_ID})"

UPDATE_RESPONSE=$(curl -s -X PUT \
    -H "Content-Type: application/json" \
    -d '{"completed":true}' \
    http://localhost:8080/api/tasks/${TASK_ID})

if echo "$UPDATE_RESPONSE" | grep -q "completed"; then
    echo "✓ PASSED - Task updated successfully"
else
    echo "✗ FAILED - Could not update task"
    exit 1
fi
echo ""

# Test 6: Delete task (DELETE /api/tasks/:id)
echo "[TEST 6] Delete task (DELETE /api/tasks/${TASK_ID})"

DELETE_RESPONSE=$(curl -s -X DELETE http://localhost:8080/api/tasks/${TASK_ID})

if echo "$DELETE_RESPONSE" | grep -q "deleted"; then
    echo "✓ PASSED - Task deleted successfully"
else
    echo "✗ FAILED - Could not delete task"
    exit 1
fi
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Hummingbird Python used as drop-in replacement (untouched image)"
echo "  ✓ Dependencies installed via builder init service"
echo "  ✓ Flask REST API runs successfully"
echo "  ✓ Full CRUD operations work (POST/GET/PUT/DELETE)"
echo ""
echo "This validates that Hummingbird Python can replace"
echo "mainstream Python images for production web applications."
