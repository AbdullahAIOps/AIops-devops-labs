# Lab 2 – Introduction to Kubernetes 🚀

In this lab, I worked on setting up a local Kubernetes environment using **Minikube** and explored the fundamentals of Kubernetes architecture. The goal was to get comfortable deploying, scaling, and managing containerized applications inside a cluster.

---

## Objectives

By the end of this lab, I was able to:

* Set up and configure Minikube for local Kubernetes development
* Deploy and manage a simple web application (Nginx)
* Understand how deployments, pods, and services work together
* Scale applications manually and test Kubernetes’ self-healing behavior
* Compare Kubernetes orchestration with Docker Swarm
* Perform advanced operations like rolling updates, health checks, and resource cleanup

---

## Prerequisites

Before starting, I made sure my environment had:

* Ubuntu 20.04 LTS with Docker pre-installed
* Basic knowledge of Docker, YAML, and Linux CLI
* Administrative privileges (sudo access)

---

## Step 1: Installing Minikube and kubectl

I started by updating my system and installing the required tools.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https
sudo apt install -y virtualbox virtualbox-ext-pack
```
Then I installed kubectl, the Kubernetes CLI:
```Bash

curl -LO "[https://dl.k8s.io/release/$(curl](https://dl.k8s.io/release/$(curl) -L -s [https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl](https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl)"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```
Next, I installed Minikube:

```Bash

curl -LO [https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64](https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64)
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```
I started the cluster using VirtualBox:

```Bash

minikube start --driver=virtualbox --memory=2048 --cpus=2
```
After it started, I verified everything:
```Bash

minikube status
kubectl cluster-info
kubectl get nodes
Step 2: Deploying a Simple Application
```
To test the setup, I deployed a simple nginx application.

```Bash

kubectl create deployment nginx-app --image=nginx:latest
kubectl get deployments
kubectl get pods
kubectl describe deployment nginx-app
```
Then I created a working directory for my manifests:

```Bash

mkdir ~/k8s-lab && cd ~/k8s-lab
```
I applied my deployment file and confirmed that the pods were running:

```Bash

kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl get pods -l app=nginx
kubectl describe pods -l app=nginx
```
Next, I exposed the deployment as a service:

```Bash

kubectl apply -f nginx-service.yaml
kubectl get services
kubectl describe service nginx-service
```
Finally, I accessed the Nginx application from my browser:

```Bash

minikube ip
minikube service nginx-service --url
curl $(minikube service nginx-service --url)
```
I was able to see the default Nginx welcome page, confirming everything worked correctly.

Step 3: Scaling and Self-Healing
I experimented with Kubernetes scaling and recovery behavior.

Scaling Up
```Bash

kubectl get deployments nginx-deployment
kubectl scale deployment nginx-deployment --replicas=5
kubectl get pods -l app=nginx
kubectl get pods -l app=nginx -w
```
After verifying all 5 pods were running, I scaled it back down:

```Bash

kubectl scale deployment nginx-deployment --replicas=2
kubectl get pods -l app=nginx
```
Self-Healing Test
I deleted one pod to simulate a failure:
```Bash

POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD_NAME
kubectl get pods -l app=nginx -w
```
Kubernetes automatically replaced the deleted pod, showing its self-healing capability.

Step 4: Logs, Debugging, and Resource Monitoring
I checked logs from running pods and even accessed one of them interactively:

```Bash

kubectl logs -l app=nginx
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- /bin/bash
nginx -t
exit
```
To monitor resource usage:

```Bash

kubectl top nodes
kubectl top pods
kubectl describe nodes minikube
Step 5: Kubernetes vs Docker Swarm
To better understand orchestration differences, I compared key features.
```
Kubernetes example:

```Bash

kubectl create deployment app --image=nginx --replicas=3
kubectl expose deployment app --port=80 --type=NodePort
Docker Swarm equivalent:
```
```Bash

docker service create --name app --replicas 3 --publish 80:80 nginx
Kubernetes clearly offers more advanced management, scalability, and observability.
```
Step 6: Advanced Operations
I practiced creating ConfigMaps and Secrets:

```Bash

kubectl create configmap nginx-config --from-literal=server_name=myapp.local
kubectl create secret generic nginx-secret --from-literal=username=admin --from-literal=password=secretpass
kubectl get configmaps
kubectl get secrets
Then I tested rolling updates:
```
```Bash

kubectl set image deployment/nginx-with-probes nginx=nginx:1.22
kubectl rollout status deployment/nginx-with-probes
kubectl rollout history deployment/nginx-with-probes
Step 7: Cleanup
After finishing all the tasks, I cleaned up my environment:
```
```Bash

kubectl delete deployment nginx-app
kubectl delete deployment nginx-deployment
kubectl delete deployment nginx-with-probes
kubectl delete service nginx-service
kubectl delete configmap nginx-config
kubectl delete secret nginx-secret
kubectl get all
minikube stop
Troubleshooting 🚨
Minikube not starting
If VirtualBox doesn’t support virtualization:
```
```Bash

minikube start --driver=docker
Pods stuck in pending
Check node resources and events:
```
```Bash

kubectl describe nodes
kubectl get events --sort-by=.metadata.creationTimestamp
Service not reachable
Verify endpoints and labels:
```
```Bash

kubectl get endpoints
kubectl get pods --show-labels
```
## Conclusion
This lab gave me hands-on exposure to Kubernetes fundamentals — from deploying and scaling workloads to understanding self-healing and service management. I also got to compare it with Docker Swarm and see how Kubernetes handles orchestration at scale.

It was a solid step toward mastering Kubernetes concepts that are essential for cloud-native DevOps, AIOps automation, and production-grade CI/CD pipelines.
