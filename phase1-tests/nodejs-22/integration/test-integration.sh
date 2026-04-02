#!/bin/bash
# Integration test for Node.js image
# Tests building and running an Express.js REST API application

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGE_NAME="hummingbird-nodejs-integration-test"
BUILD_TAG="latest"
CONTAINER_NAME="nodejs-test-$$"
API_PORT="8080"

echo "=========================================="
echo "Node.js Integration Test"
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

# Test 1: Build the Express application image
echo "[TEST 1] Build Express API using Hummingbird Node.js as base"
echo "Command: ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} ."

if ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} . > /dev/null 2>&1; then
    echo "✓ PASSED - Express application image built successfully"
else
    echo "✗ FAILED - Failed to build Express application image"
    exit 1
fi
echo ""

# Test 2: Start the Express application
echo "[TEST 2] Start Express API server"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${API_PORT}:8080 ${IMAGE_NAME}:${BUILD_TAG}"

${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${API_PORT}:8080 ${IMAGE_NAME}:${BUILD_TAG} > /dev/null

# Wait for app to start
echo "Waiting for Express app to start..."
sleep 3

if ${TEST_ENGINE} ps | grep -q ${CONTAINER_NAME}; then
    echo "✓ PASSED - Express server started successfully"
else
    echo "✗ FAILED - Express server did not start"
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

# Test 4: Create a user (POST /api/users)
echo "[TEST 4] Create user via API (POST /api/users)"
echo "Command: curl -X POST -H 'Content-Type: application/json' -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\"}' http://localhost:${API_PORT}/api/users"

CREATE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"John Doe","email":"john@example.com"}' \
    http://localhost:${API_PORT}/api/users)

if echo "$CREATE_RESPONSE" | grep -q "John Doe"; then
    echo "✓ PASSED - User created successfully"
    USER_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id' 2>/dev/null || echo "1")
    echo "Created user ID: $USER_ID"
else
    echo "✗ FAILED - Could not create user"
    echo "Response: $CREATE_RESPONSE"
    exit 1
fi
echo ""

# Test 5: Get all users (GET /api/users)
echo "[TEST 5] Retrieve all users (GET /api/users)"
echo "Command: curl -s http://localhost:${API_PORT}/api/users"

GET_ALL_RESPONSE=$(curl -s http://localhost:${API_PORT}/api/users)

if echo "$GET_ALL_RESPONSE" | grep -q "John Doe"; then
    echo "✓ PASSED - Retrieved users successfully"
    USER_COUNT=$(echo "$GET_ALL_RESPONSE" | jq -r '.count' 2>/dev/null || echo "1")
    echo "Total users: $USER_COUNT"
else
    echo "✗ FAILED - Could not retrieve users"
    exit 1
fi
echo ""

# Test 6: Get specific user (GET /api/users/:id)
echo "[TEST 6] Retrieve specific user (GET /api/users/${USER_ID})"

GET_ONE_RESPONSE=$(curl -s http://localhost:${API_PORT}/api/users/${USER_ID})

if echo "$GET_ONE_RESPONSE" | grep -q "John Doe"; then
    echo "✓ PASSED - Retrieved specific user successfully"
else
    echo "✗ FAILED - Could not retrieve specific user"
    exit 1
fi
echo ""

# Test 7: Update user (PUT /api/users/:id)
echo "[TEST 7] Update user (PUT /api/users/${USER_ID})"

UPDATE_RESPONSE=$(curl -s -X PUT \
    -H "Content-Type: application/json" \
    -d '{"name":"Jane Doe"}' \
    http://localhost:${API_PORT}/api/users/${USER_ID})

if echo "$UPDATE_RESPONSE" | grep -q "Jane Doe"; then
    echo "✓ PASSED - User updated successfully"
else
    echo "✗ FAILED - Could not update user"
    exit 1
fi
echo ""

# Test 8: Delete user (DELETE /api/users/:id)
echo "[TEST 8] Delete user (DELETE /api/users/${USER_ID})"

DELETE_RESPONSE=$(curl -s -X DELETE http://localhost:${API_PORT}/api/users/${USER_ID})

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
echo "  ✓ Built Express application using Node.js image"
echo "  ✓ Express server runs successfully"
echo "  ✓ Health check endpoint works"
echo "  ✓ Create user (POST) works"
echo "  ✓ Get all users (GET) works"
echo "  ✓ Get single user (GET) works"
echo "  ✓ Update user (PUT) works"
echo "  ✓ Delete user (DELETE) works"
echo ""
echo "This validates that Hummingbird Node.js image can be"
echo "used as a base for building production web applications."
