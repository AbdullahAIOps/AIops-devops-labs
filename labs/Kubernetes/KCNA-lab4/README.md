# Lab 4: Installing Kubernetes ⚙️

## Overview

In this lab, I set up a complete Kubernetes cluster from scratch using **kubeadm**. I walked through every step — from preparing the system and configuring networking to verifying that the cluster is fully functional. By the end, I had a working cluster that I could use for deployments and future labs.

---

## Objectives

By completing this lab, I learned to:

* Set up a Kubernetes cluster using **kubeadm** on Linux
* Configure the **container runtime** and **CNI networking plugin**
* Verify the installation using `kubectl` commands
* Explore cluster components and logs
* Troubleshoot common setup issues
* Deploy and test an application within the cluster

---

## Prerequisites

Before starting, I made sure I had:

* Basic Linux command-line knowledge
* Familiarity with Docker and containerization concepts
* Root or `sudo` access on a Linux machine
* Internet connectivity
* At least **2 GB RAM** and **2 CPU cores**

My lab environment was pre-configured on **Ubuntu 20.04 LTS** with Docker installed, provided through Al Nafi’s cloud setup.

---

## Step 1: Preparing the System

I started by updating the system and installing the necessary packages:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
Next, I disabled swap since Kubernetes requires it to be off:

```Bash

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
free -h
```
Then I enabled the required kernel modules for networking:

```Bash

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```
Finally, I configured and applied the required sysctl parameters:

```Bash

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```
Step 2: Installing containerd Runtime
Kubernetes needs a container runtime, and I used containerd.

```Bash

curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y containerd.io
```
After installation, I configured containerd to use the systemd cgroup driver:

```Bash

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```
I verified that containerd was running correctly:

```Bash

sudo systemctl status containerd
```
Step 3: Installing Kubernetes Components
I added the Kubernetes repository and installed kubeadm, kubelet, and kubectl.

```Bash

curl -fsSL [https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key](https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key) | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] [https://pkgs.k8s.io/core:/stable:/v1.28/deb/](https://pkgs.k8s.io/core:/stable:/v1.28/deb/) /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
I confirmed the installation:

```Bash

kubeadm version
kubectl version --client
```
Step 4: Initializing the Cluster
I initialized the control plane using kubeadm:

```Bash

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}')
```
Once initialization completed, I set up the kubectl configuration for my user:

```Bash

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl cluster-info
```
Step 5: Installing the Network Plugin (Flannel)
To enable pod networking, I installed the Flannel CNI plugin:

```Bash

kubectl apply -f [https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml](https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml)
```
For a single-node cluster, I allowed pods to schedule on the master node:

```Bash

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
I verified taint removal and checked node details:

```Bash

kubectl describe nodes | grep -i taint
```
Step 6: Verifying Cluster Installation
I verified that everything was working:

```Bash

kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl wait --for=condition=ready pod --all -n kube-system --timeout=300s
kubectl cluster-info
```
All nodes were in the Ready state and all system pods were running.

Step 7: Deploying a Test Application
To confirm the cluster was functional, I deployed a simple nginx app:

```Bash

kubectl create deployment nginx-test --image=nginx:latest
kubectl expose deployment nginx-test --port=80 --type=NodePort
kubectl get pods
kubectl get services
```
Then I tested it:

```Bash

NODE_PORT=$(kubectl get service nginx-test -o jsonpath='{.spec.ports[0].nodePort}')
curl http://localhost:$NODE_PORT
```
It returned the default Nginx welcome page, confirming everything worked.

Finally, I cleaned up:

```Bash

kubectl delete deployment nginx-test
kubectl delete service nginx-test
```
Step 8: Troubleshooting and Verification
I verified resource usage and cluster components:

```Bash

kubectl top nodes
kubectl api-resources
kubectl get componentstatuses
kubectl get events --sort-by=.metadata.creationTimestamp
```
If any pod was stuck or a component wasn’t running, I checked logs using:

```Bash

kubectl describe pod <pod-name>
sudo systemctl status kubelet
sudo journalctl -xeu kubelet
```
## Key Takeaways
* Successfully built and configured a Kubernetes cluster using kubeadm.

* Installed and configured containerd as the runtime.

* Set up Flannel for pod networking.

* Verified node, pod, and control-plane health.

* Deployed and tested an application to validate the setup.

## Why This Matters
Manually installing Kubernetes gave me a clear understanding of how the cluster components fit together — the control plane, kubelet, container runtime, and networking layers.

This experience is essential for:

* Troubleshooting real-world Kubernetes issues

* Preparing for KCNA certification

* Understanding cluster internals before using managed services like EKS or AKS

* Building a strong foundation for DevOps and AIOps automation

## Conclusion
This lab was a major milestone in my Kubernetes journey. I now have a fully functional cluster that I can use for testing, learning, and deploying containerized workloads. The hands-on installation helped me understand Kubernetes at a much deeper level — from system preparation to verifying cluster health.

Next, I’ll move on to exploring multi-node clusters, persistent storage, and ingress configuration to expand my setup further.
