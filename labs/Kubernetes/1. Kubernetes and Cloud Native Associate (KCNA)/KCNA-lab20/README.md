# Lab 20: Exploring Cloud Native Application Delivery with GitOps

## Overview

This lab demonstrates GitOps-based application delivery using ArgoCD on Kubernetes. The goal is to understand how Git becomes the single source of truth for deploying, updating, and managing cloud-native applications while ArgoCD continuously synchronizes the Kubernetes cluster state with the Git repository.

---

## Objectives

By the end of this lab, you will be able to:

- Understand core GitOps principles and benefits  
- Install and configure ArgoCD in a Kubernetes cluster  
- Create and manage Kubernetes manifests using Git  
- Deploy applications using GitOps workflows  
- Observe automatic synchronization between Git and cluster state  
- Update applications using Git commits  
- Troubleshoot common GitOps deployment issues  

---

## Prerequisites

Before starting this lab, you should have:

- Basic knowledge of Kubernetes (Pods, Services, Deployments)  
- Familiarity with Git  
- Basic understanding of YAML  
- Knowledge of containers and Docker  
- Access to a Linux CLI environment  

---

## Lab Environment

- Ubuntu 20.04 LTS  
- kubectl pre-installed  
- Minikube for local Kubernetes cluster  
- Git client configured  
- Nano or Vim text editor  

---

## Task 1: Environment Setup

### Start Minikube

```bash
minikube start --driver=docker --memory=4096 --cpus=2
kubectl cluster-info
kubectl get nodes
Create ArgoCD Namespace
bash
Copy code
kubectl create namespace argocd
kubectl get namespaces
Task 2: Install and Configure ArgoCD
Install ArgoCD
bash
Copy code
kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=available \
deployment/argocd-server -n argocd --timeout=300s

kubectl get pods -n argocd
Access ArgoCD UI
bash
Copy code
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
Get admin password:

bash
Copy code
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d && echo
UI URL:

arduino
Copy code
https://localhost:8080
Install ArgoCD CLI
bash
Copy code
curl -sSL -o argocd-linux-amd64 \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
argocd version --client
Login to ArgoCD
bash
Copy code
argocd login localhost:8080 \
--username admin \
--password <your-password> \
--insecure

argocd account get-user-info
Task 3: Create Git Repository
bash
Copy code
mkdir ~/gitops-demo
cd ~/gitops-demo
git init
git config user.name "GitOps Student"
git config user.email "student@example.com"
Create Application Manifests
bash
Copy code
mkdir -p apps/sample-app
Commit Manifests
bash
Copy code
git add .
git commit -m "Initial commit: Add sample application manifests"
git log --oneline
Task 4: Integrate Git Repository with ArgoCD
bash
Copy code
kubectl apply -f argocd-app.yaml
Verify application:

bash
Copy code
argocd app list
argocd app get sample-app
argocd app status sample-app
Task 5: Deploy Application Using GitOps
bash
Copy code
argocd app sync sample-app
argocd app wait sample-app --timeout 300
Verify deployment:

bash
Copy code
kubectl get pods -n sample-app
kubectl get services -n sample-app
kubectl get deployments -n sample-app
Test application:

bash
Copy code
kubectl port-forward -n sample-app svc/sample-app-service 8081:80 &
curl http://localhost:8081
pkill -f "kubectl port-forward"
Task 6: Update Application via Git
bash
Copy code
git commit -m "Update: Increase replicas and upgrade nginx"
ArgoCD automatically detects and syncs changes.

Task 7: Observe Synchronization
bash
Copy code
argocd app get sample-app
kubectl get pods -n sample-app
Task 8: Advanced GitOps
Added ConfigMap

Mounted custom index.html

Observed automatic synchronization

Task 9: Troubleshooting
bash
Copy code
argocd app get sample-app
kubectl get events -n sample-app
kubectl get pods -n sample-app
Task 10: Monitoring
bash
Copy code
kubectl top pods -n sample-app
kubectl logs -n sample-app -l app=sample-app
Cleanup
bash
Copy code
argocd app delete sample-app --cascade
kubectl delete namespace sample-app
kubectl delete namespace argocd
minikube stop
Conclusion
This lab demonstrates a complete GitOps workflow using ArgoCD and Kubernetes. You learned how Git acts as the single source of truth, enabling automated deployments, easy rollbacks, improved reliability, and strong auditability. These practices are widely used in real-world cloud-native and enterprise DevOps environments.
