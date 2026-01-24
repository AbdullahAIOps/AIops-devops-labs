# Lab 17: Exploring Kubernetes Security Best Practices 🔐

## Overview
This lab focuses on **securing Kubernetes workloads** by applying modern security best practices. You will work hands-on with **Pod Security Standards**, **Network Policies**, **container image scanning**, and **RBAC**, building a strong foundation for running secure, production-ready Kubernetes clusters.

---

## Objectives
By completing this lab, you will be able to:

- Implement **Pod Security Standards (PSS)** in Kubernetes
- Configure **Network Policies** to control Pod-to-Pod communication
- Perform **container image vulnerability scanning** using Trivy
- Apply security best practices for containerized workloads
- Troubleshoot common Kubernetes security issues

---

## Prerequisites
Before starting this lab, you should have:

- Basic understanding of Kubernetes (Pods, Services, Deployments)
- Familiarity with YAML configuration files
- Basic Linux command-line skills
- Understanding of container security concepts
- Completion of previous Kubernetes labs or equivalent experience

---

## Lab Environment
This lab uses **ready-to-use cloud machines** provided by Al Nafi.

### Environment Includes
- Ubuntu 22.04 LTS
- Kubernetes cluster (Minikube or Kind)
- kubectl pre-configured
- Required tools pre-installed
- Internet access for image downloads

---

## Task 1: Pod Security Standards (PSS)

### Understanding Pod Security Standards
Kubernetes provides three Pod Security profiles:

- **Privileged** – No restrictions
- **Baseline** – Prevents known privilege escalations
- **Restricted** – Enforces pod hardening best practices

---

### Enable Pod Security Admission
```bash
kubectl api-versions | grep admissionregistration

kubectl create namespace secure-apps

kubectl label namespace secure-apps \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```
Test an Insecure Pod
```bash
kubectl apply -f insecure-pod.yaml
```
Expected result: Pod creation is blocked or warned due to policy violations.

Deploy a Secure Pod
```bash
kubectl apply -f secure-pod.yaml
kubectl get pods -n secure-apps
kubectl describe pod secure-pod -n secure-apps
```
Task 2: Network Policies
Create Namespaces
```bash
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database

kubectl label namespace frontend tier=frontend
kubectl label namespace backend tier=backend
kubectl label namespace database tier=database
```
Deploy Applications
```bash
kubectl apply -f frontend-app.yaml
kubectl apply -f backend-app.yaml
kubectl apply -f database-app.yaml
```
Verify:

```bash
kubectl get pods -n frontend
kubectl get pods -n backend
kubectl get pods -n database
```
Test Connectivity (Before Policies)
```bash
kubectl exec -n frontend <frontend-pod> -- wget http://backend-service.backend.svc.cluster.local
kubectl exec -n frontend <frontend-pod> -- nc -zv database-service.database.svc.cluster.local 5432
```
Apply Network Policies
```bash
kubectl apply -f database-network-policy.yaml
kubectl apply -f backend-network-policy.yaml
```
Test Policy Enforcement
```bash
# Should fail
kubectl exec -n frontend <frontend-pod> -- nc -zv database-service.database.svc.cluster.local 5432

# Should work
kubectl exec -n frontend <frontend-pod> -- wget http://backend-service.backend.svc.cluster.local
kubectl exec -n backend <backend-pod> -- nc -zv database-service.database.svc.cluster.local 5432
```
Task 3: Container Image Scanning with Trivy
Install Trivy
```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```
trivy version
Scan Images
```bash
trivy image nginx:latest
trivy image --severity HIGH,CRITICAL nginx:latest
trivy image --format json --output nginx-scan.json nginx:latest
```
Scan Cluster Images
```bash
chmod +x scan-cluster-images.sh
./scan-cluster-images.sh
```
Secure Image Build Example:
- Uses fixed image versions
- Drops root privileges
- Removes unnecessary packages
- Uses non-privileged ports
See: Dockerfile.secure

Task 4: Additional Security Controls
RBAC Configuration
```bash
kubectl apply -f rbac-config.yaml
```
Resource Quotas and Limits
```bash
kubectl apply -f resource-quota.yaml
```
Verify Security Configuration
```bash
kubectl get namespace secure-apps --show-labels
kubectl get networkpolicies --all-namespaces
kubectl get serviceaccounts -n secure-apps
kubectl get resourcequota -n secure-apps
```
## Troubleshooting
- Pod Security Not Enforced
- Verify namespace labels
- Check admission controller availability
- Network Policies Not Working
- Ensure CNI supports NetworkPolicy (Calico, Cilium, Weave)
- Validate policy selectors and ports

Trivy Scan Issues
```bash
trivy image --download-db-only
trivy image --debug nginx:latest
```
Lab Validation
```bash
kubectl auth can-i get pods \
  --as=system:serviceaccount:secure-apps:app-service-account \
  -n secure-apps
```
## Conclusion
You have successfully completed Lab 17: Exploring Kubernetes Security Best Practices.

## Key Takeaways
- Enforced Pod Security Standards using a modern approach
- Implemented zero-trust networking with Network Policies
- Integrated image vulnerability scanning with Trivy
- Applied RBAC, quotas, and limits for defense in depth

## Why This Matters
Kubernetes security is critical in production environments. The practices learned in this lab help protect against:
- Privilege escalation and container breakouts
- Lateral movement inside the cluster
- Vulnerable container images
- Resource exhaustion attacks
- Unauthorized access to cluster resources
- Security is not a one-time task. Continuously review policies, scan images, and audit access as your workloads evolve.

🚀 Well done on building a secure Kubernetes foundation!
