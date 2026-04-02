# Python Integration Test

## Purpose

Validates that the Hummingbird Python image works as a **drop-in replacement** for mainstream Python images for running production web applications. The image is used completely untouched — no custom Dockerfile, no modifications.

## Approach

Uses `podman-compose` with a two-service pattern:
1. **Builder init service** — uses a mainstream Python image to `pip install` Flask into a shared volume
2. **Hummingbird Python service** — runs the Flask app with the app code and pre-installed deps volume-mounted

This mirrors real deployment patterns where dependency layers are pre-built separately from the runtime image.

## Application

**Task Manager REST API** — a full CRUD REST API built with Flask.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Health check |
| GET | /api/tasks | Get all tasks |
| POST | /api/tasks | Create new task |
| GET | /api/tasks/:id | Get specific task |
| PUT | /api/tasks/:id | Update task |
| DELETE | /api/tasks/:id | Delete task |

## Files

- `compose.yaml` - Defines builder + app services with shared volume
- `app.py` - Flask REST API application
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## Running the Test

```bash
cd phase1-tests/python-3-13/integration
bash test-integration.sh

# Or with docker
TEST_ENGINE=docker bash test-integration.sh
```

## Real-World Relevance

This test validates that the Hummingbird Python image can replace mainstream Python images for:
- REST API services and microservices
- Web applications (Flask, Django, FastAPI)
- Backend services with pip dependencies
