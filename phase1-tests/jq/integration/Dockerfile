# Integration Test: JSON Data Processing Pipeline
# Builds a data processing application using Hummingbird jq as base

FROM quay.io/hummingbird/jq:latest

USER 0

# Create app directory
WORKDIR /app

# Copy data files and processing script
COPY data/ /app/data/
COPY process-data.sh /app/
RUN chmod +x /app/process-data.sh

# Set ownership
RUN chown -R 1001:1001 /app

USER 1001

# Run the data processing pipeline
ENTRYPOINT ["/app/process-data.sh"]
