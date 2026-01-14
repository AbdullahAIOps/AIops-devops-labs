# 🚀 Lab 16: Integrating Kubernetes with CI/CD Pipelines

This project demonstrates a complete **CI/CD pipeline integrated with Kubernetes**, showcasing real-world DevOps practices using **Docker, GitHub Actions, and Kubernetes (Minikube)**.  
The lab focuses on automation, reliability, rollback strategies, and multi-environment deployments.

---

## 🎯 Objectives

By completing this lab, you will be able to:

- Build a complete CI/CD pipeline using **GitHub Actions**
- Automatically build and push **Docker images**
- Deploy applications to **Kubernetes** using automation
- Implement **automated testing and deployment verification**
- Configure **rollback mechanisms** for failed deployments
- Understand CI/CD integration with Kubernetes
- Apply **best practices** for containerized application workflows

---

## 🧩 Prerequisites

- Basic understanding of **Docker containers and images**
- Familiarity with **Kubernetes concepts** (Pods, Deployments, Services)
- Knowledge of **Git version control**
- Experience with **YAML configuration files**
- Basic Linux command-line skills
- A **GitHub account**

---

## 🖥️ Lab Environment

This lab was performed on **cloud-based Linux machines** with pre-installed tools.

**Environment includes:**
- Ubuntu 20.04 LTS
- Docker (pre-installed)
- kubectl CLI
- Minikube (local Kubernetes cluster)
- Git and text editors
- Preconfigured networking

---

## 🏗️ Architecture Overview

**Pipeline Flow:**
1. Code pushed to GitHub  
2. GitHub Actions triggers CI/CD pipeline  
3. Automated testing and security checks  
4. Docker image built and pushed to Docker Hub  
5. Kubernetes manifests updated  
6. Application deployed to Kubernetes  
7. Rollout verification and health checks  
8. Rollback available on failure  

---

## 🛠️ Technology Stack

- **Backend:** Node.js (Express)
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Orchestration:** Kubernetes (Minikube)
- **Registry:** Docker Hub
- **Automation:** YAML, Bash
- **Monitoring:** Kubernetes liveness & readiness probes

---

## 📁 Project Structure

```
k8s-cicd-lab/
├── app.js
├── package.json
├── Dockerfile
├── k8s-manifests/
│ ├── deployment.yaml
│ ├── service.yaml
│ └── environments/
│ ├── staging/
│ └── production/
├── .github/
│ └── workflows/
│ ├── ci-cd.yaml
│ └── rollback.yaml

```


---

## ⚙️ CI/CD Pipeline Features

### Continuous Integration
- Dependency installation
- Automated tests
- Security audit (`npm audit`)
- Multi-architecture Docker image builds

### Continuous Deployment
- Automatic deployment on `main` branch
- Kubernetes rollout monitoring
- Deployment verification

### Rollback Strategy
- Manual rollback using Kubernetes rollout history
- Automated rollback via GitHub Actions workflow dispatch

---

## 🌍 Multi-Environment Deployment

- **Staging**
  - Single replica
  - Environment-specific configuration
- **Production**
  - Scaled replicas
  - Production-grade configuration
- Managed using **Kustomize**

---

## 🧪 Testing & Verification

- Local Docker testing
- Kubernetes health probes
- Automated deployment verification
- Failure simulation and rollback testing

---

## 🔐 Secrets Management

Secrets are securely stored using **GitHub Actions Secrets**:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `KUBECONFIG` (Base64 encoded)

---

## 🧠 Key Skills Demonstrated

- Kubernetes deployment automation
- CI/CD pipeline design
- Docker image lifecycle management
- Infrastructure as Code (IaC)
- Rollback and disaster recovery handling
- Multi-environment orchestration
- DevOps best practices

---

## 📌 Real-World Relevance

This lab reflects enterprise-level DevOps workflows where teams:
- Deploy changes frequently and safely
- Maintain high availability
- Recover quickly from failures
- Ensure consistent environments
- Reduce manual operational effort

---

## 🏁 Conclusion

This project showcases a **production-ready CI/CD pipeline** integrated with Kubernetes, following modern DevOps standards.  
It provides hands-on experience with automation, reliability, and scalable deployment strategies used in real industry environments.


