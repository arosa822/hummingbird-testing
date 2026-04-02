# Integration Test: Simple Flask Web API
# Builds a REST API application using Hummingbird Python as base

FROM quay.io/hummingbird/python:3.13

USER 0

# Install Flask (minimal web framework)
RUN python3 -m pip install --no-cache-dir flask==3.0.0

# Create app directory
WORKDIR /app

# Copy application code
COPY app.py /app/

# Create non-root user for running the app
RUN chown -R 1001:1001 /app

USER 1001

# Expose port
EXPOSE 8080

# Run the Flask app
CMD ["python3", "app.py"]
