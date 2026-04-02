# nginx Integration Test

## Purpose

Validates that the Hummingbird nginx image works as a **drop-in replacement** for mainstream nginx images for hosting production websites. The image is used completely untouched — no custom Dockerfile, no modifications.

## Approach

Uses `podman-compose` to run the Hummingbird nginx image with custom configuration and static files volume-mounted, just like you would deploy nginx in production with Kubernetes ConfigMaps or Docker Compose volumes.

## Files

- `compose.yaml` - Defines the nginx service with volume-mounted config and content
- `nginx.conf` - Custom nginx configuration (non-root port, gzip, security headers)
- `index.html` - Main website page
- `style.css` - Stylesheet
- `app.js` - JavaScript for interactive features
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

1. **Server startup** - nginx starts and serves content
2. **HTTP status** - Returns 200 for valid requests
3. **CSS serving** - Stylesheets delivered correctly
4. **JavaScript serving** - JS files delivered correctly
5. **Health endpoint** - Custom `/health` endpoint works
6. **JSON API** - Custom `/api/status` endpoint returns JSON
7. **Gzip compression** - Compression is enabled

## Running the Test

```bash
cd phase1-tests/nginx/integration
bash test-integration.sh

# Or with docker
TEST_ENGINE=docker bash test-integration.sh
```

## Real-World Relevance

This test validates that the Hummingbird nginx image can replace mainstream nginx images for:
- Static website hosting
- Single-page applications (SPAs)
- Reverse proxy deployments
- API gateway configurations
