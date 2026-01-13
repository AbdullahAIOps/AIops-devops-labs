#!/bin/bash

echo "Manual Cleanup Process"
echo "====================="

# Stop all web-app containers
echo "1. Stopping all application containers..."
docker ps | grep web-app | awk '{print $1}' | xargs -r docker stop

# Remove all web-app containers
echo "2. Removing all application containers..."
docker ps -a | grep web-app | awk '{print $1}' | xargs -r docker rm

# Remove unused images (optional)
echo "3. Cleaning up unused images..."
docker image prune -f

# Stop nginx load balancer
echo "4. Stopping load balancer..."
sudo systemctl stop nginx

# Show remaining containers
echo "5. Remaining containers:"
docker ps

echo "Cleanup complete!"
echo "Note: In orchestration, this would be: 'kubectl delete deployment myapp'"
