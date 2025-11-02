#!/bin/bash

echo "=== Ingress Testing Script ==="
echo "Testing HTTP/HTTPS routing and SSL termination"
echo

# Test HTTP redirect to HTTPS
echo "1. Testing HTTP to HTTPS redirect:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}, Redirect URL: %{redirect_url}\n" http://myapps.local/app1
echo

# Test HTTPS app1
echo "2. Testing HTTPS app1 path:"
curl -k -s https://myapps.local/app1 | grep -o "<title>.*</title>"
echo

# Test HTTPS app2
echo "3. Testing HTTPS app2 path:"
curl -k -s https://myapps.local/app2 | grep -o "<title>.*</title>"
echo

# Test API subdomain
echo "4. Testing API subdomain:"
curl -k -s https://api.myapps.local/ | grep -o "<title>.*</title>"
echo

# Test SSL certificate
echo "5. Testing SSL certificate:"
echo | openssl s_client -servername myapps.local -connect $(minikube ip):443 2>/dev/null | openssl x509 -noout -subject
echo

# Test custom headers
echo "6. Testing custom headers:"
curl -k -s -I https://myapps.local/app1 | grep "X-Served-By"
curl -k -s -I https://myapps.local/app1 | grep "X-App-Version"
echo

echo "=== Testing Complete ==="
