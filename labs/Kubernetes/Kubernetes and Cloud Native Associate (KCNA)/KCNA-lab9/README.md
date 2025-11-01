# Lab 9: Configuring and Using Kubernetes Services 🌐

## Overview

In this lab, I explored the core networking components of Kubernetes — **Services**. I learned how to configure and use the different types of services (**ClusterIP**, **NodePort**, and **LoadBalancer**) to expose applications both internally and externally, and how to verify service discovery and troubleshoot connectivity issues.

---

## Objectives

By the end of this lab, I was able to:

* Understand the different types of Kubernetes services and their use cases
* Deploy applications and expose them using **ClusterIP** services
* Configure and test **NodePort** services for external access
* Set up **LoadBalancer** services in cloud environments (or simulate locally)
* Verify service connectivity and troubleshoot common issues
* Understand service discovery and DNS resolution in Kubernetes

---

## Prerequisites

Before starting this lab, I had:

* Basic understanding of Kubernetes concepts (pods, deployments, namespaces)
* Familiarity with command-line interface operations and basic networking
* Understanding of YAML file structure
* Previous experience with `kubectl` commands

The lab was performed on the **Al Nafi cloud lab environment**, which provided a pre-configured Kubernetes cluster and necessary tools.

---

## Task 1: Deploy an Application and Expose it Using ClusterIP Service

### Subtask 1.1: Create a Sample Application Deployment

I created a directory for the lab and deployed a 3-replica Nginx deployment.

```bash
mkdir ~/k8s-services-lab
cd ~/k8s-services-lab

cat > nginx-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl get pods -l app=nginx
Subtask 1.2: Create a ClusterIP Service
A ClusterIP service is the default type, exposing the application on an internal IP only accessible within the cluster.

Bash

cat > nginx-clusterip-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip-service
  labels:
    app: nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

kubectl apply -f nginx-clusterip-service.yaml
kubectl get services
kubectl describe service nginx-clusterip-service
Subtask 1.3: Test ClusterIP Service Connectivity
I tested connectivity using the service IP and DNS name from a temporary pod.

Bash

kubectl get service nginx-clusterip-service -o wide

kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh

# Inside the pod:
# Test using service IP (replace with actual ClusterIP)
# wget -qO- [http://10.96.xxx.xxx](http://10.96.xxx.xxx)

# Test using service name (DNS resolution)
# wget -qO- http://nginx-clusterip-service

# Test using FQDN
# wget -qO- [http://nginx-clusterip-service.default.svc.cluster.local](http://nginx-clusterip-service.default.svc.cluster.local)

# exit
Task 2: Change Service Type to NodePort and Verify External Access
Subtask 2.1: Convert ClusterIP to NodePort Service
A NodePort service exposes the service on a static port on every node's IP, allowing external access.

Bash

cat > nginx-nodeport-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-service
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
EOF

kubectl apply -f nginx-nodeport-service.yaml
kubectl get services
kubectl describe service nginx-nodeport-service
Subtask 2.2: Test External Access via NodePort
I tested access using the node's internal IP and the assigned NodePort (30080).

Bash

kubectl get nodes -o wide

# Test external access using a loop to check all nodes:
for node in $(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'); do
  echo "Testing node: $node"
  curl -s http://$node:30080 | grep -o "<title>.*</title>" || echo "Failed to connect"
done
Subtask 2.3: Understanding NodePort Range and Limitations
I observed the default NodePort range (30000-32767) and created a service without specifying nodePort to see the automatic assignment.

Bash

kubectl cluster-info dump | grep service-node-port-range

cat > nginx-nodeport-auto.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-auto
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

kubectl apply -f nginx-nodeport-auto.yaml
kubectl get service nginx-nodeport-auto
Task 3: Configure LoadBalancer Service in Cloud Environment
Subtask 3.1: Understanding LoadBalancer Services
A LoadBalancer service uses the cloud provider's native load balancing solution, providing a dedicated external IP.

Bash

cat > nginx-loadbalancer-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer-service
  labels:
    app: nginx
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

kubectl apply -f nginx-loadbalancer-service.yaml
kubectl get service nginx-loadbalancer-service --watch
Subtask 3.2: Test LoadBalancer Service (Cloud Environment)
I monitored the service until an EXTERNAL-IP was assigned and tested it via curl.

Subtask 3.3: Simulate LoadBalancer with MetalLB (Local Environment)
For local testing, I simulated the LoadBalancer functionality by installing and configuring MetalLB.

Bash

kubectl apply -f [https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml](https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml)
kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s

cat > metallb-config.yaml << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF

kubectl apply -f metallb-config.yaml
kubectl get service nginx-loadbalancer-service
Task 4: Service Discovery and DNS Testing
Subtask 4.1: Test Service DNS Resolution
I tested the built-in Kubernetes DNS resolution using nslookup from within a temporary pod.

Bash

kubectl run dns-test --image=busybox --rm -it --restart=Never -- sh

# Inside the pod:
# nslookup nginx-clusterip-service
# nslookup nginx-clusterip-service.default.svc.cluster.local
# exit
Subtask 4.2: Explore Service Endpoints
Service endpoints track the actual Pod IPs that the service routes traffic to.

Bash

kubectl get endpoints
kubectl describe endpoints nginx-clusterip-service
kubectl get pods -l app=nginx -o wide

# Scaling the deployment confirmed that endpoints automatically update:
kubectl scale deployment nginx-app --replicas=5
kubectl get endpoints nginx-clusterip-service
kubectl scale deployment nginx-app --replicas=3
Task 5: Service Troubleshooting and Best Practices
Subtask 5.1: Common Service Issues and Solutions
I created a broken service with an incorrect selector (app: wrong-label) to simulate a common issue where the service has no endpoints.

Bash

cat > nginx-broken-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-broken-service
spec:
  type: ClusterIP
  selector:
    app: wrong-label
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl apply -f nginx-broken-service.yaml
kubectl get endpoints nginx-broken-service
# The endpoints list was empty, confirming the issue.

# Fix the service by updating the selector:
kubectl patch service nginx-broken-service -p '{"spec":{"selector":{"app":"nginx"}}}'
kubectl get endpoints nginx-broken-service
# Endpoints appeared, confirming the fix.
Subtask 5.2: Service Performance and Monitoring
I practiced checking resource usage and generating test traffic.

Bash

kubectl top pods -l app=nginx
kubectl run load-test --image=busybox --rm -it --restart=Never -- sh
# (Traffic generation commands executed inside load-test pod)
# exit
kubectl logs -l app=nginx --tail=20
Task 6: Cleanup and Service Management
Subtask 6.1: Clean Up Resources
All created resources were successfully deleted to clean the environment.

Bash

kubectl get services
kubectl delete service nginx-clusterip-service
kubectl delete service nginx-nodeport-service
kubectl delete service nginx-loadbalancer-service
kubectl delete service nginx-nodeport-auto
kubectl delete service nginx-broken-service

kubectl delete deployment nginx-app
kubectl get all
Subtask 6.2: Service Configuration Best Practices
I reviewed a YAML example demonstrating best practices for a production-ready LoadBalancer service, including proper labeling, annotations, named ports, and session affinity.

YAML

apiVersion: v1
kind: Service
metadata:
  name: nginx-production
  labels:
    app: nginx
    environment: production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: /health
spec:
  type: LoadBalancer
  selector:
    app: nginx
    environment: production
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
