#!/bin/bash

echo "Scanning all container images in the cluster..."

# Get all unique images from all namespaces
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u > cluster-images.txt

# Scan each image
while IFS= read -r image; do
    echo "Scanning image: $image"
    trivy image --severity HIGH,CRITICAL --quiet "$image"
    echo "---"
done < cluster-images.txt

rm cluster-images.txt
