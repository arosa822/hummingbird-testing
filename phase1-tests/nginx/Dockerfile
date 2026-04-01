# Phase 1 Test: nginx image
# Purpose: Verify Hummingbird nginx image can serve static content

FROM quay.io/hummingbird/nginx:latest

# Create a simple test HTML page
USER 0
RUN echo '<html><body><h1>Hummingbird nginx Test</h1><p>If you see this, nginx is working!</p></body></html>' > /usr/share/nginx/html/index.html
USER 1001

# nginx is already configured to serve from /usr/share/nginx/html
# Default port is 8080 (non-root)
