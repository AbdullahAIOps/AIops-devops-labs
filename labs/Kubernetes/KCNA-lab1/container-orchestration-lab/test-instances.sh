#!/bin/bash

echo "Testing all application instances..."
echo "=================================="

for port in {9001..9005}; do
    echo "Testing instance on port $port:"
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port)
    if [ $response -eq 200 ]; then
        echo "✓ Port $port: OK"
    else
        echo "✗ Port $port: Failed (HTTP $response)"
    fi
done
