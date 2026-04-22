#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/openjdk:21"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: openjdk-21 Image Tests"
echo "=================================="
echo ""

# Test 1: Verify Java version
echo "[TEST 1] Verify OpenJDK 21 version"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} java -version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} java -version 2>&1)
echo "Output: ${VERSION_OUTPUT%%$'\n'*}"
if echo "$VERSION_OUTPUT" | grep -q "21"; then
    echo "✓ PASSED - OpenJDK 21 detected"
else
    echo "✗ FAILED - Expected OpenJDK 21"
    exit 1
fi
echo ""

# Test 2: Verify javac compiler
echo "[TEST 2] Verify javac compiler"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} javac -version"
JAVAC_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} javac -version 2>&1)
echo "Output: ${JAVAC_OUTPUT}"
if [[ "$JAVAC_OUTPUT" == *"21"* ]]; then
    echo "✓ PASSED - javac 21 detected"
else
    echo "✗ FAILED - Could not detect javac version"
    exit 1
fi
echo ""

# Test 3: Compile and run a Java program
echo "[TEST 3] Compile and run Java program"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Command: ${TEST_ENGINE} run --rm -v ${SCRIPT_DIR}/TestProgram.java:/tmp/TestProgram.java:ro,z --entrypoint '' ${IMAGE} bash -c 'javac /tmp/TestProgram.java -d /tmp && java -cp /tmp TestProgram'"
RUN_OUTPUT=$(${TEST_ENGINE} run --rm -v "${SCRIPT_DIR}/TestProgram.java:/tmp/TestProgram.java:ro,z" --entrypoint '' ${IMAGE} bash -c 'javac /tmp/TestProgram.java -d /tmp && java -cp /tmp TestProgram' 2>&1)
echo "Output: ${RUN_OUTPUT}"
if [[ "$RUN_OUTPUT" == *"4 passed, 0 failed"* ]]; then
    echo "✓ PASSED - Java program compiled and ran successfully"
else
    echo "✗ FAILED - Java program test failed"
    exit 1
fi
echo ""

# Test 4: Verify JDK tools
echo "[TEST 4] Verify JDK tools available"
echo "Command: ${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} jar --version"
JAR_OUTPUT=$(${TEST_ENGINE} run --rm --entrypoint '' ${IMAGE} jar --version 2>&1)
echo "Output: ${JAR_OUTPUT}"
if [[ "$JAR_OUTPUT" == *"21"* ]]; then
    echo "✓ PASSED - JDK tools available"
else
    echo "✗ FAILED - jar tool not working"
    exit 1
fi
echo ""

echo "=================================="
echo "All openjdk-21 tests PASSED!"
echo "=================================="
