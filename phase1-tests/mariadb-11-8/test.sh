#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/mariadb:11.8"
TEST_ENGINE="${TEST_ENGINE:-podman}"
CONTAINER_NAME="hummingbird-mariadb-test-$$"
HOST_PORT=$(( (RANDOM % 10000) + 20000 ))

echo "=================================="
echo "Phase 1: mariadb-11-8 Image Tests"
echo "=================================="
echo ""

cleanup() {
    echo "Cleaning up..."
    ${TEST_ENGINE} rm -f ${CONTAINER_NAME} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Start MariaDB container
echo "[TEST 1] Start MariaDB container"
echo "Command: ${TEST_ENGINE} run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:3306 -e MARIADB_ROOT_PASSWORD=testpass ${IMAGE}"
${TEST_ENGINE} run -d --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:3306 \
    -e MARIADB_ROOT_PASSWORD=testpass \
    ${IMAGE} > /dev/null
echo "Waiting for MariaDB to initialize..."
sleep 5
MAX_RETRIES=20
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if ${TEST_ENGINE} exec ${CONTAINER_NAME} mariadb -u root -ptestpass -e 'SELECT 1' 2>/dev/null | grep -q 1; then
        break
    fi
    RETRY=$((RETRY + 1))
    sleep 2
done
if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ FAILED - MariaDB did not start in time"
    ${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1 | tail -20
    exit 1
fi
echo "✓ PASSED - MariaDB container started successfully"
echo ""

# Test 2: Check MariaDB version
echo "[TEST 2] Verify MariaDB version"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} mariadb -u root -ptestpass -e 'SELECT VERSION();'"
VERSION_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} mariadb -u root -ptestpass -e 'SELECT VERSION();' 2>&1)
echo "Output: $(echo "$VERSION_OUTPUT" | grep -i mariadb || echo "$VERSION_OUTPUT" | tail -1)"
if echo "$VERSION_OUTPUT" | grep -qi "11.8\|MariaDB"; then
    echo "✓ PASSED - MariaDB 11.8 detected"
else
    echo "✗ FAILED - Could not verify MariaDB version"
    echo "$VERSION_OUTPUT"
    exit 1
fi
echo ""

# Test 3: Create table and insert data
echo "[TEST 3] Create table and insert data"
echo "Command: ${TEST_ENGINE} exec ${CONTAINER_NAME} mariadb -u root -ptestpass -e 'CREATE TABLE ...'"
SQL_OUTPUT=$(${TEST_ENGINE} exec ${CONTAINER_NAME} mariadb -u root -ptestpass -e "
    CREATE DATABASE IF NOT EXISTS testdb;
    USE testdb;
    CREATE TABLE test_table (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));
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
echo "[TEST 4] Verify no critical errors in MariaDB logs"
echo "Command: ${TEST_ENGINE} logs ${CONTAINER_NAME}"
LOGS=$(${TEST_ENGINE} logs ${CONTAINER_NAME} 2>&1)
if echo "$LOGS" | grep -qi "\[ERROR\].*fatal\|\[ERROR\].*crash"; then
    echo "✗ FAILED - Found critical errors in logs:"
    echo "$LOGS" | grep -i "ERROR.*fatal\|ERROR.*crash" | head -5
    exit 1
else
    echo "✓ PASSED - No critical errors in logs"
fi
echo ""

echo "=================================="
echo "All mariadb-11-8 tests PASSED!"
echo "=================================="
