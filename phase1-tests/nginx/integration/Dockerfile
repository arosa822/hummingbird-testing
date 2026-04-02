# Integration Test: Static Website with Custom Configuration
# Builds a static website using Hummingbird nginx as base

FROM quay.io/hummingbird/nginx:latest

USER 0

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create website directory
RUN mkdir -p /usr/share/nginx/html

# Copy static website files
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Set permissions
RUN chown -R 1001:1001 /usr/share/nginx/html

USER 1001

# Expose port 8080 (non-root)
EXPOSE 8080

# nginx is already configured as CMD in base image
