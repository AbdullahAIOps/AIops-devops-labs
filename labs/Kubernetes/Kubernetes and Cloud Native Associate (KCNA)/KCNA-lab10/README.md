# Lab 10: Deploying a Stand-Alone Application in Kubernetes 🚀

## Overview

In this lab, I mastered the core Kubernetes deployment workflow by creating a **Deployment** for a stand-alone application (NGINX), exposing it using a **NodePort Service**, and monitoring its health, logs, and resource utilization. I also practiced updating the application using a **ConfigMap**.

---

## Objectives

By the end of this lab, I was able to:

* Create and deploy a Kubernetes manifest for a stand-alone application
* Configure and deploy a **NodePort service** to expose applications externally
* Monitor application **logs** using `kubectl` commands
* View and analyze **resource metrics** for deployed applications
* Understand the relationship between Deployments, Pods, and Services
* Troubleshoot common deployment issues in Kubernetes environments

---

## Prerequisites

Before starting this lab, I had:

* Basic understanding of containerization concepts (Docker)
* Familiarity with YAML file structure and syntax
* Basic knowledge of Linux command line operations
* Understanding of networking concepts (ports, IP addresses)

The lab was performed on the **Al Nafi cloud lab environment**, pre-configured with `kubectl` and a **Minikube** cluster.

---

## Task 1: Write and Deploy a Kubernetes Manifest for a Stand-Alone Application

### Subtask 1.1: Verify Kubernetes Cluster Status

I verified the cluster status and node readiness:

```bash
kubectl cluster-info
kubectl get nodes
# Output confirmed the 'minikube' node was in the 'Ready' state.
```
Subtask 1.2: Create the Application Deployment ManifestI created the deployment manifest for a 3-replica NGINX application, ensuring resource requests/limits were set and proper labels were used.
```Bash
mkdir ~/k8s-lab10
cd ~/k8s-lab10
nano nginx-deployment.yaml

# YAML Content (See below for details):
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: nginx-standalone-app
#   labels:
#     app: nginx-standalone
# spec:
#   replicas: 3
# ... (container specs) ...
```
Subtask 1.3: Deploy the Application
```Bash
kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl get pods -l app=nginx-standalone
kubectl get pods -l app=nginx-standalone -w
# Waited for all 3 pods to enter the "Running" status.
```
Subtask 1.4: Verify Application Details
```Bash
kubectl describe deployment nginx-standalone-app
kubectl get replicasets -l app=nginx-standalone
```
Task 2: Expose the Application Externally Using a NodePort ServiceSubtask 2.1: Create the NodePort Service ManifestI created a NodePort service to expose the application externally on port 30080.
```Bash
nano nginx-service.yaml

# YAML Content (See below for details):
# apiVersion: v1
# kind: Service
# metadata:
#   name: nginx-standalone-service
# spec:
#   type: NodePort
#   selector:
#     app: nginx-standalone
#   ports:
#   - port: 80
#     targetPort: 80
#     nodePort: 30080
```
Subtask 2.2: Deploy the Service
```Bash
kubectl apply -f nginx-service.yaml
kubectl get services
kubectl describe service nginx-standalone-service
```
Subtask 2.3: Test External AccessI retrieved the cluster IP and used curl to confirm external accessibility via the NodePort.
```Bash
minikube ip
curl http://$(minikube ip):30080
# Output was the default NGINX welcome page.
echo "Access your application at: http://$(minikube ip):30080"
```
Subtask 2.4: Verify Service Endpoints
```Bash
kubectl get endpoints nginx-standalone-service
kubectl get pods -l app=nginx-standalone -o wide
# Confirmed that the endpoint IPs matched the Pod IPs.
```
Task 3: Monitor Application Logs and Resource MetricsSubtask 3.1: Monitor Application Logs
```Bash
kubectl logs -l app=nginx-standalone
kubectl logs -f POD_NAME # Followed logs from a specific pod
# Generated traffic to see real-time log updates:
# curl http://$(minikube ip):30080
kubectl logs -l app=nginx-standalone --since=10m
```
Subtask 3.2: Monitor Resource Usage
```Bash
kubectl top pods -l app=nginx-standalone
kubectl top nodes
kubectl describe pod POD_NAME
```
Subtask 3.3: Monitor Application Health
```Bash
kubectl get pods -l app=nginx-standalone -o wide
kubectl get events --field-selector involvedObject.name=nginx-standalone-app
kubectl rollout status deployment/nginx-standalone-app
```
Subtask 3.4: Create a Custom HTML Page (Application Update)I created a custom HTML page and packaged it into a ConfigMap, then updated the Deployment to mount the ConfigMap, demonstrating a simple application configuration change and rollout.
```Bash
#Custom HTML file created here: custom-index.html
kubectl create configmap nginx-custom-html --from-file=index.html=custom-index.html

# Updated Deployment YAML created here: nginx-deployment-updated.yaml
# Added volumeMounts and volumes sections to the Pod template.

kubectl apply -f nginx-deployment-updated.yaml
kubectl rollout status deployment/nginx-standalone-app
curl http://$(minikube ip):30080
# Confirmed the custom HTML content was displayed.
```

## Conclusion
This lab provided practical experience with the core Kubernetes application deployment and management lifecycle. I successfully created a highly available application using a Deployment, exposed it using a NodePort Service, customized its content using a ConfigMap, and rigorously monitored its health, logs, and resource usage.
## Why This Matters
These skills are foundational for:
* Production Deployments: Mastering Deployments and Services is the backbone of running applications in production.
* Resource Management: Applying resource requests and limits ensures cluster stability and efficient use of resources.
* KCNA Certification: This entire workflow directly addresses fundamental concepts tested in the Kubernetes and Cloud Native Associate certification.
