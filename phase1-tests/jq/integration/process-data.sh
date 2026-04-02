#!/bin/sh
# JSON Data Processing Pipeline
# Demonstrates using jq for real-world data transformation tasks

set -e

echo "=========================================="
echo "JSON Data Processing Pipeline"
echo "=========================================="
echo ""

# Task 1: Extract active users
echo "[TASK 1] Extract active users"
echo "Command: jq '.[] | select(.active == true) | {name, email}' data/users.json"
echo ""

ACTIVE_USERS=$(cat /app/data/users.json | jq '.[] | select(.active == true) | {name, email}')
echo "Active Users:"
echo "$ACTIVE_USERS"
echo ""

# Task 2: Calculate average age of active users
echo "[TASK 2] Calculate average age of active users"
echo "Command: jq '[.[] | select(.active == true) | .age] | add / length' data/users.json"
echo ""

AVG_AGE=$(cat /app/data/users.json | jq '[.[] | select(.active == true) | .age] | add / length')
echo "Average Age: $AVG_AGE years"
echo ""

# Task 3: Find top spenders
echo "[TASK 3] Find top 3 spenders"
echo "Command: jq 'sort_by(.total_spent) | reverse | .[0:3] | .[] | {name, total_spent}' data/users.json"
echo ""

TOP_SPENDERS=$(cat /app/data/users.json | jq 'sort_by(.total_spent) | reverse | .[0:3] | .[] | {name, total_spent}')
echo "Top Spenders:"
echo "$TOP_SPENDERS"
echo ""

# Task 4: Count orders by status
echo "[TASK 4] Count orders by status"
echo "Command: jq 'group_by(.status) | map({status: .[0].status, count: length})' data/orders.json"
echo ""

ORDER_STATUS=$(cat /app/data/orders.json | jq 'group_by(.status) | map({status: .[0].status, count: length})')
echo "Order Status Summary:"
echo "$ORDER_STATUS"
echo ""

# Task 5: Join users with their orders
echo "[TASK 5] Join users with their order count"
echo "Complex transformation combining two data sources"
echo ""

# This demonstrates more complex jq operations
JOINED_DATA=$(cat /app/data/users.json | jq --slurpfile orders /app/data/orders.json '
  .[] | select(.active == true) |
  {
    name,
    email,
    purchases,
    order_count: ([$orders[0][] | select(.user_id == .id)] | length)
  }
')
echo "User Order Summary (Active Users):"
echo "$JOINED_DATA"
echo ""

# Task 6: Transform to CSV format
echo "[TASK 6] Transform active users to CSV format"
echo "Command: jq -r '.[] | select(.active == true) | [.name, .email, .age, .total_spent] | @csv' data/users.json"
echo ""

CSV_DATA=$(cat /app/data/users.json | jq -r '.[] | select(.active == true) | [.name, .email, .age, .total_spent] | @csv')
echo "CSV Output:"
echo "name,email,age,total_spent"
echo "$CSV_DATA"
echo ""

# Task 7: Create summary report
echo "[TASK 7] Generate summary report"
echo ""

SUMMARY=$(cat /app/data/users.json | jq '{
  total_users: length,
  active_users: [.[] | select(.active == true)] | length,
  total_revenue: [.[] | .total_spent] | add,
  average_purchase_value: ([.[] | .total_spent] | add) / ([.[] | .purchases] | add)
}')

echo "Summary Report:"
echo "$SUMMARY"
echo ""

echo "=========================================="
echo "Data Processing Complete!"
echo "=========================================="
echo ""
echo "Processed:"
echo "  ✓ User data filtering and selection"
echo "  ✓ Statistical calculations"
echo "  ✓ Sorting and ranking"
echo "  ✓ Grouping and aggregation"
echo "  ✓ Data joining across files"
echo "  ✓ Format transformation (JSON to CSV)"
echo "  ✓ Summary report generation"

exit 0
