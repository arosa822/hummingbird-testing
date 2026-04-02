# curl Integration Test

## Purpose

Validates that the Hummingbird curl image can be used as a base for building real applications, not just running individual commands.

## Application

**Weather Data Fetcher** - A simple application that:
- Fetches weather data from wttr.in API
- Retrieves IP information from httpbin.org
- Accepts custom location parameters
- Demonstrates multi-API integration

## Files

- `Dockerfile` - Builds the application using curl image as base
- `fetch-weather.sh` - The application script
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

### Test 1: Build Application
- Can we build a Docker image using Hummingbird curl as FROM?
- Does the build process complete without errors?

### Test 2: Run Application (Default)
- Does the application run successfully?
- Can it fetch data from external APIs?
- Does it complete without errors?

### Test 3: Custom Parameters
- Can the application accept runtime parameters?
- Does it properly handle custom locations?

### Test 4: Multiple Data Sources
- Can the application fetch from multiple APIs in one run?
- Does it handle multiple curl commands correctly?

## Running the Test

```bash
# Navigate to integration directory
cd phase1-tests/curl/integration

# Make test script executable
chmod +x test-integration.sh fetch-weather.sh

# Run integration tests
./test-integration.sh

# Or with docker
TEST_ENGINE=docker ./test-integration.sh
```

## Expected Output

```
==========================================
curl Integration Test
==========================================

[TEST 1] Build application using Hummingbird curl as base
✓ PASSED - Application image built successfully

[TEST 2] Run application with default parameters
✓ PASSED - Application ran successfully
Sample output:
Current Weather:
  NewYork: ⛅️  +7°C

[TEST 3] Run application with custom location
✓ PASSED - Application accepts custom parameters

[TEST 4] Verify application fetches from multiple APIs
✓ PASSED - Application successfully fetches from multiple sources

==========================================
All integration tests PASSED!
==========================================

Summary:
  ✓ Built real application using curl image
  ✓ Application runs successfully
  ✓ Accepts custom parameters
  ✓ Fetches data from multiple APIs
```

## Real-World Relevance

This test validates that the curl image is suitable for:
- API integration scripts
- Data fetching services
- Webhook handlers
- Health check monitors
- CI/CD pipeline utilities

## Cleanup

The test automatically removes the built image after completion.
