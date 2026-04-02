# Phase 1 Integration Tests

## Overview

Integration tests validate that Hummingbird container images can be used as base images for building real, production-ready applications - not just running individual commands.

## Philosophy

**Basic Tests** answer: "Can we run this image?"
**Integration Tests** answer: "Can we build real applications with this image?"

This progression validates that Hummingbird images are truly production-ready.

---

## Test Structure

Each image has both **basic** and **integration** tests:

```
phase1-tests/
├── curl/
│   ├── test.sh                      # Basic: Run curl commands
│   └── integration/                 # NEW
│       ├── Dockerfile               # Build real app
│       ├── fetch-weather.sh         # Application code
│       ├── test-integration.sh      # Integration tests
│       └── README.md                # Documentation
├── jq/
│   ├── test.sh                      # Basic: Process JSON
│   └── integration/                 # Data processing pipeline
├── nginx/
│   ├── test.sh                      # Basic: Serve files
│   └── integration/                 # Full static website
├── python-3-13/
│   ├── test.sh                      # Basic: Run Python
│   └── integration/                 # Flask REST API
└── nodejs-22/
    ├── test.sh                      # Basic: Run Node.js
    └── integration/                 # Express REST API
```

---

## Applications Built

### 1. curl - Weather Data Fetcher
**Type:** CLI utility application

**What it does:**
- Fetches weather data from wttr.in API
- Retrieves IP information from httpbin.org
- Accepts custom location parameters
- Demonstrates multi-API integration

**Real-world use case:** API integration scripts, data fetching services, webhook handlers

**Key validation:**
- Can build with curl as base
- Can make multiple HTTP/HTTPS requests
- Can handle parameters and output data

---

### 2. jq - JSON Data Processing Pipeline
**Type:** Data transformation application

**What it does:**
- Filters and selects data
- Performs statistical calculations
- Sorts and ranks records
- Groups and aggregates data
- Joins data from multiple files
- Transforms JSON to CSV
- Generates summary reports

**Real-world use case:** ETL pipelines, log analysis, data migration, report generation

**Key validation:**
- Complex jq operations work
- Multi-file processing works
- Real data transformation scenarios

---

### 3. nginx - Static Website
**Type:** Web hosting application

**What it does:**
- Serves complete HTML/CSS/JavaScript website
- Custom nginx configuration
- Health check endpoint
- JSON API endpoints
- Security headers
- Gzip compression

**Real-world use case:** Static websites, SPAs, documentation sites, landing pages

**Key validation:**
- Custom nginx.conf works
- Serves multiple file types
- Custom endpoints work
- Production configuration features

---

### 4. Python - Flask REST API
**Type:** Web service application

**What it does:**
- Full CRUD REST API (Create, Read, Update, Delete)
- Task management system
- JSON request/response handling
- Error handling
- Health check endpoint

**Real-world use case:** REST APIs, microservices, backend services, data APIs

**Key validation:**
- pip install works (Flask dependency)
- Web framework runs correctly
- All HTTP methods work
- Production-ready service

**API Endpoints:**
- `GET /` - Health check
- `GET /api/tasks` - List all tasks
- `POST /api/tasks` - Create task
- `GET /api/tasks/:id` - Get task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

---

### 5. Node.js - Express REST API
**Type:** Web service application

**What it does:**
- Full CRUD REST API
- User management system
- JSON request/response handling
- Error handling middleware
- Health check endpoint

**Real-world use case:** REST APIs, web applications, microservices, backend services

**Key validation:**
- npm install works (Express dependency)
- Web framework runs correctly
- All HTTP methods work
- Production-ready service

**API Endpoints:**
- `GET /` - Health check
- `GET /api/users` - List all users
- `POST /api/users` - Create user
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

---

## Running Integration Tests

### Single Image

```bash
# Navigate to integration test directory
cd phase1-tests/curl/integration

# Run the integration test
./test-integration.sh

# Or with docker
TEST_ENGINE=docker ./test-integration.sh
```

### All Integration Tests

```bash
# Run all integration tests
cd phase1-tests
./run-all-integration-tests.sh

# With docker
TEST_ENGINE=docker ./run-all-integration-tests.sh
```

---

## What Integration Tests Validate

### 1. Build Process
- Can the image be used as `FROM` base?
- Does the build complete successfully?
- Can we add application code?
- Can we install dependencies (pip, npm)?

### 2. Dependency Management
- **Python:** Can we `pip install` packages?
- **Node.js:** Can we `npm install` packages?
- **nginx:** Can we add custom configuration?
- **curl/jq:** Can we add scripts and data?

### 3. Application Execution
- Does the application start correctly?
- Does it run without errors?
- Can it handle requests/process data?
- Does it complete successfully?

