# Lab 2: Introduction to Kubernetes

## Overview
This lab focuses on understanding and working with **Kubernetes**, the industry-standard platform for container orchestration.  
You’ll install and configure Minikube, deploy a sample web application, explore Kubernetes core concepts, and compare it with Docker Swarm.

By the end of this lab, you’ll understand how Kubernetes handles scaling, self-healing, and resource management in real-world environments.

---

## Objectives
- Install and configure **Minikube** locally.  
- Deploy and expose a simple **Nginx web application** on Kubernetes.  
- Learn core concepts like **Pods**, **Deployments**, and **Services**.  
- Demonstrate **scaling** and **self-healing** in action.  
- Compare **Kubernetes orchestration** with **Docker Swarm**.  
- Implement advanced features such as **health probes**, **rolling updates**, and **ConfigMaps/Secrets**.

---

## Environment Setup
- **OS:** Ubuntu 20.04 LTS  
- **Tools:** Docker, Minikube, kubectl  
- **Resources:** 2 CPUs, 2GB memory  
- **Cluster Type:** Local (Minikube using VirtualBox or Docker driver)

---

## Key Tasks

### 1. Kubernetes Setup
- Installed dependencies (`curl`, `wget`, `VirtualBox`).
- Installed **kubectl** and verified version.
- Installed **Minikube** and started a single-node cluster.
- Verified cluster readiness with `kubectl get nodes`.

### 2. Application Deployment
- Created an **Nginx deployment** using both imperative and declarative approaches.
- Defined YAML manifests for:
  - **Deployment:** Managing Nginx replicas and containers.
  - **Service:** Exposing Nginx through NodePort for external access.
- Verified application accessibility using `minikube service`.

### 3. Scaling and Self-Healing
- Scaled deployment replicas up and down using `kubectl scale`.
- Simulated pod failure and observed **automatic recovery**.
- Watched Kubernetes maintain desired replica count and replace failed pods.

### 4. Monitoring and Debugging
- Checked cluster health and resource usage using:
  - `kubectl top pods`
  - `kubectl top nodes`
- Viewed container logs and executed commands inside pods for debugging.

### 5. Advanced Operations
- Created **ConfigMaps** and **Secrets** for configuration management.  
- Implemented **liveness** and **readiness probes** for health monitoring.  
- Performed **rolling updates** and verified deployment version changes.  
- Explored rollback capabilities for safe updates.

### 6. Comparison with Docker Swarm
Created a markdown comparison report highlighting:
- Architecture differences  
- Scaling capabilities  
- Service discovery  
- Ecosystem maturity  
- Learning curve and setup simplicity  

**Result:** Kubernetes offers greater flexibility and automation for large-scale systems, while Docker Swarm remains simpler for quick setups.

---

## Troubleshooting Notes
Common issues and quick fixes:
- **Minikube not starting:** Try `--driver=docker` or check VirtualBox installation.  
- **Pods stuck in Pending:** Check node resources and image pull permissions.  
- **Service not reachable:** Validate service selectors and endpoints.

---

## Cleanup
After completing the lab:
```bash
kubectl delete all --all
minikube stop

```
## Conclusion
This lab provided hands-on experience with Kubernetes fundamentals — from setup to deployment, scaling, and maintenance.
You learned how Kubernetes automates container orchestration, manages resources efficiently, and recovers from failures without manual intervention.

These skills form a strong foundation for working with EKS (AWS), GKE (Google Cloud), or AKS (Azure) and are essential for any modern DevOps or Cloud-Native engineer.

## Author
**Abdullah Saleem**
AIOps / DevOps Engineer
