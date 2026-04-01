#!/bin/bash
# Phase 1 Test Script for Hummingbird nodejs-22 image
# Tests basic Node.js runtime functionality

set -euo pipefail

IMAGE="quay.io/hummingbird/nodejs:22"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: nodejs-22 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify Node.js version
echo "[TEST 1] Verify Node.js 22.x version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"v22."* ]]; then
    echo "✓ PASSED - Node.js 22.x detected"
else
    echo "✗ FAILED - Expected Node.js v22.x, got ${VERSION_OUTPUT}"
    exit 1
fi
echo ""

# Test 2: Execute simple JavaScript inline
echo "[TEST 2] Execute inline JavaScript code"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -e \"console.log('Hello, World!')\""
OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -e "console.log('Hello, World!')")
if [ "$OUTPUT" = "Hello, World!" ]; then
    echo "✓ PASSED - JavaScript execution works: $OUTPUT"
else
    echo "✗ FAILED - Expected 'Hello, World!', got $OUTPUT"
    exit 1
fi
echo ""

# Test 3: Test Node.js built-in modules
echo "[TEST 3] Test Node.js built-in modules"
JS_CODE="const os = require('os'); console.log(os.platform());"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -e \"${JS_CODE}\""
PLATFORM_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -e "${JS_CODE}")
if [[ "$PLATFORM_OUTPUT" == "linux" ]]; then
    echo "✓ PASSED - Built-in modules accessible: platform = $PLATFORM_OUTPUT"
else
    echo "✗ FAILED - Expected 'linux', got $PLATFORM_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Run Node.js script from file
echo "[TEST 4] Execute Node.js script file"
echo "Command: ${TEST_ENGINE} run --rm -v \$(pwd)/test_script.js:/app/test.js:ro ${IMAGE} /app/test.js"
SCRIPT_OUTPUT=$(${TEST_ENGINE} run --rm -v "$(pwd)/test_script.js:/app/test.js:ro" ${IMAGE} /app/test.js)
if [[ "$SCRIPT_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - Node.js script execution successful"
    echo "Script output:"
    echo "$SCRIPT_OUTPUT"
else
    echo "✗ FAILED - Node.js script test failed"
    echo "Output: $SCRIPT_OUTPUT"
    exit 1
fi
echo ""

echo "=================================="
echo "All nodejs-22 tests PASSED!"
echo "=================================="
