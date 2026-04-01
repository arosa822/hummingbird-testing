#!/bin/bash
# Phase 1 Test Script for Hummingbird python-3-13 image
# Tests basic Python runtime functionality

set -euo pipefail

IMAGE="quay.io/hummingbird/python:3.13"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: python-3-13 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify Python version
echo "[TEST 1] Verify Python 3.13 version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"Python 3.13"* ]]; then
    echo "✓ PASSED - Python 3.13 detected"
else
    echo "✗ FAILED - Expected Python 3.13, got ${VERSION_OUTPUT}"
    exit 1
fi
echo ""

# Test 2: Execute simple Python command
echo "[TEST 2] Execute inline Python code"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -c \"print('Hello, World!')\""
OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -c "print('Hello, World!')")
if [ "$OUTPUT" = "Hello, World!" ]; then
    echo "✓ PASSED - Python code execution works: $OUTPUT"
else
    echo "✗ FAILED - Expected 'Hello, World!', got $OUTPUT"
    exit 1
fi
echo ""

# Test 3: Test Python standard library (json module)
echo "[TEST 3] Test Python standard library access"
PYTHON_CODE='import json; data={"test": 123}; print(json.dumps(data))'
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} -c \"${PYTHON_CODE}\""
JSON_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} -c "${PYTHON_CODE}")
if [[ "$JSON_OUTPUT" == *'"test"'* ]] && [[ "$JSON_OUTPUT" == *'123'* ]]; then
    echo "✓ PASSED - Standard library (json) works: $JSON_OUTPUT"
else
    echo "✗ FAILED - JSON module test failed"
    exit 1
fi
echo ""

# Test 4: Run Python script from file
echo "[TEST 4] Execute Python script file"
echo "Command: ${TEST_ENGINE} run --rm -v \$(pwd)/test_script.py:/app/test.py:ro ${IMAGE} /app/test.py"
SCRIPT_OUTPUT=$(${TEST_ENGINE} run --rm -v "$(pwd)/test_script.py:/app/test.py:ro" ${IMAGE} /app/test.py)
if [[ "$SCRIPT_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - Python script execution successful"
    echo "Script output:"
    echo "$SCRIPT_OUTPUT"
else
    echo "✗ FAILED - Python script test failed"
    echo "Output: $SCRIPT_OUTPUT"
    exit 1
fi
echo ""

echo "=================================="
echo "All python-3-13 tests PASSED!"
echo "=================================="
