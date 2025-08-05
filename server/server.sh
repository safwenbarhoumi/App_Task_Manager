#!/bin/bash
# server.sh - Simple script to serve Flutter web build on port 9000

WEB_BUILD_DIR="/app/build/web"
PORT=9000

# Check if web build directory exists
if [ ! -d "$WEB_BUILD_DIR" ]; then
  echo "Error: Web build directory not found at $WEB_BUILD_DIR"
  exit 1
fi

echo "Serving Flutter web build from $WEB_BUILD_DIR on port $PORT ..."
cd $WEB_BUILD_DIR

# Use Python's HTTP server (compatible with Python 3)
python3 -m http.server $PORT