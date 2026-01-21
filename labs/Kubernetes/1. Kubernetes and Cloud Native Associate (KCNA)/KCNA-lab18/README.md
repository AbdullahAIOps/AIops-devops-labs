# Lab 18: Observability with Prometheus and Grafana

## Overview
This lab focuses on implementing observability in a Kubernetes environment using **Prometheus** for metrics collection and **Grafana** for visualization and alerting. The goal is to gain hands-on experience with monitoring Kubernetes clusters, workloads, and applications using cloud-native best practices.

By completing this lab, I implemented a full monitoring stack, configured metric scraping, built custom dashboards, and created alerting rules for proactive system monitoring.

---

## Objectives
By the end of this lab, I was able to:

- Deploy Prometheus to a Kubernetes cluster using Helm
- Configure Prometheus to scrape metrics from cluster components and applications
- Install and configure Grafana for metrics visualization
- Create custom Grafana dashboards for nodes, pods, and cluster health
- Set up alerting rules for CPU, memory, and pod health
- Understand observability fundamentals in cloud-native systems
- Apply Kubernetes monitoring best practices

---

## Prerequisites
Before starting this lab, the following knowledge and tools were required:

- Basic understanding of Kubernetes (Pods, Services, Deployments)
- Familiarity with YAML configuration files
- Basic Linux command-line skills
- Understanding of containerization concepts
- Access to `kubectl`
- Basic knowledge of monitoring and metrics

---

## Lab Environment
This lab was performed on a **pre-configured cloud environment** provided by Al Nafi.

### Environment Details
- Ubuntu 20.04 LTS
- Docker pre-installed
- Kubernetes cluster (Minikube)
- `kubectl` configured and ready
- Helm package manager installed
- Networking pre-configured

No additional VM or Kubernetes installation was required.

---

## Task 1: Deploy Prometheus to Kubernetes

### Verify Cluster Status
```bash
kubectl cluster-info
kubectl get nodes
minikube status
```
Create Monitoring Namespace
```bash
kubectl create namespace monitoring
kubectl get namespaces
```
Deploy Prometheus Using Helm
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
```
Verify Deployment
```bash
kubectl get pods -n monitoring
kubectl get services -n monitoring
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
```
Access Prometheus UI
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &
```
Access via: http://localhost:9090
Task 2: Configure Metrics Scraping
Deploy Sample Application
A sample application was deployed to expose metrics for Prometheus scraping.

```bash
kubectl apply -f sample-app.yaml
```
Create ServiceMonitor
```bash
kubectl apply -f sample-app-servicemonitor.yaml
```
Verify Metrics
```bash
kubectl get servicemonitor -n monitoring
```
Targets were verified in Prometheus under /targets.

Task 3: Grafana Setup and Access
Get Grafana Admin Password
```bash
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```
Access Grafana
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
```
Access via: http://localhost:3000
Default username: admin

Prometheus was already configured as a data source.

Task 4: Create Grafana Dashboards
**Imported Dashboard**
Kubernetes Cluster Monitoring (Dashboard ID: 315)
Custom Dashboards Created
Node CPU Usage
Node Memory Usage
Disk Usage
Pod CPU and Memory Usage
Running Pod Count
These dashboards provided real-time visibility into cluster health and workloads.

Task 5: Alerting with Prometheus and Grafana
Prometheus Alert Rules Implemented
High CPU usage

Critical CPU usage

High memory usage

Critical memory usage

Pod crash looping

Pod not ready

Alerts were defined using PrometheusRule resources and validated in Prometheus UI.

Grafana Alerting
Grafana panel-based alerts were configured for CPU thresholds and tested using a CPU stress pod.

Task 6: Advanced Monitoring
Custom Metrics Collection
Deployed an application exposing custom metrics

Created a ServiceMonitor to scrape business-level metrics

Verified metrics visibility in Prometheus and Grafana

Troubleshooting Highlights
Verified Metrics Server and Prometheus targets when metrics were missing

Checked ServiceMonitor labels and namespaces

Validated Grafana-to-Prometheus connectivity

Used logs and resource metrics to debug pod issues

Cleanup
bash
Copy code
pkill -f "kubectl port-forward"

kubectl delete pod cpu-stress-test
kubectl delete deployment sample-app custom-metrics-app
kubectl delete service sample-app-service custom-metrics-service

kubectl delete servicemonitor -n monitoring sample-app-monitor custom-metrics-monitor
kubectl delete prometheusrules -n monitoring cpu-usage-alerts memory-usage-alerts pod-alerts

helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
Conclusion
This lab provided hands-on experience with Kubernetes observability using Prometheus and Grafana. I successfully deployed a complete monitoring stack, configured metrics collection, built custom dashboards, and implemented alerting for proactive system monitoring.

These skills are critical for:

Production Kubernetes operations

DevOps and SRE roles

Capacity planning and performance optimization

Incident detection and response

KCNA certification preparation

This lab strengthened my understanding of observability as a core pillar of reliable, scalable cloud-native systems.


