# Lab 18: Observability with Prometheus and Grafana

## Overview
This lab demonstrates how to implement **observability in a Kubernetes environment** using **Prometheus** and **Grafana**. You will deploy a full monitoring stack, collect metrics from cluster components and applications, visualize them using dashboards, and configure alerts for critical system conditions.

By completing this lab, you gain hands-on experience with monitoring best practices for cloud-native workloads.

---

## Objectives
By the end of this lab, you will be able to:

- Deploy Prometheus in a Kubernetes cluster
- Configure Prometheus to scrape metrics from cluster components and applications
- Install and access Grafana for visualization
- Create custom Grafana dashboards
- Configure alerting rules for CPU, memory, and pod health
- Understand observability fundamentals in cloud-native environments
- Implement monitoring best practices for Kubernetes workloads

---

## Prerequisites
Before starting this lab, you should have:

- Basic understanding of Kubernetes (pods, services, deployments)
- Familiarity with YAML configuration files
- Basic Linux command-line knowledge
- Understanding of containerization concepts
- Access to `kubectl`
- Basic understanding of monitoring and metrics

---

## Lab Environment
This lab uses a **ready-to-use cloud environment** provided by Al Nafi.

### Included Tools
- Ubuntu 20.04 LTS
- Docker (pre-installed)
- Kubernetes cluster (Minikube)
- kubectl configured
- Helm package manager
- Networking pre-configured

---

## Task 1: Deploy Prometheus

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
Access Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &
```
Access: http://localhost:9090

Task 2: Configure Metrics Scraping
Deploy Sample Application
```bash
kubectl apply -f sample-app.yaml
```
Create ServiceMonitor
```bash
kubectl apply -f sample-app-monitor.yaml
```
Verify Targets
http://localhost:9090/targets

Task 3: Grafana Setup
Get Admin Password
```bash
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```
Access Grafana
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
```
Access: http://localhost:3000
Username: admin

Task 4: Dashboards
Import Kubernetes Dashboard
Dashboard ID: 315

Data source: Prometheus

Custom Dashboards

- CPU Usage by Node
- Memory Usage by Node
- Disk Usage
- Pod CPU & Memory
- Running Pod Count

Task 5: Alerting
CPU Alerts

- Warning: > 80% for 2 minutes
- Critical: > 95% for 1 minute

- Memory Alerts
Warning: > 85%
Critical: > 95%
- Pod Alerts
- CrashLoopBackOff
- Pod Not Ready

Verify alerts at:
http://localhost:9090/alerts

Task 6: Advanced Monitoring
Custom Metrics Application
Deploy application exposing custom metrics

Create ServiceMonitor
Verify metrics collection

## Troubleshooting
Pods Not Starting
```bash
kubectl describe pod -n monitoring
kubectl logs -n monitoring
kubectl top nodes
```
- Metrics Missing
- Verify ServiceMonitor
- Check Prometheus targets
- Confirm service endpoints
- Grafana Issues
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana
kubectl get svc -n monitoring prometheus-kube-prometheus-prometheus
```
## Cleanup
```bash
pkill -f "kubectl port-forward"

kubectl delete pod cpu-stress-test
kubectl delete deployment sample-app custom-metrics-app
kubectl delete service sample-app-service custom-metrics-service

kubectl delete servicemonitor -n monitoring sample-app-monitor custom-metrics-monitor
kubectl delete prometheusrules -n monitoring cpu-usage-alerts memory-usage-alerts pod-alerts

helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```
## Conclusion
This lab provided a complete, hands-on implementation of observability in Kubernetes using Prometheus and Grafana. You successfully deployed a monitoring stack, collected metrics, built dashboards, configured alerts, and applied monitoring best practices for cloud-native workloads.

This setup forms a strong foundation for production-grade Kubernetes monitoring and SRE practices.

