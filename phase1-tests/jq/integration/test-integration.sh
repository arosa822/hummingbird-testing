#!/bin/bash
# Integration test for Hummingbird jq image
# Tests the image as a drop-in replacement in a real data processing pipeline
#
# Approach: The Hummingbird jq image is used UNTOUCHED — no custom
# Dockerfile, no modifications. JSON data files are volume-mounted
# and jq processes them directly, just like you would in a CI/CD
# pipeline or data processing workflow.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

TEST_ENGINE="${TEST_ENGINE:-podman}"
# Detect compose command: "docker compose" (plugin) vs "docker-compose" / "podman-compose"
if [ "${TEST_ENGINE}" = "docker" ] && docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="${TEST_ENGINE}-compose"
fi
JQ_RUN="${COMPOSE_CMD} run --rm jq"

echo "=========================================="
echo "jq Integration Test (compose-based)"
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo "[CLEANUP] Tearing down services..."
    ${COMPOSE_CMD} down --volumes --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Extract active users
echo "[TEST 1] Extract active users from JSON data"
echo "Command: ${JQ_RUN} '.[] | select(.active == true) | {name, email}' /data/users.json"

OUTPUT=$(${JQ_RUN} '.[] | select(.active == true) | {name, email}' /data/users.json 2>&1)

if echo "$OUTPUT" | grep -q "Alice Johnson"; then
    echo "✓ PASSED - Active user filtering works"
else
    echo "✗ FAILED - User filtering failed"
    echo "Output: $OUTPUT"
    exit 1
fi
echo ""

# Test 2: Calculate average age of active users
echo "[TEST 2] Calculate average age of active users"
echo "Command: ${JQ_RUN} '[.[] | select(.active == true) | .age] | add / length' /data/users.json"

AVG_OUTPUT=$(${JQ_RUN} '[.[] | select(.active == true) | .age] | add / length' /data/users.json 2>&1)

if echo "$AVG_OUTPUT" | grep -qE '[0-9]+'; then
    echo "✓ PASSED - Statistical calculations work"
    echo "Average Age: $(echo "$AVG_OUTPUT" | tail -1)"
else
    echo "✗ FAILED - Statistical calculations failed"
    echo "Output: $AVG_OUTPUT"
    exit 1
fi
echo ""

# Test 3: Sort and rank — find top spenders
echo "[TEST 3] Find top 3 spenders (sorting and ranking)"
echo "Command: ${JQ_RUN} 'sort_by(.total_spent) | reverse | .[0:3] | .[].name' /data/users.json"

TOP_OUTPUT=$(${JQ_RUN} 'sort_by(.total_spent) | reverse | .[0:3] | .[].name' /data/users.json 2>&1)

if echo "$TOP_OUTPUT" | grep -q "David Wilson"; then
    echo "✓ PASSED - Sorting and ranking work"
    echo "Top Spenders:"
    echo "$TOP_OUTPUT" | tail -3 | sed 's/^/  /'
else
    echo "✗ FAILED - Sorting and ranking failed"
    echo "Output: $TOP_OUTPUT"
    exit 1
fi
echo ""

# Test 4: Group orders by status
echo "[TEST 4] Group orders by status (aggregation)"
echo "Command: ${JQ_RUN} 'group_by(.status) | map({status: .[0].status, count: length})' /data/orders.json"

GROUP_OUTPUT=$(${JQ_RUN} 'group_by(.status) | map({status: .[0].status, count: length})' /data/orders.json 2>&1)

if echo "$GROUP_OUTPUT" | grep -q "completed"; then
    echo "✓ PASSED - Grouping and aggregation work"
else
    echo "✗ FAILED - Grouping and aggregation failed"
    echo "Output: $GROUP_OUTPUT"
    exit 1
fi
echo ""

# Test 5: Transform JSON to CSV
echo "[TEST 5] Transform active users to CSV format"
echo "Command: ${JQ_RUN} -r '.[] | select(.active == true) | [.name, .email, .age, .total_spent] | @csv' /data/users.json"

CSV_OUTPUT=$(${JQ_RUN} -r '.[] | select(.active == true) | [.name, .email, .age, .total_spent] | @csv' /data/users.json 2>&1)

if echo "$CSV_OUTPUT" | grep -q "alice@example.com"; then
    echo "✓ PASSED - JSON to CSV transformation works"
    echo "CSV Output:"
    echo "$CSV_OUTPUT" | tail -5 | sed 's/^/  /'
else
    echo "✗ FAILED - Format transformation failed"
    echo "Output: $CSV_OUTPUT"
    exit 1
fi
echo ""

# Test 6: Generate summary report
echo "[TEST 6] Generate summary report (complex aggregation)"
echo "Command: ${JQ_RUN} '{total_users: length, active_users: ...}' /data/users.json"

SUMMARY_OUTPUT=$(${JQ_RUN} '{total_users: length, active_users: [.[] | select(.active == true)] | length, total_revenue: [.[] | .total_spent] | add}' /data/users.json 2>&1)

if echo "$SUMMARY_OUTPUT" | grep -q "total_users"; then
    echo "✓ PASSED - Summary report generation works"
    echo "Summary:"
    echo "$SUMMARY_OUTPUT" | tail -5 | sed 's/^/  /'
else
    echo "✗ FAILED - Summary report generation failed"
    echo "Output: $SUMMARY_OUTPUT"
    exit 1
fi
echo ""

echo "=========================================="
echo "All integration tests PASSED!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ Hummingbird jq used as drop-in replacement (untouched image)"
echo "  ✓ Data filtering and selection work"
echo "  ✓ Statistical calculations work"
echo "  ✓ Sorting and ranking work"
echo "  ✓ Grouping and aggregation work"
echo "  ✓ Format transformation (JSON to CSV) works"
echo "  ✓ Complex report generation works"
echo ""
echo "This validates that Hummingbird jq can replace"
echo "mainstream jq images in data processing pipelines."
