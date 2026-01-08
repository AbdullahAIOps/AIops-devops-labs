# Lab 15: Implementing Autoscaling in Kubernetes (HPA & VPA)

## 📌 Overview
This lab demonstrates how to implement **autoscaling in Kubernetes** using both **Horizontal Pod Autoscaler (HPA)** and **Vertical Pod Autoscaler (VPA)**.  
The goal is to understand how Kubernetes automatically scales applications based on workload demands and resource usage.

By completing this lab, you gain hands-on experience with:
- CPU-based horizontal scaling
- Resource-based vertical scaling
- Metrics-driven automation
- Real-time monitoring and troubleshooting

This lab reflects **real-world Kubernetes operations** and aligns with **KCNA / CKAD / DevOps engineering practices**.

---

## 🎯 Objectives
By the end of this lab, you will be able to:

- Understand Horizontal Pod Autoscaler (HPA) and Vertical Pod Autoscaler (VPA)
- Configure HPA based on CPU utilization
- Generate synthetic traffic to trigger autoscaling
- Monitor scaling events in real time
- Implement VPA to automatically adjust CPU and memory
- Compare horizontal vs vertical scaling strategies
- Troubleshoot common autoscaling issues

---

## 🧠 Prerequisites
Before starting this lab, you should have:

- Basic knowledge of Kubernetes (Pods, Deployments, Services)
- Familiarity with `kubectl`
- Understanding of CPU and memory resources
- Basic Linux command-line skills
- Access to a Kubernetes cluster with metrics-server installed

---

## 🧪 Lab Environment
This lab was performed on a **pre-configured Kubernetes cluster** with:

- Multiple worker nodes
- `kubectl` configured
- Metrics Server pre-installed
- Internet access for pulling container images

---

## 🔹 Task 1: Horizontal Pod Autoscaler (HPA)

### Step 1: Deploy Sample Application
A simple PHP-Apache web application is deployed with defined CPU and memory requests and limits.

```bash
kubectl apply -f php-apache-deployment.yaml
```
Verify:

```bash
kubectl get deployments
kubectl get pods -l app=php-apache
```
Step 2: Verify Metrics Server
HPA depends on metrics-server for CPU metrics.

```bash
kubectl top nodes
kubectl top pods
```
If metrics-server is missing:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
Step 3: Create Horizontal Pod Autoscaler
HPA scales pods when average CPU utilization exceeds 50%.

```bash
kubectl apply -f hpa-config.yaml
```
Verify:

```bash
kubectl get hpa
kubectl describe hpa php-apache
```
🔹 Task 2: Generate Load & Observe Scaling
Step 1: Create Load Generator
A BusyBox pod continuously sends HTTP requests to the application.

```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
```
Inside the pod:

```sh
while true; do wget -q -O- http://php-apache; done
```
Step 2: Monitor Autoscaling
Observe autoscaling behavior in real time.

```bash
kubectl get hpa php-apache --watch
kubectl get pods -l app=php-apache --watch
kubectl top pods -l app=php-apache
````
Stop the load generator with Ctrl+C and observe scale-down behavior.

🔹 Task 3: Vertical Pod Autoscaler (VPA)
Step 1: Install VPA
VPA is not enabled by default.

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/
./hack/vpa-install.sh
```
Verify:

```bash
kubectl get pods -n kube-system | grep vpa
```
Step 2: Remove HPA (Avoid Conflict)
HPA and VPA should not control CPU simultaneously.

```bash
kubectl delete hpa php-apache
```
Step 3: Deploy VPA (Auto Mode)
VPA automatically adjusts CPU and memory by restarting pods.

```bash
kubectl apply -f vpa-config.yaml
```
Verify:

```bash
kubectl get vpa
kubectl describe vpa php-apache-vpa
```
Step 4: Generate Load for VPA
Deploy a stronger load generator.

```bash
kubectl apply -f load-generator-deployment.yaml
```
Monitor:

```bash
kubectl top pods -l app=php-apache
kubectl get pods -l app=php-apache --watch
```
Step 5: Recommendation-Only Mode
To prevent automatic restarts, VPA can run in recommendation mode.

```bash
kubectl apply -f vpa-recommend-only.yaml
kubectl describe vpa php-apache-vpa-recommend
```
🔹 Task 4: Advanced Autoscaling
Multi-Metric HPA
Scale based on CPU and memory simultaneously.

```bash
kubectl apply -f multi-metric-hpa.yaml
```
Custom Metrics HPA
Example of scaling using application-level metrics (requires Prometheus adapter).

```bash
kubectl apply -f custom-metric-hpa.yaml
```
## 🛠️ Troubleshooting
HPA Shows Unknown
Metrics server not running

Resource requests missing

Check:

```bash
kubectl logs -n kube-system deployment/metrics-server
```
VPA Not Updating Pods
Ensure updateMode is Auto

Check admission controller

Verify no resource quotas block updates

Scaling Too Fast or Too Slow
Adjust stabilization windows

Tune target utilization

Modify scaling policies

## 🧹 Cleanup
```bash
kubectl delete deployment php-apache load-generator
kubectl delete service php-apache
kubectl delete hpa --all
kubectl delete vpa --all
rm -f *.yaml
```
(Optional VPA removal)

```bash
cd autoscaler/vertical-pod-autoscaler/
./hack/vpa-down.sh
```
# ✅ Conclusion
In this lab, you successfully:

Implemented Horizontal Pod Autoscaler (HPA) for traffic-based scaling

Observed real-time scaling behavior under load

Configured Vertical Pod Autoscaler (VPA) for automatic resource optimization

Compared horizontal vs vertical scaling strategies

Learned troubleshooting techniques for autoscaling issues

Autoscaling is a core Kubernetes capability that improves performance, reliability, and cost efficiency.
Understanding HPA and VPA is essential for modern DevOps, SRE, and Cloud Engineers.

## 👤 Author
### Abdullah Saleem
DevOps | Cloud | Kubernetes | AIOps
