# Phase 1 Test: jq

## Test Strategy

This test validates that the Hummingbird jq image can process JSON data correctly.

## Tests Included

### Test 1: Extract Simple Field
- **What it does**: Extracts `.name` from `{"name":"test"}`
- **Why**: Verifies basic JSON field extraction works
- **Pass criteria**: Returns `"test"`

### Test 2: Version Check
- **What it does**: Runs `jq --version` to verify the binary is accessible
- **Why**: Confirms jq is properly installed and executable
- **Pass criteria**: Output contains "jq-" version string

### Test 3: Array Processing
- **What it does**: Accesses second element of array `[1,2,3]` using `.[1]`
- **Why**: Validates array indexing functionality
- **Pass criteria**: Returns `2`

### Test 4: Nested JSON Filtering
- **What it does**: Filters nested structure with `.users[0].name`
- **Why**: Tests real-world JSON processing scenarios
- **Pass criteria**: Correctly extracts `"alice"` from nested object

## Running Tests

```bash
# Make script executable
chmod +x test.sh

# Run tests with podman (default)
./test.sh

# Run tests with docker
TEST_ENGINE=docker ./test.sh
```

## Files

- `Dockerfile` - Simple demonstration of using jq image as a base
- `test.sh` - Automated test script
- `test-jq.md` - Original comprehensive test plan
- `README.md` - This file

## Success Criteria

All 4 tests must pass for Phase 1 validation.
