#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/go:1.26"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: go-1-26 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify Go version
echo "[TEST 1] Verify Go 1.26 version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} go version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} go version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"go1.26"* ]]; then
    echo "✓ PASSED - Go 1.26 detected"
else
    echo "✗ FAILED - Expected Go 1.26, got ${VERSION_OUTPUT}"
    exit 1
fi
echo ""

# Test 2: Check Go environment
echo "[TEST 2] Verify Go environment"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} go env GOPATH GOROOT"
GOPATH_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} go env GOPATH)
GOROOT_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} go env GOROOT)
echo "GOPATH: ${GOPATH_OUTPUT}"
echo "GOROOT: ${GOROOT_OUTPUT}"
if [ -n "$GOPATH_OUTPUT" ] && [ -n "$GOROOT_OUTPUT" ]; then
    echo "✓ PASSED - Go environment is configured"
else
    echo "✗ FAILED - Go environment not properly set"
    exit 1
fi
echo ""

# Test 3: Compile and run a simple Go program
echo "[TEST 3] Compile and run Go program"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/test_program.go:/tmp/test_program.go:ro,z ${IMAGE} go run /tmp/test_program.go"
RUN_OUTPUT=$(${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/test_program.go:/tmp/test_program.go:ro,z" ${IMAGE} go run /tmp/test_program.go)
echo "Output: ${RUN_OUTPUT}"
if [[ "$RUN_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - Go program compiled and ran successfully"
else
    echo "✗ FAILED - Go program test failed"
    echo "Output: $RUN_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Verify Go build toolchain
echo "[TEST 4] Verify Go build toolchain"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/test_program.go:/tmp/test_program.go:ro,z ${IMAGE} go build -o /tmp/test_binary /tmp/test_program.go"
if ${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/test_program.go:/tmp/test_program.go:ro,z" ${IMAGE} go build -o /tmp/test_binary /tmp/test_program.go 2>&1; then
    echo "✓ PASSED - Go build toolchain works"
else
    echo "✗ FAILED - Go build failed"
    exit 1
fi
echo ""

echo "=================================="
echo "All go-1-26 tests PASSED!"
echo "=================================="
