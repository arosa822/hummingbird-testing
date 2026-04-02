# Node.js Integration Test

## Purpose

Validates that the Hummingbird Node.js image can be used to build production-ready web applications with npm dependencies (Express.js).

## Application

**User Management REST API** - A full CRUD REST API built with Express.js:
- Health check endpoint
- Create, read, update, delete users
- JSON request/response handling
- In-memory data storage
- Proper HTTP status codes
- Error handling middleware

## Files

- `Dockerfile` - Builds Express app using Node.js image as base
- `package.json` - npm dependencies (Express.js)
- `server.js` - Express.js REST API application
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

### Test 1: Build with npm Dependencies
- Can we install npm packages (Express.js)?
- Does `npm install` work correctly?

### Test 2: Application Startup
- Does the Express server start successfully?
- Can it bind to port 8080?

### Test 3: Health Check
- Is the root endpoint accessible?
- Does it return proper JSON with Node version?

### Test 4-8: Full CRUD Operations
- **Create** - POST /api/users
- **Read (All)** - GET /api/users
- **Read (One)** - GET /api/users/:id
- **Update** - PUT /api/users/:id
- **Delete** - DELETE /api/users/:id

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Health check |
| GET | /api/users | Get all users |
| POST | /api/users | Create new user |
| GET | /api/users/:id | Get specific user |
| PUT | /api/users/:id | Update user |
| DELETE | /api/users/:id | Delete user |

## Running the Test

```bash
# Navigate to integration directory
cd phase1-tests/nodejs-22/integration

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
Node.js Integration Test
==========================================

[TEST 1] Build Express API using Hummingbird Node.js as base
✓ PASSED - Express application image built successfully

[TEST 2] Start Express API server
✓ PASSED - Express server started successfully

[TEST 3] Test health check endpoint (GET /)
✓ PASSED - Health check endpoint working
Response: healthy

[TEST 4] Create user via API (POST /api/users)
✓ PASSED - User created successfully
Created user ID: 1

[TEST 5] Retrieve all users (GET /api/users)
✓ PASSED - Retrieved users successfully
Total users: 1

[TEST 6] Retrieve specific user (GET /api/users/1)
✓ PASSED - Retrieved specific user successfully

[TEST 7] Update user (PUT /api/users/1)
✓ PASSED - User updated successfully

[TEST 8] Delete user (DELETE /api/users/1)
✓ PASSED - User deleted successfully

==========================================
All integration tests PASSED!
==========================================
```

## Real-World Relevance

This test validates that the Node.js image is suitable for:
- REST API services
- Web applications
- Microservices
- Backend services
- Real-time applications

## Technical Details

**Dependencies Tested:**
- Express.js 4.18.2 (web framework)
- npm package installation
- Node.js 22.x compatibility

**Features Demonstrated:**
- HTTP server operation
- JSON parsing (express.json middleware)
- Route handling
- HTTP methods (GET, POST, PUT, DELETE)
- Error handling (404s, 400s, 500s)
- Non-root user execution
- Environment configuration

## Cleanup

The test automatically:
- Stops the container
- Removes the container
- Removes the built image
