# Lab 3 – Understanding Kubernetes Architecture 🧠

In this lab, I explored the internal architecture of Kubernetes and how its components work together to manage containerized workloads. I used `kubectl` commands to inspect control plane components, analyze logs, create Pods, and understand the overall communication flow between the master and worker nodes.

---

## Objectives

By the end of this lab, I was able to:

* Identify and understand the core components of a Kubernetes cluster
* Inspect cluster architecture and component status using `kubectl`
* Analyze control plane logs including **API Server** and **etcd**
* Create and deploy a Pod while understanding its interaction with the control plane and worker nodes
* Examine how Kubernetes components communicate internally
* Troubleshoot basic cluster issues using command-line tools

---

## Prerequisites

Before starting, I made sure I had:

* Basic understanding of **Docker** and containerization concepts
* Familiarity with **Linux commands**
* Knowledge of **YAML file structures**
* Understanding of basic **client-server architecture**
* Completion of previous Kubernetes fundamentals labs

---

## Lab Environment Setup

I used Al Nafi’s cloud-based lab environment, which comes preconfigured with everything I needed:

* Ubuntu 22.04 LTS with `kubectl` pre-installed
* A single-node Kubernetes cluster (Minikube)
* Full admin permissions and internet connectivity
* No manual setup or installation required

After clicking **Start Lab**, I was ready to begin immediately.

---

## Task 1: Identifying Kubernetes Cluster Components

### Step 1.1 – Verify Cluster Status

I started by confirming that my cluster was up and running:

```bash
kubectl cluster-info
kubectl cluster-info dump | head -20
kubectl get nodes -o wide
kubectl describe nodes
```
Step 1.2 – Explore Control Plane Components
Control plane components are responsible for managing the overall cluster state. I listed them using:

```Bash

kubectl get pods -n kube-system
kubectl get pods -n kube-system -o wide
kubectl get pods -n kube-system | grep -E "(apiserver|etcd|scheduler|controller)"
```
Step 1.3 – Examine API Server
The API Server is the heart of Kubernetes. I explored its details and checked endpoints:
```Bash

kubectl get pods -n kube-system | grep apiserver
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')
kubectl get endpoints -n kube-system
```
Step 1.4 – Examine etcd
Next, I looked at etcd, which stores all cluster data:

```Bash

kubectl get pods -n kube-system | grep etcd
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}')
kubectl exec -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') -- etcdctl endpoint health
```
Task 2: Inspecting Control Plane Component Logs
Step 2.1 – API Server Logs
Inspecting the API Server logs helped me understand how the cluster communicates and handles API requests:

```Bash

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') --tail=50
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') -f
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') | grep -i "error\|warning" | tail -10
```
Step 2.2 – etcd Logs
To understand how etcd handles state and replication:

```Bash

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') --tail=30
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') | grep -i "health\|ready" | tail -5
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') | grep -i "slow\|latency" | tail -5
```
Step 2.3 – Scheduler and Controller Manager Logs
These components make scheduling decisions and maintain cluster state:

```Bash

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') --tail=20
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep controller-manager | awk '{print $1}') --tail=20
```
Task 3: Creating a Pod and Understanding Component Interactions
Step 3.1 – Create a Simple Pod
I created a simple Nginx Pod to observe how Kubernetes schedules and manages workloads:

```Bash

cat > nginx-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
  labels:
    app: nginx-demo
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

kubectl apply -f nginx-pod.yaml
kubectl get pods
kubectl describe pod nginx-demo
```
Step 3.2 – Monitor Component Interactions
I checked which components were involved when the Pod was scheduled and started:

```Bash

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') | grep nginx-demo
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') | grep nginx-demo | tail -10
minikube ssh "sudo journalctl -u kubelet | grep nginx-demo | tail -5"
```
Step 3.3 – Analyze Pod Lifecycle
To understand the Pod’s creation process:

```Bash

kubectl get events --sort-by=.metadata.creationTimestamp | grep nginx-demo
kubectl get pod nginx-demo -o yaml | grep -A 10 "status:"
kubectl get pod nginx-demo -o jsonpath='{.status.containerStatuses[0].containerID}'
```
Step 3.4 – Test Pod Functionality and Networking
I verified the Pod was reachable and working:

```Bash

kubectl exec nginx-demo -- nginx -v
kubectl get pod nginx-demo -o wide

POD_IP=$(kubectl get pod nginx-demo -o jsonpath='{.status.podIP}')
curl -I http://$POD_IP

kubectl port-forward nginx-demo 8080:80 &
curl http://localhost:8080
pkill -f "kubectl port-forward"
```
Task 4: Advanced Component Analysis
Step 4.1 – Resource Usage and Metrics
I used kubectl top to monitor cluster resources:

```Bash

kubectl top nodes
kubectl top pods
kubectl describe node | grep -A 5 "Allocated resources"
```
Step 4.2 – Component Dependencies and RBAC
I explored service accounts and roles within the cluster:

```Bash

kubectl get serviceaccounts -n kube-system
kubectl get clusterroles | head -10
kubectl get clusterrolebindings | head -10
kubectl get componentstatuses
```
Troubleshooting Common Issues
Issue 1 – Pod Stuck in Pending
```Bash

kubectl describe pod nginx-demo | grep -A 10 Events
kubectl describe nodes | grep -A 5 "Allocated resources"
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') | tail -20
```
Issue 2 – Control Plane Unreachable
```Bash

kubectl cluster-info
kubectl get pods -n kube-system
minikube stop && minikube start
```
Issue 3 – Network Problems
```Bash

kubectl get pod nginx-demo -o yaml | grep -A 5 "podIP"
kubectl exec nginx-demo -- nslookup kubernetes.default
```
Cleanup
```Bash

kubectl delete pod nginx-demo
rm nginx-pod.yaml
```
## Conclusion
In this lab, I:
* Identified core Kubernetes cluster components

* Explored how the API Server, etcd, scheduler, and controller manager interact

* Analyzed real logs to understand cluster operations

* Created and tested a Pod, following its lifecycle from scheduling to running state

* Practiced troubleshooting cluster and network issues

## Why This Lab Matters
Understanding Kubernetes architecture is essential for:

* Efficient troubleshooting and debugging

* Optimizing cluster performance and resource usage

* Strengthening security by knowing component roles and communication paths

* Preparing for the KCNA certification and advanced Kubernetes administration

**This lab gave me a deeper, hands-on understanding of how Kubernetes actually works under the hood — knowledge that will be invaluable for more advanced operations, scaling, and automation in future labs.**

