# Lab 6: Accessing and Interacting with Minikube 🛠️

## Overview

In this lab, I explored how to interact with a Kubernetes cluster running on **Minikube**. The goal was to understand cluster components, manage pods, use `kubectl` commands, and troubleshoot common connectivity issues. This lab helped me get hands-on experience using Minikube as a local Kubernetes environment.

---

## Objectives

By completing this lab, I was able to:

* Understand the basic architecture and components of a Minikube-based Kubernetes cluster
* Use the `kubectl` command-line tool to interact with resources
* List and examine nodes, namespaces, and pods
* Deploy and manage Pods using both command-line and YAML files
* Retrieve and analyze Pod logs for troubleshooting
* Diagnose and resolve connectivity and configuration issues
* Apply foundational Kubernetes concepts in a practical environment

---

## Prerequisites

Before starting, I made sure to have:

* A basic understanding of Docker and containerization
* Familiarity with Linux command-line operations
* Basic YAML syntax knowledge
* General understanding of networking fundamentals

I used the **Al Nafi cloud lab environment**, which already included:

* Minikube pre-installed and configured
* kubectl CLI tool
* Docker runtime
* All necessary dependencies

This saved time and made it easy to start right away.

---

## Task 1: Understanding the Kubernetes Environment

### 1.1 Start Minikube and Verify Cluster Status

I started my Minikube cluster and verified its status:

```bash
minikube start --driver=docker
minikube status
````
Expected output:
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
Then I confirmed that kubectl was correctly configured:

```Bash

kubectl cluster-info
```
1.2 List and Examine Nodes
```Bash

kubectl get nodes
kubectl get nodes -o wide
kubectl describe node minikube
```
In Minikube, there’s typically one node that acts as both the control plane and worker node — perfect for learning and testing.

1.3 Explore Namespaces
Namespaces help organize Kubernetes resources logically. I listed and explored them with:

```Bash

kubectl get namespaces
kubectl get namespaces -o wide
kubectl describe namespace default
kubectl get ns --show-labels
```
Common namespaces include default, kube-system, and kube-public.

1.4 List and Examine Pods
To see running pods:

```Bash

kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide --all-namespaces
kubectl get pods -n kube-system
```
This helped me understand system components like CoreDNS, etcd, and API server pods.

Task 2: Deploy a Simple Pod and Manage Its Lifecycle
2.1 Create a Simple Pod
I deployed a simple nginx pod:

```Bash

kubectl run my-nginx-pod --image=nginx:latest --port=80
kubectl get pods
kubectl get pod my-nginx-pod -o wide
kubectl describe pod my-nginx-pod
```
This confirmed my ability to create and manage pods using kubectl run.

2.2 Create a Pod Using YAML Manifest
I created a YAML file to deploy a custom pod:

```Bash

cat > test-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-app-pod
  labels:
    app: test-app
    environment: lab
spec:
  containers:
  - name: test-container
    image: busybox:latest
    command: ['sh', '-c', 'echo "Hello from Kubernetes Pod!" && sleep 3600']
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF
```
Then I applied it:

```Bash

kubectl apply -f test-pod.yaml
kubectl get pods
```
2.3 Retrieve and Analyze Pod Logs
Log analysis is essential for troubleshooting. I practiced with:

```Bash

kubectl logs my-nginx-pod
kubectl logs test-app-pod
kubectl logs -f test-app-pod
kubectl logs test-app-pod --timestamps
kubectl logs test-app-pod --tail=10
```
2.4 Execute Commands Inside Pods
To inspect a running container:

```Bash

kubectl exec test-app-pod -- ls -la
kubectl exec -it test-app-pod -- sh
```
Inside the pod, I ran a few checks:

```Bash

hostname
ip addr
ps aux
exit
```
This helped me understand how to debug pods from within their container environment.

Task 3: Diagnose and Resolve Connectivity Issues
3.1 Create a Service for Pod Access
I exposed the nginx pod as a service:

```Bash

