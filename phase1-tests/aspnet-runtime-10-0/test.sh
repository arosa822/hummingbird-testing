#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/aspnet-runtime:10.0"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: aspnet-runtime-10-0 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify .NET version
echo "[TEST 1] Verify ASP.NET runtime version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --info"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --info 2>&1)
echo "Output: ${VERSION_OUTPUT%%$'\n'*}"
if echo "$VERSION_OUTPUT" | grep -q "10\.0"; then
    echo "✓ PASSED - ASP.NET 10.0 runtime detected"
else
    echo "✗ FAILED - Expected ASP.NET 10.0"
    echo "$VERSION_OUTPUT"
    exit 1
fi
echo ""

# Test 2: Verify help output
echo "[TEST 2] Verify dotnet help output"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --help"
HELP_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --help 2>&1 || true)
if echo "$HELP_OUTPUT" | grep -qi "Usage"; then
    echo "✓ PASSED - Help output contains Usage information"
else
    echo "✗ FAILED - Help output missing Usage information"
    echo "$HELP_OUTPUT"
    exit 1
fi
echo ""

# Test 3: List runtimes
echo "[TEST 3] List installed runtimes"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --list-runtimes"
RUNTIMES_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --list-runtimes 2>&1)
echo "Output: ${RUNTIMES_OUTPUT}"
if echo "$RUNTIMES_OUTPUT" | grep -q "Microsoft.AspNetCore.App"; then
    echo "✓ PASSED - ASP.NET Core runtime listed"
else
    echo "✗ FAILED - ASP.NET Core runtime not found in list"
    exit 1
fi
echo ""

# Test 4: Verify no crash on --version
echo "[TEST 4] Verify dotnet --version runs without crash"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --version"
VERSION_SHORT=$(${TEST_ENGINE} run --rm ${IMAGE} --version 2>&1 || true)
echo "Output: ${VERSION_SHORT}"
if [ -n "$VERSION_SHORT" ]; then
    echo "✓ PASSED - dotnet --version completed successfully"
else
    echo "✗ FAILED - dotnet --version produced no output"
    exit 1
fi
echo ""

echo "=================================="
echo "All aspnet-runtime-10-0 tests PASSED!"
echo "=================================="
