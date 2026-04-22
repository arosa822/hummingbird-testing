#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/rust:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: rust Image Tests"
echo "=================================="
echo ""

# Test 1: Verify Rust compiler version
echo "[TEST 1] Verify rustc version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} rustc --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} rustc --version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"rustc"* ]]; then
    echo "✓ PASSED - rustc version detected"
else
    echo "✗ FAILED - Could not detect rustc version"
    exit 1
fi
echo ""

# Test 2: Verify Cargo is available
echo "[TEST 2] Verify cargo version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} cargo --version"
CARGO_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} cargo --version)
echo "Output: ${CARGO_OUTPUT}"
if [[ "$CARGO_OUTPUT" == *"cargo"* ]]; then
    echo "✓ PASSED - cargo version detected"
else
    echo "✗ FAILED - Could not detect cargo version"
    exit 1
fi
echo ""

# Test 3: Compile and run a Rust program
echo "[TEST 3] Compile and run Rust program"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/test_program.rs:/tmp/test_program.rs:ro,z ${IMAGE} bash -c 'rustc /tmp/test_program.rs -o /tmp/test_binary && /tmp/test_binary'"
RUN_OUTPUT=$(${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/test_program.rs:/tmp/test_program.rs:ro,z" ${IMAGE} bash -c 'rustc /tmp/test_program.rs -o /tmp/test_binary && /tmp/test_binary')
echo "Output: ${RUN_OUTPUT}"
if [[ "$RUN_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - Rust program compiled and ran successfully"
else
    echo "✗ FAILED - Rust program test failed"
    exit 1
fi
echo ""

# Test 4: Verify Rust toolchain sysroot
echo "[TEST 4] Verify Rust toolchain"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} rustc --print sysroot"
SYSROOT_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} rustc --print sysroot 2>&1)
echo "Output: ${SYSROOT_OUTPUT}"
if [ -n "$SYSROOT_OUTPUT" ]; then
    echo "✓ PASSED - Rust toolchain sysroot: ${SYSROOT_OUTPUT}"
else
    echo "✗ FAILED - Could not determine Rust sysroot"
    exit 1
fi
echo ""

echo "=================================="
echo "All rust tests PASSED!"
echo "=================================="
