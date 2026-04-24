#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/xcaddy:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: xcaddy Image Tests"
echo "=================================="
echo ""

# Test 1: Verify xcaddy version
echo "[TEST 1] Verify xcaddy version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} version 2>&1)
echo "Output: ${VERSION_OUTPUT%%$'\n'*}"
if [ -n "$VERSION_OUTPUT" ]; then
    echo "✓ PASSED - xcaddy version output received"
else
    echo "✗ FAILED - xcaddy version produced no output"
    exit 1
fi
echo ""

# Test 2: Verify xcaddy help output
echo "[TEST 2] Verify xcaddy help output"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} xcaddy help"
HELP_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} xcaddy help 2>&1)
if echo "$HELP_OUTPUT" | grep -qi "usage\|build\|help"; then
    echo "✓ PASSED - Help output contains usage information"
else
    echo "✗ FAILED - Help output missing usage information"
    echo "$HELP_OUTPUT"
    exit 1
fi
echo ""

# Test 3: Verify xcaddy responds to build subcommand (dry check)
echo "[TEST 3] Verify xcaddy build subcommand is available"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} xcaddy build --help"
BUILD_HELP=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} xcaddy build --help 2>&1)
if echo "$BUILD_HELP" | grep -qi "build\|usage\|caddy"; then
    echo "✓ PASSED - xcaddy build subcommand is available"
else
    echo "✗ FAILED - xcaddy build subcommand not responding"
    echo "$BUILD_HELP"
    exit 1
fi
echo ""

# Test 4: Verify Go is available (xcaddy requires Go)
echo "[TEST 4] Verify Go toolchain is available"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} go version"
GO_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} go version 2>&1)
echo "Output: ${GO_OUTPUT}"
if echo "$GO_OUTPUT" | grep -q "go"; then
    echo "✓ PASSED - Go toolchain is available"
else
    echo "✗ FAILED - Go toolchain not found"
    exit 1
fi
echo ""

echo "=================================="
echo "All xcaddy tests PASSED!"
echo "=================================="
