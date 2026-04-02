# curl Integration Test

## Purpose

Validates that the Hummingbird curl image works as a **drop-in replacement** for mainstream curl images in real service stacks. The image is used completely untouched — no custom Dockerfile, no modifications.

## Approach

Uses `podman-compose` to spin up a target web service, then runs the Hummingbird curl image against it to prove it works in a compose network. Additional tests verify HTTPS and API interactions.

## Files

- `compose.yaml` - Defines the service stack (target + curl)
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

1. **Service-to-service communication** - curl reaches a target service within the compose network
2. **Version check** - `curl --version` works correctly
3. **HTTPS/TLS support** - curl can make secure connections
4. **API fetching** - curl can retrieve JSON from API endpoints

## Running the Test

```bash
cd phase1-tests/curl/integration
bash test-integration.sh

# Or with docker
TEST_ENGINE=docker bash test-integration.sh
```

## Real-World Relevance

This test validates that the Hummingbird curl image can replace mainstream curl images for:
- Sidecar containers in Kubernetes pods
- CI/CD pipeline utilities
- Health check containers
- API automation scripts
