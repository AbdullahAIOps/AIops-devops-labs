# Lab 12: Deploying a Multi-Tier Application in Kubernetes ⚙️

## Overview

This lab demonstrates how I deployed a **three-tier application** on Kubernetes using **Nginx (frontend)**, **Flask (backend)**, and **MySQL (database)**. The goal was to understand how different layers of an application interact inside a Kubernetes cluster and to apply real-world deployment concepts like ConfigMaps, Secrets, and Services.

---

## Architecture

| Tier | Component | Function | Kubernetes Object |
| :--- | :--- | :--- | :--- |
| **Presentation** | Nginx | Serves custom static web content | Deployment, NodePort Service, ConfigMap |
| **Application Logic** | Flask | Handles API requests and communicates with the database | Deployment, ClusterIP Service |
| **Data** | MySQL | Stores and manages application data | Deployment, ClusterIP Service, Secret |

---

## Step-by-Step Work

### 1. Environment Setup

I created a dedicated namespace for isolation.

```bash
kubectl create namespace multi-tier-app
kubectl config set-context --current --namespace=multi-tier-app # Optional: Set context
```
2. Configuration and Credential ManagementConfiguration was externalized using ConfigMaps (for static content) and Secrets (for credentials).
3. Bash# Create ConfigMap for the Nginx custom HTML page
```
kubectl create configmap nginx-custom-html --from-file=index.html=custom-index.html

# Create Secrets for database credentials
kubectl create secret generic database-secret \
  --from-literal=MYSQL_ROOT_PASSWORD=rootpassword123 \
  --from-literal=MYSQL_PASSWORD=userpassword123
```
3. Deploying the MySQL Database (Data Tier)The database uses the database-secret to set the root password, ensuring credentials are not hardcoded.
```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  labels: { app: mysql }
spec:
  replicas: 1
  selector: { matchLabels: { app: mysql } }
  template:
    metadata: { labels: { app: mysql } }
    spec:
      containers:
      - name: mysql
        image: mysql:8
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_DATABASE
          value: appdb
        ports:
        - containerPort: 3306
```
6. Deploying the Flask Backend (Application Tier)The backend connects to the database using the database Service name (mysql) as the host and retrieves the password from the database-secret.
```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-backend
  labels: { app: flask-backend }
spec:
  replicas: 2
  selector: { matchLabels: { app: flask-backend } }
  template:
    metadata: { labels: { app: flask-backend } }
    spec:
      containers:
      - name: flask-backend
        image: yourusername/flask-backend:latest
        env:
        - name: DB_HOST
          value: mysql
        - name: DB_USER
          value: root
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: MYSQL_ROOT_PASSWORD
        - name: DB_NAME
          value: appdb
        ports:
        - containerPort: 5000
```
8. Deploying the Nginx Frontend (Presentation Tier)The frontend mounts the custom index.html from the nginx-custom-html ConfigMap.
```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-frontend
  labels: { app: nginx-frontend }
spec:
  replicas: 2
  selector: { matchLabels: { app: nginx-frontend } }
  template:
    metadata: { labels: { app: nginx-frontend } }
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: nginx-html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nginx-html
        configMap:
          name: nginx-custom-html
```
10. Exposing Services for Inter-Tier Communication and External AccessServices enable stable networking between the tiers and expose the application externally.
```YAML
# MySQL Service (ClusterIP or Headless for internal discovery)
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  selector: { app: mysql }
  ports:
  - port: 3306
    targetPort: 3306
  clusterIP: None # Headless service for direct pod access

---

# Flask Backend Service (ClusterIP for internal access by Nginx)
apiVersion: v1
kind: Service
metadata:
  name: flask-backend
spec:
  selector: { app: flask-backend }
  ports:
  - port: 5000
    targetPort: 5000

---

# Nginx Frontend Service (NodePort for external user access)
apiVersion: v1
kind: Service
metadata:
  name: nginx-frontend
spec:
  selector: { app: nginx-frontend }
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
```
VerificationI verified deployment status and external access:
```Bash
kubectl get pods -n multi-tier-app
kubectl get svc -n multi-tier-app
minikube service nginx-frontend -n multi-tier-app
```
The custom webpage was successfully served, and the backend/database connections were verified to be working.

## What I Learned
* Multi-Tier Structure: Gained a hands-on understanding of how to separate an application into logical tiers (DB, Logic, Presentation) within Kubernetes.

* Secure Configuration: Learned the critical best practice of using Secrets for credentials and ConfigMaps for general application settings.

* Service Discovery: Confirmed that applications can reliably communicate using Service names (e.g., Flask connects to the database simply by addressing mysql).

* Reliability: Implemented scaling (replicas > 1) to improve fault tolerance and reliability across the application and presentation layers.
