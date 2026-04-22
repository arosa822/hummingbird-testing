#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/php:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: php Image Tests"
echo "=================================="
echo ""

# Test 1: Verify PHP version
echo "[TEST 1] Verify PHP version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -v"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -v 2>&1)
echo "Output: ${VERSION_OUTPUT%%$'\n'*}"
if [[ "$VERSION_OUTPUT" == *"PHP"* ]]; then
    echo "✓ PASSED - PHP version detected"
else
    echo "✗ FAILED - Could not detect PHP version"
    exit 1
fi
echo ""

# Test 2: Execute simple PHP command
echo "[TEST 2] Execute inline PHP code"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -r \"echo 'Hello, World!';\""
OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -r "echo 'Hello, World!';")
if [ "$OUTPUT" = "Hello, World!" ]; then
    echo "✓ PASSED - PHP code execution works: $OUTPUT"
else
    echo "✗ FAILED - Expected 'Hello, World!', got $OUTPUT"
    exit 1
fi
echo ""

# Test 3: Test PHP built-in functions (JSON)
echo "[TEST 3] Test PHP built-in functions"
PHP_CODE='echo json_encode(["test" => 123]);'
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -r \"${PHP_CODE}\""
JSON_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -r "${PHP_CODE}")
if [[ "$JSON_OUTPUT" == *'"test"'* ]] && [[ "$JSON_OUTPUT" == *'123'* ]]; then
    echo "✓ PASSED - Built-in functions (json) work: $JSON_OUTPUT"
else
    echo "✗ FAILED - JSON test failed"
    exit 1
fi
echo ""

# Test 4: Run PHP script from file
echo "[TEST 4] Execute PHP script file"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/test_script.php:/app/test.php:ro,z ${IMAGE} /app/test.php"
SCRIPT_OUTPUT=$(${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/test_script.php:/app/test.php:ro,z" ${IMAGE} /app/test.php)
if [[ "$SCRIPT_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - PHP script execution successful"
    echo "Script output:"
    echo "$SCRIPT_OUTPUT"
else
    echo "✗ FAILED - PHP script test failed"
    echo "Output: $SCRIPT_OUTPUT"
    exit 1
fi
echo ""

echo "=================================="
echo "All php tests PASSED!"
echo "=================================="
