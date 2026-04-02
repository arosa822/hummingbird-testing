# Python Integration Test

## Purpose

Validates that the Hummingbird Python image can be used to build production-ready web applications with external dependencies (Flask).

## Application

**Task Manager REST API** - A full CRUD REST API built with Flask:
- Health check endpoint
- Create, read, update, delete tasks
- JSON request/response handling
- In-memory data storage
- Proper HTTP status codes

## Files

- `Dockerfile` - Builds Flask app using Python image as base
- `app.py` - Flask REST API application
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

### Test 1: Build with Dependencies
- Can we install pip packages (Flask)?
- Does the build process handle dependencies correctly?

### Test 2: Application Startup
- Does the Flask server start successfully?
- Can it bind to port 8080?

### Test 3: Health Check
- Is the root endpoint accessible?
- Does it return proper JSON?

### Test 4-8: Full CRUD Operations
- **Create** - POST /api/tasks
- **Read (All)** - GET /api/tasks
- **Read (One)** - GET /api/tasks/:id
- **Update** - PUT /api/tasks/:id
- **Delete** - DELETE /api/tasks/:id

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Health check |
| GET | /api/tasks | Get all tasks |
| POST | /api/tasks | Create new task |
| GET | /api/tasks/:id | Get specific task |
| PUT | /api/tasks/:id | Update task |
| DELETE | /api/tasks/:id | Delete task |

## Running the Test

```bash
# Navigate to integration directory
cd phase1-tests/python-3-13/integration

# Make test script executable
chmod +x test-integration.sh

# Run integration tests
./test-integration.sh

# Or with docker
TEST_ENGINE=docker ./test-integration.sh
```

## Expected Output

```
==========================================
Python Integration Test
==========================================

[TEST 1] Build Flask API using Hummingbird Python as base
✓ PASSED - Flask application image built successfully

[TEST 2] Start Flask API server
✓ PASSED - Flask server started successfully

[TEST 3] Test health check endpoint (GET /)
✓ PASSED - Health check endpoint working
Response: healthy

[TEST 4] Create task via API (POST /api/tasks)
✓ PASSED - Task created successfully
Created task ID: 1

[TEST 5] Retrieve all tasks (GET /api/tasks)
✓ PASSED - Retrieved tasks successfully
Total tasks: 1

[TEST 6] Retrieve specific task (GET /api/tasks/1)
✓ PASSED - Retrieved specific task successfully

[TEST 7] Update task (PUT /api/tasks/1)
✓ PASSED - Task updated successfully

[TEST 8] Delete task (DELETE /api/tasks/1)
✓ PASSED - Task deleted successfully

==========================================
All integration tests PASSED!
==========================================
```

## Real-World Relevance

This test validates that the Python image is suitable for:
- REST API services
- Web applications
- Microservices
- Backend services
- Data processing APIs

## Technical Details

**Dependencies Tested:**
- Flask 3.0.0 (web framework)
- pip package installation
- Python 3.13 compatibility

**Features Demonstrated:**
- HTTP server operation
- JSON handling
- Route handling
- HTTP methods (GET, POST, PUT, DELETE)
- Error handling (404s, 400s)
- Non-root user execution

## Cleanup

The test automatically:
- Stops the container
- Removes the container
- Removes the built image