kubectl expose pod my-nginx-pod --port=80 --target-port=80 --name=nginx-service
kubectl get services
kubectl describe service nginx-service
```
3.2 Test Connectivity Between Pods
I created a temporary debug pod for testing:

```Bash

kubectl run debug-pod --image=busybox:latest --rm -it --restart=Never -- sh
```
Inside the pod, I tested DNS and network connectivity:

```Bash

nslookup nginx-service
wget -qO- nginx-service
```
After checking pod IPs with kubectl get pod my-nginx-pod -o wide, I also tested direct connectivity using:

```Bash

wget -qO- <POD_IP>
exit
```
3.3 Simulate and Resolve a Connectivity Issue
To simulate an image pull failure:

```Bash

kubectl run broken-pod --image=nginx:nonexistent-tag
kubectl get pods
kubectl describe pod broken-pod
kubectl get events --sort-by=.metadata.creationTimestamp
```
Then I fixed it by deleting and redeploying correctly:

```Bash

kubectl delete pod broken-pod
kubectl run fixed-pod --image=nginx:latest
kubectl get pods
kubectl describe pod fixed-pod
```
3.4 Advanced Troubleshooting Techniques
```Bash

kubectl top nodes
kubectl top pods
kubectl get all
kubectl get pods -o yaml my-nginx-pod
kubectl get pods -w
```
# Press Ctrl + C to stop watching pod status.
3.5 Network Policy Testing (Optional)
I also tried a basic NetworkPolicy:

```Bash

cat > deny-all-policy.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```
Applied and tested it:

```Bash

kubectl apply -f deny-all-policy.yaml
kubectl run test-connectivity --image=busybox:latest --rm -it --restart=Never -- wget -qO- nginx-service
```
Then I deleted it to restore access:

```Bash

kubectl delete networkpolicy deny-all
kubectl run test-connectivity --image=busybox:latest --rm -it --restart=Never -- wget -qO- nginx-service
```
Task 4: Clean Up Resources
4.1 Remove All Created Resources
```Bash

kubectl delete pod my-nginx-pod
kubectl delete pod test-app-pod
kubectl delete pod fixed-pod
kubectl delete service nginx-service
rm test-pod.yaml deny-all-policy.yaml
kubectl get pods
kubectl get services
```
4.2 Stop Minikube (Optional)
```Bash

minikube stop
```
To start it again later:

```Bash

minikube start
```
Troubleshooting Common Issues
1. Pod Stuck in Pending State
```Bash

kubectl describe pod <pod-name>
kubectl get events
```
Causes: Insufficient resources, image pull problems, or scheduling issues.

2. Cannot Connect to Service
```Bash

kubectl get endpoints <service-name>
kubectl describe service <service-name>
```
Causes: Wrong selectors, incorrect ports, or unready pods.

3. Image Pull Errors
```Bash

kubectl describe pod <pod-name>
```
Causes: Invalid image name, missing tag, or registry authentication issues.

Key Commands Reference
```Bash

# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Pod management
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- <command>

# Service management
kubectl get services
kubectl describe service <service-name>
kubectl expose pod <pod-name> --port=<port>

# Troubleshooting
kubectl get events
kubectl top nodes
kubectl top pods
```
## Conclusion
By completing this lab, I gained hands-on experience with Minikube and kubectl — understanding how to interact with Kubernetes clusters, deploy and manage pods, expose services, and troubleshoot issues.

What I Learned:
* Starting and managing a Minikube cluster

* Essential kubectl commands for cluster interaction

* Pod management via CLI and YAML

* Log inspection and command execution inside pods

* Network and service troubleshooting

* Diagnosing and fixing connectivity and image pull errors

## Why It Matters:
These are the core skills required for Kubernetes administration and form the foundation for certifications like KCNA. Understanding how to interact with Kubernetes clusters and troubleshoot real issues is critical for DevOps and AIOps engineers.

