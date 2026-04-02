#!/bin/bash
# Integration test for Python image
# Tests building and running a Flask REST API application

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGE_NAME="hummingbird-python-integration-test"
BUILD_TAG="latest"
CONTAINER_NAME="python-test-$$"
API_PORT="8080"

echo "=========================================="
echo "Python Integration Test"
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

# Test 1: Build the Flask application image
echo "[TEST 1] Build Flask API using Hummingbird Python as base"
echo "Command: ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} ."

if ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} .; then
    echo "✓ PASSED - Flask application image built successfully"
else
    echo "✗ FAILED - Failed to build Flask application image"
    exit 1
fi
echo ""

# Test 2: Start the Flask application
echo "[TEST 2] Start Flask API server"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${API_PORT}:8080 ${IMAGE_NAME}:${BUILD_TAG}"

${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${API_PORT}:8080 ${IMAGE_NAME}:${BUILD_TAG} > /dev/null

# Wait for app to start
echo "Waiting for Flask app to start..."
sleep 3

if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - Flask server started successfully"
else
    echo "✗ FAILED - Flask server did not start"
    exit 1
fi
echo ""

# Test 3: Health check endpoint
echo "[TEST 3] Test health check endpoint (GET /)"
echo "Command: curl -s http://localhost:${API_PORT}/"

MAX_RETRIES=5
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if HEALTH_RESPONSE=$(curl -s http://localhost:${API_PORT}/ 2>/dev/null); then
        if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
            echo "✓ PASSED - Health check endpoint working"
            echo "Response: $(echo "$HEALTH_RESPONSE" | jq -r '.status' 2>/dev/null || echo "$HEALTH_RESPONSE")"
            break
        fi
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - Health check endpoint not responding"
    exit 1
fi
echo ""

# Test 4: Create a task (POST /api/tasks)
echo "[TEST 4] Create task via API (POST /api/tasks)"
echo "Command: curl -X POST -H 'Content-Type: application/json' -d '{\"title\":\"Test Task\"}' http://localhost:${API_PORT}/api/tasks"

CREATE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Task","description":"Integration test task"}' \
    http://localhost:${API_PORT}/api/tasks)

if echo "$CREATE_RESPONSE" | grep -q "Test Task"; then
    echo "✓ PASSED - Task created successfully"
    TASK_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id' 2>/dev/null || echo "1")
    echo "Created task ID: $TASK_ID"
else
    echo "✗ FAILED - Could not create task"
    echo "Response: $CREATE_RESPONSE"
    exit 1
fi
echo ""

# Test 5: Get all tasks (GET /api/tasks)
echo "[TEST 5] Retrieve all tasks (GET /api/tasks)"
echo "Command: curl -s http://localhost:${API_PORT}/api/tasks"

GET_ALL_RESPONSE=$(curl -s http://localhost:${API_PORT}/api/tasks)

if echo "$GET_ALL_RESPONSE" | grep -q "Test Task"; then
    echo "✓ PASSED - Retrieved tasks successfully"
    TASK_COUNT=$(echo "$GET_ALL_RESPONSE" | jq -r '.count' 2>/dev/null || echo "1")
    echo "Total tasks: $TASK_COUNT"
else
    echo "✗ FAILED - Could not retrieve tasks"
    exit 1
fi
echo ""

# Test 6: Get specific task (GET /api/tasks/:id)
echo "[TEST 6] Retrieve specific task (GET /api/tasks/${TASK_ID})"

GET_ONE_RESPONSE=$(curl -s http://localhost:${API_PORT}/api/tasks/${TASK_ID})

if echo "$GET_ONE_RESPONSE" | grep -q "Test Task"; then
    echo "✓ PASSED - Retrieved specific task successfully"
else
    echo "✗ FAILED - Could not retrieve specific task"
    exit 1
fi
echo ""

# Test 7: Update task (PUT /api/tasks/:id)
echo "[TEST 7] Update task (PUT /api/tasks/${TASK_ID})"

UPDATE_RESPONSE=$(curl -s -X PUT \
    -H "Content-Type: application/json" \
    -d '{"completed":true}' \
    http://localhost:${API_PORT}/api/tasks/${TASK_ID})

if echo "$UPDATE_RESPONSE" | grep -q '"completed":true' || echo "$UPDATE_RESPONSE" | grep -q '"completed": true'; then
    echo "✓ PASSED - Task updated successfully"
else
    echo "✗ FAILED - Could not update task"
    exit 1
fi
echo ""

# Test 8: Delete task (DELETE /api/tasks/:id)
echo "[TEST 8] Delete task (DELETE /api/tasks/${TASK_ID})"

DELETE_RESPONSE=$(curl -s -X DELETE http://localhost:${API_PORT}/api/tasks/${TASK_ID})

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
echo "  ✓ Built Flask application using Python image"
echo "  ✓ Flask server runs successfully"
echo "  ✓ Health check endpoint works"
echo "  ✓ Create task (POST) works"
echo "  ✓ Get all tasks (GET) works"
echo "  ✓ Get single task (GET) works"
echo "  ✓ Update task (PUT) works"
echo "  ✓ Delete task (DELETE) works"
echo ""
echo "This validates that Hummingbird Python image can be"
echo "used as a base for building production web applications."
