#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/ruby:3.4"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: ruby-3-4 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify Ruby version
echo "[TEST 1] Verify Ruby 3.4 version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} ruby --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} ruby --version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"ruby 3.4"* ]]; then
    echo "✓ PASSED - Ruby 3.4 detected"
else
    echo "✗ FAILED - Expected Ruby 3.4, got ${VERSION_OUTPUT}"
    exit 1
fi
echo ""

# Test 2: Execute simple Ruby command
echo "[TEST 2] Execute inline Ruby code"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} ruby -e \"puts 'Hello, World!'\""
OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} ruby -e "puts 'Hello, World!'")
if [ "$OUTPUT" = "Hello, World!" ]; then
    echo "✓ PASSED - Ruby code execution works: $OUTPUT"
else
    echo "✗ FAILED - Expected 'Hello, World!', got $OUTPUT"
    exit 1
fi
echo ""

# Test 3: Test Ruby standard library (JSON)
echo "[TEST 3] Test Ruby standard library access"
RUBY_CODE="require 'json'; data = {'test' => 123}; puts JSON.generate(data)"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} ruby -e \"${RUBY_CODE}\""
JSON_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} ruby -e "${RUBY_CODE}")
if [[ "$JSON_OUTPUT" == *'"test"'* ]] && [[ "$JSON_OUTPUT" == *'123'* ]]; then
    echo "✓ PASSED - Standard library (JSON) works: $JSON_OUTPUT"
else
    echo "✗ FAILED - JSON module test failed"
    exit 1
fi
echo ""

# Test 4: Run Ruby script from file
echo "[TEST 4] Execute Ruby script file"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/test_script.rb:/app/test.rb:ro,z ${IMAGE} ruby /app/test.rb"
SCRIPT_OUTPUT=$(${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/test_script.rb:/app/test.rb:ro,z" ${IMAGE} ruby /app/test.rb)
if [[ "$SCRIPT_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - Ruby script execution successful"
    echo "Script output:"
    echo "$SCRIPT_OUTPUT"
else
    echo "✗ FAILED - Ruby script test failed"
    echo "Output: $SCRIPT_OUTPUT"
    exit 1
fi
echo ""

echo "=================================="
echo "All ruby-3-4 tests PASSED!"
echo "=================================="
