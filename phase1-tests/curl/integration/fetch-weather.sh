#!/bin/sh
# Simple application that fetches weather data from wttr.in API
# Demonstrates using Hummingbird curl image as base for real application

set -e

# Configuration
LOCATION="${1:-NewYork}"
API_URL="https://wttr.in/${LOCATION}?format=3"

echo "==================================="
echo "Weather Data Fetcher"
echo "==================================="
echo ""
echo "Fetching weather for: ${LOCATION}"
echo "API: ${API_URL}"
echo ""

# Fetch weather data using curl (skip cert verification for minimal image)
WEATHER=$(curl -k -s "${API_URL}")

# Check if we got data
if [ -z "$WEATHER" ]; then
    echo "ERROR: Failed to fetch weather data"
    exit 1
fi

# Display result
echo "Current Weather:"
echo "  ${WEATHER}"
echo ""

# Fetch additional data - current IP info
echo "Fetching IP information..."
IP_DATA=$(curl -k -s https://httpbin.org/ip)

if [ -n "$IP_DATA" ]; then
    echo "IP Data:"
    echo "  ${IP_DATA}"
else
    echo "WARNING: Could not fetch IP data"
fi

echo ""
echo "==================================="
echo "Application completed successfully"
echo "==================================="

exit 0
