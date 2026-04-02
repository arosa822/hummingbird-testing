# nginx Integration Test

## Purpose

Validates that the Hummingbird nginx image can be used to serve real static websites with custom configuration.

## Application

**Static Website** - A complete single-page application with:
- HTML, CSS, and JavaScript files
- Custom nginx configuration
- Health check endpoint
- JSON API endpoint
- Security headers
- Gzip compression

## Files

- `Dockerfile` - Builds website using nginx image as base
- `nginx.conf` - Custom nginx configuration
- `index.html` - Main website page
- `style.css` - Stylesheet
- `app.js` - JavaScript for interactive features
- `test-integration.sh` - Automated integration tests
- `README.md` - This file

## What It Tests

1. **Build with Custom Config** - Can we customize nginx.conf?
2. **Server Startup** - Does nginx start and serve files?
3. **HTML Serving** - Can it serve the main page?
4. **CSS Serving** - Are stylesheets served correctly?
5. **JavaScript Serving** - Is JavaScript delivered?
6. **Health Endpoint** - Custom health check works?
7. **JSON API** - Can nginx return JSON responses?
8. **Gzip Compression** - Is compression enabled?

## Running the Test

```bash
cd phase1-tests/nginx/integration
chmod +x test-integration.sh
./test-integration.sh
```

## Real-World Relevance

This test validates that the nginx image is suitable for:
- Static website hosting
- Single-page applications (SPAs)
- Documentation sites
- Landing pages
- Asset serving (CSS, JS, images)

## Configuration Features

- Non-root port (8080)
- Security headers (X-Frame-Options, X-XSS-Protection)
- Gzip compression
- Custom error pages
- Health check endpoint
- JSON API endpoints

## Cleanup

The test automatically removes all resources after completion.
