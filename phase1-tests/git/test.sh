#!/bin/bash
set -euo pipefail

IMAGE="quay.io/hummingbird/git:latest"
TEST_ENGINE="${TEST_ENGINE:-podman}"

echo "=================================="
echo "Phase 1: git Image Tests"
echo "=================================="
echo ""

# Test 1: Verify git version
echo "[TEST 1] Verify git version"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --version"
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --version)
echo "Output: ${VERSION_OUTPUT}"
if [[ "$VERSION_OUTPUT" == *"git version"* ]]; then
    echo "✓ PASSED - git version detected"
else
    echo "✗ FAILED - Could not detect git version"
    exit 1
fi
echo ""

# Test 2: Verify help output
echo "[TEST 2] Verify git help output"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} --help"
HELP_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --help)
if [[ "$HELP_OUTPUT" == *"usage: git"* ]]; then
    echo "✓ PASSED - git help output works"
else
    echo "✗ FAILED - git help output not recognized"
    exit 1
fi
echo ""

# Test 3: Initialize a repository
echo "[TEST 3] Initialize a git repository"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} init /tmp/test-repo"
INIT_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} init /tmp/test-repo)
echo "Output: ${INIT_OUTPUT}"
if [[ "$INIT_OUTPUT" == *"Initialized"* ]]; then
    echo "✓ PASSED - git init works"
else
    echo "✗ FAILED - git init did not produce expected output"
    exit 1
fi
echo ""

# Test 4: Clone a public repository
echo "[TEST 4] Clone a public repository"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE} clone --depth 1 https://github.com/octocat/Hello-World.git /tmp/hello-world"
CLONE_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} clone --depth 1 https://github.com/octocat/Hello-World.git /tmp/hello-world 2>&1)
echo "Output: ${CLONE_OUTPUT}"
if [[ "$CLONE_OUTPUT" == *"Cloning"* ]] || [[ "$CLONE_OUTPUT" == *"done"* ]]; then
    echo "✓ PASSED - git clone works"
else
    echo "✗ FAILED - git clone did not work"
    exit 1
fi
echo ""

echo "=================================="
echo "All git tests PASSED!"
echo "=================================="
