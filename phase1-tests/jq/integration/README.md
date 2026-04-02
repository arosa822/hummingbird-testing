# jq Integration Test

## Purpose

Validates that the Hummingbird jq image can be used to build real data processing pipelines for JSON manipulation and transformation.

## Application

**JSON Data Processing Pipeline** - Demonstrates comprehensive JSON operations:
- Data filtering and selection
- Statistical calculations
- Sorting and ranking
- Grouping and aggregation
- Data joining across files
- Format transformation (JSON to CSV)
- Summary report generation

## Files

- `Dockerfile` - Builds pipeline using jq image as base
- `process-data.sh` - Data processing pipeline script
- `data/users.json` - Sample user data
- `data/orders.json` - Sample order data
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

1. **Data Filtering** - Select active users with conditional logic
2. **Statistical Calculations** - Calculate average age
3. **Sorting & Ranking** - Find top 3 spenders
4. **Grouping & Aggregation** - Count orders by status
5. **Data Joining** - Combine data from multiple JSON files
6. **Format Transformation** - Convert JSON to CSV
7. **Summary Reports** - Generate aggregate statistics

## Sample Operations

### Filter Active Users
```bash
jq '.[] | select(.active == true) | {name, email}' users.json
```

### Calculate Average
```bash
jq '[.[] | select(.active == true) | .age] | add / length' users.json
```

### Sort and Rank
```bash
jq 'sort_by(.total_spent) | reverse | .[0:3]' users.json
```

### Group and Count
```bash
jq 'group_by(.status) | map({status: .[0].status, count: length})' orders.json
```

## Running the Test

```bash
cd phase1-tests/jq/integration
chmod +x test-integration.sh process-data.sh
./test-integration.sh
```

## Real-World Relevance

This test validates that the jq image is suitable for:
- ETL (Extract, Transform, Load) pipelines
- Log processing and analysis
- API response transformation
- Configuration file manipulation
- Data migration scripts
- Report generation
- CI/CD data processing

## Cleanup

The test automatically removes the built image after completion.
