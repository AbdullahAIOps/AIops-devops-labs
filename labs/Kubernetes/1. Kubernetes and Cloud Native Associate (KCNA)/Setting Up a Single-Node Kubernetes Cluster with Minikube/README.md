# Lab 5: Setting Up a Single-Node Kubernetes Cluster with Minikube

## Overview

In this lab, I worked on setting up a **single-node Kubernetes cluster** using **Minikube** on Linux. The goal was to understand how a lightweight local cluster works, how to interact with it using `kubectl`, and how to manage its lifecycle — from installation to stopping and restarting while keeping everything persistent.

---

## Objectives

By completing this lab, I learned to:

- Install and configure **Minikube** on Linux  
- Start and manage a **single-node Kubernetes cluster**  
- Use **kubectl** to verify and interact with the cluster  
- Understand basic cluster components and their status  
- Stop and restart the Minikube cluster while maintaining persistence  
- Troubleshoot common installation and startup issues  

---
  

I used an **Al Nafi cloud machine**, which came pre-configured with:

- Ubuntu 20.04 LTS  
- Docker runtime  
- Internet connectivity  
- 2 CPUs and 4 GB RAM  

---

## Step 1: Installing Minikube

### 1.1 Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```
1.2 Install Required Dependencies
```bash
sudo apt install -y curl wget apt-transport-https
```
1.3 Download and Install Minikube
```bash

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
Verify installation:

```bash

minikube version
```
Expected output:

```yaml
minikube version: v1.32.0
commit: 8220a6eb95f0a4d75f7f2d7b14cef975f050512d
```
1.4 Install kubectl
```bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client
```
Expected output:

```yaml
Client Version: v1.29.0
Kustomize Version: v5.0.4
```
Step 2: Starting the Minikube Cluster
2.1 Start Minikube Using Docker Driver
```bash
minikube start --driver=docker
```
This initializes a local Kubernetes cluster using Docker as the container runtime.
The first startup takes a few minutes as it pulls base images and components.

2.2 Verify Cluster Status
```bash
minikube status
```
Expected output shows Running for host, kubelet, and apiserver.

2.3 Verify kubectl Context
```bash
kubectl config current-context
```
Expected output:

```nginx
minikube
```
Step 3: Verifying Cluster Health and Resources
3.1 Check Cluster Information
```bash
kubectl cluster-info
```
Expected output:

```swift
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at .../services/kube-dns:dns/proxy
```
3.2 List Cluster Nodes
```bash
kubectl get nodes
kubectl describe node minikube
```
Expected:

```pgsql

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   2m    v1.28.3
```
3.3 Check System Pods
```bash
kubectl get pods -n kube-system
```
All pods like CoreDNS, etcd, API server, and scheduler should be in Running state.

3.4 Check Resource Usage
If Metrics Server is not installed:

```bash

minikube addons enable metrics-server
```
Then run:

```bash

kubectl top node
```
3.5 List Namespaces
```bash
kubectl get namespaces
```
Expected:

```pgsql
default
kube-system
kube-public
kube-node-lease
```
Step 4: Testing Cluster Functionality
4.1 Deploy a Test Application
```bash
kubectl create deployment hello-minikube --image=nginx:latest
kubectl get deployments
```
Expected:

```pgsql
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
hello-minikube   1/1     1            1           30s
```
4.2 Expose the Deployment

```bash
kubectl expose deployment hello-minikube --type=NodePort --port=80
kubectl get services
```
4.3 Access the Application
```bash
minikube service hello-minikube --url
curl $(minikube service hello-minikube --url)
```
The command returns the default Nginx welcome page.

Finally, I cleaned up the test resources:

```bash
kubectl delete deployment hello-minikube
kubectl delete service hello-minikube
```
Step 5: Stopping and Restarting the Cluster
5.1 Stop the Cluster
```bash
minikube stop
minikube status
```
5.2 Restart the Cluster
```bash
minikube start
```
Expected output confirms successful restart and reconnection of components.

5.3 Verify Persistence
```bash

kubectl get nodes
kubectl get pods -n kube-system
kubectl get pv
kubectl get storageclass
```
Everything remained intact after the restart, confirming persistence.

Step 6: Exploring Minikube Features
6.1 Enable the Kubernetes Dashboard
```bash
minikube addons enable dashboard
minikube dashboard --url
```
This opens the Kubernetes Dashboard in a browser window.

6.2 View and Enable Addons
```bash

minikube addons list
minikube addons enable ingress
kubectl get pods -n ingress-nginx
```
6.3 Check Configuration and IP
```bash
minikube config view
minikube ip
Troubleshooting Common Issues
```
1. Minikube Won’t Start
```bash

sudo systemctl status docker
sudo systemctl start docker
minikube delete
minikube start --driver=docker
```
2. kubectl Commands Not Working
```bash
kubectl config current-context
kubectl config use-context minikube
```
3. Insufficient Resources
```bash
minikube delete
minikube start --driver=docker --memory=4096 --cpus=2
```
4. Network Issues
```bash
minikube status
minikube delete
minikube start --driver=docker --network-plugin=cni
```
## Lab Cleanup
When finished, I cleaned up resources:

```bash
minikube stop
minikube delete
sudo rm /usr/local/bin/minikube
sudo rm /usr/local/bin/kubectl
```
## Key Takeaways
Installed and configured Minikube and kubectl

* Set up and managed a single-node Kubernetes cluster

* Verified node and pod health with kubectl

* Deployed and exposed a test nginx application

* Learned how to stop, restart, and persist cluster state

* Explored key Minikube features like addons and dashboard

## Why This Lab Matters
Setting up Minikube helped me understand the core components of Kubernetes in a simple and local environment. It’s an ideal setup for:

* Practicing Kubernetes commands safely

* Preparing for KCNA certification

* Testing and debugging deployments

* Building confidence before working on multi-node or cloud-based clusters

## Conclusion
This lab gave me practical experience with Kubernetes cluster setup, management, and troubleshooting using Minikube. I now have a solid local environment for experimenting with deployments, services, and networking. It’s a great foundation before moving on to advanced topics like Helm, Ingress, and multi-node clusters.
