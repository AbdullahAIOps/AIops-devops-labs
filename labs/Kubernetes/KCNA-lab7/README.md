# Lab 7: Exploring Kubernetes Building Blocks 🧱

## Overview

In this lab, I worked on the core building blocks of Kubernetes — **Pods**, **Deployments**, and **ConfigMaps**. The main goal was to understand how these components interact, how applications are deployed and scaled, and how configurations can be managed cleanly using Kubernetes best practices.

---

## Objectives

By the end of this lab, I was able to:

* Deploy a Pod using a YAML manifest file
* Create and manage Deployments to scale applications
* Understand the difference between Pods and Deployments
* Create ConfigMaps for managing configuration data
* Mount ConfigMaps into Pods as environment variables
* Verify and troubleshoot resources using `kubectl`
* Apply good practices for container orchestration

---

## Prerequisites

Before starting, I made sure I understood the basics of Docker, YAML syntax, and Linux commands. Kubernetes and `kubectl` were already installed in my cloud lab environment provided by Al Nafi, so setup was quick and straightforward.

---

## Task 1: Deploying a Pod Using a YAML Manifest

I started by checking that my cluster was up and running:

```bash
kubectl cluster-info
kubectl get nodes
```
Once confirmed, I created a directory for this lab and built my first YAML file:

```Bash

mkdir ~/k8s-lab7 && cd ~/k8s-lab7
nano simple-pod.yaml
simple-pod.yaml
```
```YAML

apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: lab
spec:
  containers:
  - name: nginx-container
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
```
Then I deployed and verified it:

```Bash

kubectl apply -f simple-pod.yaml
kubectl get pods
kubectl describe pod nginx-pod
kubectl logs nginx-pod
```
To test connectivity inside the cluster:

```Bash

kubectl exec -it nginx-pod -- curl localhost:80
```
It returned the default Nginx welcome page, confirming the Pod was running fine.

Task 2: Scaling the Application with a Deployment
Next, I moved on to Deployments, which make scaling and updates easier.

nginx-deployment.yaml

```YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
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
```
I applied and verified it:

```Bash

kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl get pods -l app=nginx
```
Scaling was straightforward using both methods:

```Bash

# Scale via command
kubectl scale deployment nginx-deployment --replicas=4

# Or update the YAML and reapply
nano nginx-deployment.yaml   # changed replicas: 3
kubectl apply -f nginx-deployment.yaml
kubectl get pods -l app=nginx
```
Task 3: Managing Configuration with ConfigMaps
To externalize configuration, I created a ConfigMap and attached it to a Pod.

app-config.yaml

```YAML

apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_host: "mysql.example.com"
  database_port: "3306"
  database_name: "myapp"
  log_level: "INFO"
  max_connections: "100"
  app_version: "1.2.3"
```
Applied and verified it:

```Bash

kubectl apply -f app-config.yaml
kubectl get configmaps
kubectl describe configmap app-config
```
Then I created a Pod that used this ConfigMap as environment variables.

pod-with-config.yaml

```YAML

apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    app: myapp
spec:
  containers:
  - name: app-container
    image: busybox:1.35
    command: ['sh', '-c', 'echo "Starting application..." && env | grep -E "(DATABASE|LOG|MAX|APP)" && sleep 3600']
    envFrom:
    - configMapRef:
        name: app-config
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_IP
      valueFrom:
          fieldRef:
            fieldPath: status.podIP
```
Deployment and testing:

```Bash

kubectl apply -f pod-with-config.yaml
kubectl get pod app-pod
kubectl logs app-pod
```
I could see all my configuration values from the ConfigMap in the logs. To confirm, I also checked inside the Pod:

```Bash

kubectl exec -it app-pod -- sh
env | sort
exit
```
Later, I updated the ConfigMap to test how changes propagate:

```Bash

kubectl patch configmap app-config --patch '{"data":{"log_level":"DEBUG","app_version":"1.2.4"}}'
kubectl delete pod app-pod
kubectl apply -f pod-with-config.yaml
kubectl logs app-pod
```
The updated configuration was successfully reflected.

Verification & Cleanup
To verify all resources:

```Bash

kubectl get pods,deployments,configmaps
kubectl get deployment nginx-deployment -o wide
kubectl exec app-pod -- env | grep database_host
```
Cleanup after completion:

```Bash

kubectl delete pod nginx-pod
kubectl delete deployment nginx-deployment
kubectl delete pod app-pod
kubectl delete configmap app-config
kubectl get pods,deployments,configmaps
```
## Troubleshooting Notes
Some common issues I handled:

* Pod stuck in Pending: Checked node resources and image availability.

* ConfigMap not loading: Verified YAML syntax and names.

* Deployment not scaling: Used kubectl get deployment -o wide and reviewed events.

* Env variables missing: Restarted Pod after ConfigMap updates (ConfigMaps aren't automatically updated in running Pods).

## Summary
This lab helped me understand the foundational Kubernetes components:

* Pods are the smallest deployable units.

* Deployments provide scalability and reliability.

* ConfigMaps separate configuration from application logic.

These concepts form the backbone of Kubernetes operations. Understanding them is essential for building scalable, resilient, and configurable applications in a production environment.

## Conclusion
Next, I’ll move on to learning about Services, Persistent Volumes, and Ingress controllers — the key building blocks that connect and expose applications effectively.
