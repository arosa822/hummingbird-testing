# Phase 1 Test: curl

## Test Strategy

This test validates that the Hummingbird curl image can perform basic HTTP/HTTPS operations.

## Tests Included

### Test 1: Basic HTTP GET
- **What it does**: Makes a simple HTTP GET request to example.com
- **Why**: Verifies the most basic curl functionality works
- **Pass criteria**: Returns HTTP 200 status code

### Test 2: Version Check
- **What it does**: Runs `curl --version` to verify the binary is accessible
- **Why**: Confirms curl is properly installed and executable
- **Pass criteria**: Output contains "curl" string

### Test 3: HTTPS/TLS Support
- **What it does**: Makes an HTTPS request to google.com
- **Why**: Verifies SSL/TLS certificates and HTTPS functionality work
- **Pass criteria**: Returns HTTP 200/301/302 (accepts redirects)

### Test 4: JSON API Response
- **What it does**: Fetches JSON data from httpbin.org/json endpoint
- **Why**: Validates curl can handle real-world API responses
- **Pass criteria**: Response contains expected JSON content

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

- `Dockerfile` - Simple demonstration of using curl image as a base
- `test.sh` - Automated test script
- `test-curl.md` - Original comprehensive test plan
- `README.md` - This file

## Success Criteria

All 4 tests must pass for Phase 1 validation.
