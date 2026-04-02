# Integration Test: Express.js REST API
# Builds a REST API application using Hummingbird Node.js as base

FROM quay.io/hummingbird/nodejs:22

USER 0

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json /app/

# Install dependencies
RUN npm install --production --no-audit

# Copy application code
COPY server.js /app/

# Create non-root user
RUN chown -R 1001:1001 /app

USER 1001

# Expose port
EXPOSE 8080

# Run the application
CMD ["node", "server.js"]
