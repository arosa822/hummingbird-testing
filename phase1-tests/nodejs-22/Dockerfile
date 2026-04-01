# Phase 1 Test: nodejs-22 image
# Purpose: Verify Hummingbird Node.js image can execute JavaScript code

FROM quay.io/hummingbird/nodejs-22:latest

# Create a simple test Node.js script
USER 0
WORKDIR /app
COPY test_script.js /app/
RUN chown -R 1001:1001 /app
USER 1001

# The image already has node configured
CMD ["node", "test_script.js"]
