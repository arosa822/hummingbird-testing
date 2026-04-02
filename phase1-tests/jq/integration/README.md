# jq Integration Test

## Purpose

Validates that the Hummingbird jq image works as a **drop-in replacement** for mainstream jq images in data processing pipelines. The image is used completely untouched — no custom Dockerfile, no modifications.

## Approach

Uses `podman-compose` to run the Hummingbird jq image with JSON data files volume-mounted. The tests exercise real-world data processing operations (filtering, aggregation, transformation) against the mounted data.

## Files

- `compose.yaml` - Defines the jq service with volume-mounted data
- `data/users.json` - Sample user dataset
- `data/orders.json` - Sample order dataset
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

1. **Data filtering** - Extract active users from JSON
2. **Statistical calculations** - Compute averages across records
3. **Sorting and ranking** - Find top spenders
4. **Grouping and aggregation** - Count orders by status
5. **Format transformation** - Convert JSON to CSV
6. **Complex report generation** - Build summary reports

## Running the Test

```bash
cd phase1-tests/jq/integration
bash test-integration.sh

# Or with docker
TEST_ENGINE=docker bash test-integration.sh
```

## Real-World Relevance

This test validates that the Hummingbird jq image can replace mainstream jq images for:
- CI/CD data processing steps
- Log analysis pipelines
- ETL batch jobs
- Configuration file transformation
