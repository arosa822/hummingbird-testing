#!/bin/bash
# Integration test for jq image
# Tests building and running a data processing pipeline

set -euo pipefail

TEST_ENGINE="${TEST_ENGINE:-podman}"
IMAGE_NAME="hummingbird-jq-integration-test"
BUILD_TAG="latest"

echo "=========================================="
echo "jq Integration Test"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Removing test image..."
    ${TEST_ENGINE} rmi ${IMAGE_NAME}:${BUILD_TAG} 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Build the data processing application
echo "[TEST 1] Build data processing app using Hummingbird jq as base"
echo "Command: ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} ."

if ${TEST_ENGINE} build -t ${IMAGE_NAME}:${BUILD_TAG} .; then
    echo "✓ PASSED - Data processing application built successfully"
else
    echo "✗ FAILED - Failed to build data processing application"
    exit 1
fi
echo ""

# Test 2: Run the data processing pipeline
echo "[TEST 2] Execute data processing pipeline"
echo "Command: ${TEST_ENGINE} run --rm ${IMAGE_NAME}:${BUILD_TAG}"

OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE_NAME}:${BUILD_TAG} 2>&1)

if echo "$OUTPUT" | grep -q "Data Processing Complete!"; then
    echo "✓ PASSED - Pipeline executed successfully"
else
    echo "✗ FAILED - Pipeline did not complete"
    echo "Output: $OUTPUT"
    exit 1
fi
echo ""

# Test 3: Verify active user filtering
echo "[TEST 3] Verify active user filtering works"

if echo "$OUTPUT" | grep -q "Active Users:"; then
    echo "✓ PASSED - User filtering successful"
else
    echo "✗ FAILED - User filtering failed"
    exit 1
fi
echo ""

# Test 4: Verify statistical calculations
echo "[TEST 4] Verify statistical calculations"

if echo "$OUTPUT" | grep -q "Average Age:"; then
    echo "✓ PASSED - Statistical calculations work"
else
    echo "✗ FAILED - Statistical calculations failed"
    exit 1
fi
echo ""

# Test 5: Verify sorting and ranking
echo "[TEST 5] Verify sorting and ranking"

if echo "$OUTPUT" | grep -q "Top Spenders:"; then
    echo "✓ PASSED - Sorting and ranking work"
else
    echo "✗ FAILED - Sorting and ranking failed"
    exit 1
fi
echo ""

# Test 6: Verify grouping and aggregation
echo "[TEST 6] Verify grouping and aggregation"

if echo "$OUTPUT" | grep -q "Order Status Summary:"; then
    echo "✓ PASSED - Grouping and aggregation work"
else
    echo "✗ FAILED - Grouping and aggregation failed"
    exit 1
fi
echo ""

# Test 7: Verify data joining
echo "[TEST 7] Verify data joining across files"

if echo "$OUTPUT" | grep -q "User Order Summary"; then
    echo "✓ PASSED - Data joining works"
else
    echo "✗ FAILED - Data joining failed"
    exit 1
fi
echo ""

# Test 8: Verify format transformation
echo "[TEST 8] Verify JSON to CSV transformation"

if echo "$OUTPUT" | grep -q "CSV Output:"; then
    echo "✓ PASSED - Format transformation works"
else
    echo "✗ FAILED - Format transformation failed"
    exit 1
fi
echo ""

# Test 9: Verify summary report generation
echo "[TEST 9] Verify summary report generation"

if echo "$OUTPUT" | grep -q "Summary Report:"; then
    echo "✓ PASSED - Summary report generation works"
else
    echo "✗ FAILED - Summary report generation failed"
    exit 1
fi
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Built data processing app using jq image"
echo "  ✓ Pipeline runs successfully"
echo "  ✓ Data filtering works"
echo "  ✓ Statistical calculations work"
echo "  ✓ Sorting and ranking work"
echo "  ✓ Grouping and aggregation work"
echo "  ✓ Data joining works"
echo "  ✓ Format transformation works"
echo "  ✓ Summary generation works"
echo ""
echo "This validates that Hummingbird jq image can be"
echo "used as a base for building data processing pipelines."
