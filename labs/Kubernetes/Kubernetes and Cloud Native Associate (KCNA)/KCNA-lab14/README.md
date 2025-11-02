# Lab 14: Advanced HTTP/S Routing with Ingress

## Overview
This lab walks through advanced concepts of HTTP and HTTPS routing using Kubernetes Ingress.  
By the end of this lab, you’ll have deployed multiple web applications, configured secure traffic management, and implemented path-based routing with TLS termination.

---

## 🎯 Objectives
By completing this lab, you will be able to:

- Deploy multiple applications in a Kubernetes cluster  
- Configure Ingress controllers for HTTP/S traffic management  
- Implement path-based routing using Ingress resources  
- Secure applications using TLS certificates and SSL termination  
- Verify and troubleshoot Ingress routing rules  
- Understand how Services, Ingress, and external traffic interact  

---

## 🧠 Prerequisites
Before starting, you should be familiar with:

- Basic Kubernetes concepts (Pods, Services, Deployments)  
- YAML configuration files  
- HTTP/HTTPS protocols and routing concepts  
- Basic command-line interface usage  
- DNS and domain name basics  

---

## ☁️ Ready-to-Use Environment
Al Nafi provides pre-configured cloud machines for this lab.  
Your lab environment includes:

- **Ubuntu 20.04 LTS** with `kubectl` pre-installed  
- **Minikube** cluster ready for use  
- **NGINX Ingress Controller** available for installation  
- All required tools and dependencies pre-installed  

---

## 🧩 Lab Tasks

### Task 1: Environment Setup

#### 1.1 Verify Kubernetes Cluster
```bash
kubectl cluster-info
kubectl get nodes
minikube status
If Minikube isn’t running:

bash
Copy code
minikube start --driver=docker
minikube addons enable ingress
1.2 Verify Ingress Controller
bash
Copy code
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
If not installed:

bash
Copy code
minikube addons enable ingress
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
Task 2: Deploy Applications
2.1 Create Namespace
bash
Copy code
kubectl create namespace web-apps
2.2 Deploy Application 1
Create and apply app1-deployment.yaml:

bash
Copy code
kubectl apply -f app1-deployment.yaml
2.3 Deploy Application 2
Create and apply app2-deployment.yaml:

bash
Copy code
kubectl apply -f app2-deployment.yaml
2.4 Verify Deployments
bash
Copy code
kubectl get deployments -n web-apps
kubectl get pods -n web-apps
kubectl get svc -n web-apps
Task 3: Configure Ingress (Path-Based Routing)
3.1 Create Ingress Resource
bash
Copy code
kubectl apply -f ingress-basic.yaml
3.2 Verify Configuration
bash
Copy code
kubectl get ingress -n web-apps
kubectl describe ingress web-apps-ingress -n web-apps
minikube ip
3.3 Configure Local DNS
bash
Copy code
echo "$(minikube ip) myapps.local" | sudo tee -a /etc/hosts
3.4 Test Routing
bash
Copy code
curl -H "Host: myapps.local" http://$(minikube ip)/app1
curl -H "Host: myapps.local" http://$(minikube ip)/app2
Task 4: Secure Ingress with TLS
4.1 Generate Self-Signed Certificate
bash
Copy code
openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -out tls.csr -subj "/CN=myapps.local/O=myapps.local"
openssl x509 -req -days 365 -in tls.csr -signkey tls.key -out tls.crt
4.2 Create TLS Secret
bash
Copy code
kubectl create secret tls myapps-tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  -n web-apps
4.3 Update Ingress with TLS
bash
Copy code
kubectl apply -f ingress-tls.yaml
4.4 Verify HTTPS
bash
Copy code
curl -k https://myapps.local/app1
curl -k https://myapps.local/app2
curl -v http://myapps.local/app1
Task 5: Advanced Routing
5.1 Create Advanced Ingress
bash
Copy code
kubectl apply -f ingress-advanced.yaml
5.2 Update Local DNS
bash
Copy code
echo "$(minikube ip) api.myapps.local" | sudo tee -a /etc/hosts
5.3 Test Advanced Routing
bash
Copy code
curl -k -I https://myapps.local/app1
curl -k -I https://api.myapps.local/
curl -k -I https://myapps.local/app1 | grep "X-Served-By"
5.4 Monitor Ingress Logs
bash
Copy code
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx <ingress-pod-name> --tail=50
Task 6: Verification and Testing
6.1 Automated Testing Script
bash
Copy code
./test-ingress.sh
6.2 Verify Resources
bash
Copy code
kubectl get ingress --all-namespaces
kubectl get ingressclass
kubectl get endpoints -n web-apps
6.3 Performance Testing
bash
Copy code
sudo apt install -y apache2-utils
ab -n 100 -c 10 -k https://myapps.local/app1
🧩 Troubleshooting
1. Ingress Controller Not Ready
bash
Copy code
kubectl get pods -n ingress-nginx
kubectl delete pod -n ingress-nginx -l app.kubernetes.io/component=controller
2. DNS Resolution Issues
bash
Copy code
cat /etc/hosts | grep myapps
nslookup myapps.local
ping myapps.local
3. Certificate Problems
bash
Copy code
kubectl describe secret myapps-tls-secret -n web-apps
openssl x509 -in tls.crt -noout -dates
4. Service Not Accessible
bash
Copy code
kubectl get endpoints -n web-apps
kubectl port-forward -n web-apps svc/app1-service 8080:80
curl http://localhost:8080
🧹 Cleanup
bash
Copy code
kubectl delete ingress --all -n web-apps
kubectl delete -f app1-deployment.yaml
kubectl delete -f app2-deployment.yaml
kubectl delete secret myapps-tls-secret -n web-apps
kubectl delete namespace web-apps
sudo sed -i '/myapps.local/d' /etc/hosts
rm -f tls.* *.yaml test-ingress.sh
🏁 Conclusion
You’ve successfully completed Lab 14: Advanced HTTP/S Routing with Ingress.

Key Takeaways:
Deployed Multiple Applications using Deployments and Services.

Implemented Path-Based Routing for multiple web apps.

Secured Traffic using TLS certificates and HTTPS termination.

Explored Advanced Features like multiple hosts, custom headers, and redirects.

Validated Configuration through automated testing and logs.

Why It Matters:
Ingress controllers are central to modern Kubernetes networking. They:

Provide external access to internal services

Manage routing and SSL termination

Enable load balancing and path rewriting

Simplify multi-app deployments

Real-World Applications:
Microservices and API gateway patterns

Multi-tenant hosting

Blue-Green or Canary deployments

Dev/Test cluster access management
