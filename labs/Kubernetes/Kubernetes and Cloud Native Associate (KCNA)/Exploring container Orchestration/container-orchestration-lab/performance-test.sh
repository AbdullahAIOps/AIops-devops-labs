#!/bin/bash

echo "Performance Impact Analysis"
echo "=========================="

# Test response times
echo "1. Response Time Analysis:"
for port in {9001..9005}; do
    echo "Testing port $port:"
    time curl -s http://localhost:$port > /dev/null
done

# Test concurrent requests
echo -e "\n2. Concurrent Request Handling:"
echo "Sending 50 concurrent requests to load balancer..."
time for i in {1..50}; do
    curl -s http://localhost > /dev/null &
done
wait

# Resource utilization during load
echo -e "\n3. Resource Utilization:"
docker stats --no-stream | grep web-app-instance
