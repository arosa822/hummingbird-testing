# Phase 1 Test: python-3-13 image
# Purpose: Verify Hummingbird python image can execute Python code

FROM quay.io/hummingbird/python:3.13

# Create a simple test Python script
USER 0
WORKDIR /app
COPY test_script.py /app/
RUN chown -R 1001:1001 /app
USER 1001

# The image already has python3 configured
CMD ["python3", "test_script.py"]
