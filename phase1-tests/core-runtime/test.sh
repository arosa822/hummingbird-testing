#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/core-runtime:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: core-runtime Image Tests"
echo "=================================="
echo ""

# Test 1: Check OS info
echo "[TEST 1] Check OS release information"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} cat /etc/os-release"
OS_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} cat /etc/os-release 2>&1)
echo "Output: ${OS_OUTPUT%%$'\n'*}"
if echo "$OS_OUTPUT" | grep -qi "Hummingbird"; then
    echo "✓ PASSED - Hummingbird OS detected"
else
    echo "✗ FAILED - Expected Hummingbird in os-release"
    echo "$OS_OUTPUT"
    exit 1
fi
echo ""

# Test 2: Verify bash works
echo "[TEST 2] Verify bash execution"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} bash -c \"echo 'Hello, World!'\""
BASH_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} bash -c "echo 'Hello, World!'")
if [ "$BASH_OUTPUT" = "Hello, World!" ]; then
    echo "✓ PASSED - Bash execution works: $BASH_OUTPUT"
else
    echo "✗ FAILED - Expected 'Hello, World!', got $BASH_OUTPUT"
    exit 1
fi
echo ""

# Test 3: Check coreutils
echo "[TEST 3] Check coreutils and filesystem"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} ls /"
LS_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} ls / 2>&1)
echo "Output: ${LS_OUTPUT}"
if echo "$LS_OUTPUT" | grep -q "usr" && echo "$LS_OUTPUT" | grep -q "etc"; then
    echo "✓ PASSED - Common directories present in root filesystem"
else
    echo "✗ FAILED - Expected common directories (usr, etc) in /"
    exit 1
fi
echo ""

# Test 4: File operations
echo "[TEST 4] Verify file write and read operations"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} bash -c 'echo test-content > /tmp/testfile && cat /tmp/testfile'"
FILE_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} bash -c 'echo test-content > /tmp/testfile && cat /tmp/testfile')
if [ "$FILE_OUTPUT" = "test-content" ]; then
    echo "✓ PASSED - File write and read operations work"
else
    echo "✗ FAILED - Expected 'test-content', got $FILE_OUTPUT"
    exit 1
fi
echo ""

echo "=================================="
echo "All core-runtime tests PASSED!"
echo "=================================="
