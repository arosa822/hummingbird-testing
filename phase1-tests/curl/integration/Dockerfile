# Integration Test: API Data Fetcher
# Builds a simple application that fetches and processes API data using curl

FROM quay.io/hummingbird/curl:latest

USER 0

# Create app directory and script
RUN mkdir -p /app
WORKDIR /app

# Copy our application script
COPY fetch-weather.sh /app/
RUN chmod +x /app/fetch-weather.sh

# Switch back to non-root user
USER 1001

# Run the application
ENTRYPOINT ["/app/fetch-weather.sh"]
