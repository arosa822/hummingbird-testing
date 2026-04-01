# Phase 1 Test: nginx

## Test Strategy

This test validates that the Hummingbird nginx image can serve web content as a running service.

## Tests Included

### Test 1: Container Startup
- **What it does**: Starts nginx container in detached mode on port 8080
- **Why**: Verifies the container can start and run as a service
- **Pass criteria**: Container is running after startup

### Test 2: Content Serving
- **What it does**: Makes HTTP request to nginx and checks response
- **Why**: Validates nginx is actually serving content
- **Pass criteria**: Response contains expected content (nginx welcome page)

### Test 3: HTTP Status Code
- **What it does**: Verifies HTTP 200 OK response
- **Why**: Confirms nginx is responding correctly
- **Pass criteria**: Returns HTTP 200

### Test 4: Error Log Check
- **What it does**: Inspects container logs for critical errors
- **Why**: Ensures nginx started cleanly without errors
- **Pass criteria**: No critical errors in logs (warnings allowed)

## Running Tests

```bash
# Make script executable
chmod +x test.sh

# Run tests with podman (default)
./test.sh

# Run tests with docker
TEST_ENGINE=docker ./test.sh
```

**Note**: Tests automatically clean up the container when complete.

## Files

- `Dockerfile` - Extends nginx image with custom test HTML page
- `test.sh` - Automated test script with container lifecycle management
- `test-nginx.md` - Original comprehensive test plan
- `README.md` - This file

## Success Criteria

All 4 tests must pass for Phase 1 validation.
