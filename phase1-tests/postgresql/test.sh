#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/postgresql:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-postgresql-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))

echo "=================================="
echo "Phase 1: postgresql Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Start PostgreSQL container
echo "[TEST 1] Start PostgreSQL container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:5432 -e POSTGRES_PASSWORD=testpass ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:5432 \
    -e POSTGRES_PASSWORD=testpass \
    ${IMAGE} > /dev/null
echo "Waiting for PostgreSQL to initialize..."
sleep 5
MAX_RETRIES=20
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if ${TEST_ENGINE} exec ${CONTAINER_NAME} psql -U postgres -c '\q' 2>/dev/null; then
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 2
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - PostgreSQL did not start in time"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 | tail -20
    exit 1
fi
echo "✓ PASSED - PostgreSQL container started successfully"
echo ""

# Test 2: Check PostgreSQL version via psql
echo "[TEST 2] Verify PostgreSQL version"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} psql -U postgres -c 'SELECT version();'"
VERSION_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} psql -U postgres -c 'SELECT version();' 2>&1)
echo "Output: $(echo "$VERSION_OUTPUT" | grep -i postgresql | head -1)"
if echo "$VERSION_OUTPUT" | grep -qi "postgresql"; then
    echo "✓ PASSED - PostgreSQL version detected"
else
    echo "✗ FAILED - Could not query PostgreSQL version"
    echo "$VERSION_OUTPUT"
    exit 1
fi
echo ""

# Test 3: Create table and insert data
echo "[TEST 3] Create table and insert data"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} psql -U postgres -c 'CREATE TABLE ...'"
SQL_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} psql -U postgres -c "
    CREATE TABLE test_table (id SERIAL PRIMARY KEY, name VARCHAR(50));
    INSERT INTO test_table (name) VALUES ('hummingbird');
    SELECT name FROM test_table WHERE id = 1;
" 2>&1)
echo "Output: ${SQL_OUTPUT}"
if echo "$SQL_OUTPUT" | grep -q "hummingbird"; then
    echo "✓ PASSED - Table creation and data operations work"
else
    echo "✗ FAILED - SQL operations failed"
    exit 1
fi
echo ""

# Test 4: Verify no critical errors in logs
echo "[TEST 4] Verify no critical errors in PostgreSQL logs"
echo "Command: ${TEST_ENGINE} logs ${CONTAINER_NAME}"
LOGS=$(${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1)
if echo "$LOGS" | grep -qi "FATAL\|PANIC"; then
    echo "✗ FAILED - Found critical errors in logs:"
    echo "$LOGS" | grep -i "FATAL\|PANIC" | head -5
    exit 1
else
    echo "✓ PASSED - No critical errors in logs"
fi
echo ""

echo "=================================="
echo "All postgresql tests PASSED!"
echo "=================================="