### 4. Production Features
- **Services:** Can they bind to ports?
- **APIs:** Do all endpoints work?
- **Error Handling:** Are errors handled properly?
- **Security:** Do apps run as non-root?

### 5. Real-World Scenarios
- Can we fetch from external APIs? (curl)
- Can we process complex data? (jq)
- Can we serve websites? (nginx)
- Can we handle HTTP requests? (Python, Node.js)

---

## Test Patterns

### CLI Application Pattern (curl, jq)
1. Build image with application script
2. Run container with application
3. Verify output/results
4. Test with parameters
5. Validate completion

### Web Service Pattern (nginx, Python, Node.js)
1. Build image with application
2. Start container (detached mode)
3. Wait for service to start
4. Test endpoints
5. Verify responses
6. Stop and cleanup

---

## Comparison: Basic vs Integration Tests

| Aspect | Basic Tests | Integration Tests |
|--------|-------------|-------------------|
| **Purpose** | Verify image runs | Verify real apps can be built |
| **Complexity** | Simple commands | Full applications |
| **Dependencies** | None | pip, npm packages |
| **Duration** | Seconds | Seconds to minutes |
| **What's tested** | Individual commands | Complete workflows |
| **Example** | `curl --version` | Weather fetcher app |
| **Validation** | Image functionality | Production readiness |

---

## Benefits of Integration Tests

### 1. Production Confidence
- Proves images work for real applications
- Tests actual use cases, not just theory
- Validates dependency installation

### 2. Documentation by Example
- Shows how to use images
- Provides working Dockerfile examples
- Demonstrates best practices

### 3. Regression Prevention
- Catches breaking changes
- Validates full workflow
- Tests image updates

### 4. Pattern Library
- Reusable application templates
- Common use case examples
- Starting point for new projects

---

## Expected Results

When all integration tests pass:

```
==========================================
Integration Test Summary
==========================================
Total Images: 5
Passed: 5
Failed: 0

✅ All integration tests PASSED!

What this validates:
  • Hummingbird images work as base images
  • Real applications can be built on them
  • Dependencies (pip, npm) install correctly
  • Applications run successfully in containers
  • Images are production-ready
```

---

## Extending Integration Tests

### Adding Tests for New Images

1. **Create integration directory:**
   ```bash
   mkdir -p phase1-tests/new-image/integration
   ```

2. **Choose application type:**
   - CLI utility → Use curl/jq pattern
   - Web service → Use Python/Node.js pattern
   - Static files → Use nginx pattern

3. **Create files:**
   - `Dockerfile` - Build the app
   - Application code (script, web app, etc.)
   - `test-integration.sh` - Test the app
   - `README.md` - Document it

4. **Test locally:**
   ```bash
   cd phase1-tests/new-image/integration
   ./test-integration.sh
   ```

5. **Update master script:**
   Add image name to `run-all-integration-tests.sh`

---

## Troubleshooting

### Build Failures

**Issue:** Dockerfile build fails
**Check:**
- Is base image name correct?
- Are files in correct location?
- Do file permissions allow copying?

### Application Failures

**Issue:** Application doesn't run
**Check:**
- Is entrypoint/CMD correct?
- Are scripts executable?
- Is user (1001) set correctly?

### Service Startup Failures

**Issue:** Web service doesn't start
**Check:**
- Is port correct (8080 for non-root)?
- Is sleep duration sufficient?
- Check container logs

### Network Issues

**Issue:** Can't reach external APIs
**Check:**
- Network access available?
- Firewall blocking?
- API endpoints valid?

---

## Best Practices

### 1. Keep Applications Simple
- Focus on validating image capabilities
- Don't overcomplicate the test app
- Use realistic but minimal examples

### 2. Include Cleanup
- Always remove built images
- Stop and remove containers
- Use trap for cleanup on exit

### 3. Clear Output
- Show what's being tested
- Indicate pass/fail clearly
- Include relevant details

### 4. Make Tests Repeatable
- Don't rely on external state
- Generate unique names ($$)
- Clean up after every run

### 5. Document Well
- Explain what the app does
- Show expected output
- Document real-world relevance

---

## Future Enhancements

### Potential Additions

1. **More Complex Apps**
   - Multi-tier applications
   - Database integrations
   - Message queue connections

2. **Performance Tests**
   - Load testing web services
   - Benchmark data processing
   - Measure startup times

3. **Security Tests**
   - Verify non-root execution
   - Check file permissions
   - Validate security headers

4. **Multi-Container Tests**
   - Service communication
   - Network isolation
   - Volume mounting

---

## Summary

Integration tests transform Phase 1 from "verifying images run" to "proving images are production-ready." They provide:

- **Confidence** that images work for real applications
- **Examples** of how to use images correctly
- **Validation** of production scenarios
- **Documentation** through working code

**Status:** All 5 images have integration tests ✅
**Next:** Consider adding integration tests for remaining 39 images
