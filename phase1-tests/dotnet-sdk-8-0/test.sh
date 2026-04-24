#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/dotnet-sdk:8.0"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: dotnet-sdk-8-0 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify .NET SDK version
echo "[TEST 1] Verify .NET SDK version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} dotnet --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} dotnet --version 2>&1)
echo "Output: ${VERSION_OUTPUT}"
if echo "$VERSION_OUTPUT" | grep -q "8\.0"; then
    echo "✓ PASSED - .NET SDK 8.0 detected"
else
    echo "✗ FAILED - Expected .NET SDK 8.0"
    echo "$VERSION_OUTPUT"
    exit 1
fi
echo ""

# Test 2: List installed SDKs
echo "[TEST 2] List installed SDKs"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} dotnet --list-sdks"
SDKS_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} dotnet --list-sdks 2>&1)
echo "Output: ${SDKS_OUTPUT}"
if echo "$SDKS_OUTPUT" | grep -q "8\.0"; then
    echo "✓ PASSED - .NET SDK 8.0 listed"
else
    echo "✗ FAILED - .NET SDK 8.0 not found in list"
    exit 1
fi
echo ""

# Test 3: Create and build a console project
echo "[TEST 3] Create and build a .NET console project"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} bash -c 'dotnet new console -o /tmp/testapp && dotnet build /tmp/testapp'"
BUILD_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} bash -c 'dotnet new console -o /tmp/testapp && dotnet build /tmp/testapp' 2>&1)
if echo "$BUILD_OUTPUT" | grep -qi "Build succeeded"; then
    echo "✓ PASSED - Project created and built successfully"
else
    echo "✗ FAILED - Project build failed"
    echo "$BUILD_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Run the console project
echo "[TEST 4] Run the .NET console project"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} bash -c 'dotnet new console -o /tmp/testapp --force && dotnet run --project /tmp/testapp'"
RUN_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} bash -c 'dotnet new console -o /tmp/testapp --force && dotnet run --project /tmp/testapp' 2>&1)
echo "Output: ${RUN_OUTPUT}"
if echo "$RUN_OUTPUT" | grep -q "Hello, World!"; then
    echo "✓ PASSED - Project runs and outputs Hello, World!"
else
    echo "✗ FAILED - Expected 'Hello, World!' in output"
    exit 1
fi
echo ""

echo "=================================="
echo "All dotnet-sdk-8-0 tests PASSED!"
echo "=================================="
