# Node.js Integration Test

## Purpose

Validates that the Hummingbird Node.js image works as a **drop-in replacement** for mainstream Node.js images for running production web applications. The image is used completely untouched — no custom Dockerfile, no modifications.

## Approach

Uses `podman-compose` with a two-service pattern:
1. **Builder init service** — uses a mainstream Node.js image to `npm install` Express into a shared volume
2. **Hummingbird Node.js service** — runs the Express app with the app code and pre-installed deps volume-mounted

This mirrors real deployment patterns where dependency layers are pre-built separately from the runtime image.

## Application

**User Management REST API** — a full CRUD REST API built with Express.js.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Health check |
| GET | /api/users | Get all users |
| POST | /api/users | Create new user |
| GET | /api/users/:id | Get specific user |
| PUT | /api/users/:id | Update user |
| DELETE | /api/users/:id | Delete user |

## Files

- `compose.yaml` - Defines builder + app services with shared volume
- `package.json` - npm dependencies (Express.js)
- `server.js` - Express.js REST API application
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## Running the Test

```bash
cd phase1-tests/nodejs-22/integration
bash test-integration.sh

# Or with docker
TEST_ENGINE=docker bash test-integration.sh
```

## Real-World Relevance

This test validates that the Hummingbird Node.js image can replace mainstream Node.js images for:
- REST API services and microservices
- Web applications (Express, Fastify, Next.js)
- Backend services with npm dependencies
