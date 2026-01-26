# Lab 19: Configuring and Using Service Mesh with Istio

## Overview

This lab demonstrates how to deploy and use **Istio** as a service mesh on Kubernetes. It covers traffic routing, load balancing, security with mutual TLS (mTLS), observability, and advanced traffic management using a real microservices application.

The **Bookinfo** sample application is used to showcase Istio features in a practical, hands-on manner.

---

## Objectives

By the end of this lab, you will be able to:

- Deploy and configure Istio on a Kubernetes cluster
- Understand service mesh architecture and Istio components
- Configure traffic routing and load balancing between services
- Implement mutual TLS (mTLS) for secure service-to-service communication
- Monitor and observe traffic using Istio tools
- Apply resilience patterns such as circuit breakers, retries, and fault injection

---

## Prerequisites

Before starting this lab, you should have:

- Basic understanding of Kubernetes (Pods, Services, Deployments)
- Familiarity with `kubectl`
- Experience with YAML configuration files
- Understanding of microservices architecture
- Basic networking knowledge (HTTP, TLS, load balancing)

---

## Lab Environment

This lab is designed for a ready-to-use cloud environment.

**Environment details:**

- Ubuntu 22.04 LTS
- Kubernetes cluster (single-node for lab purposes)
- `kubectl` preconfigured
- Internet access for downloading Istio
- Required permissions already configured

No additional setup is required.

---

## Task 1: Deploy Istio Service Mesh

### 1.1 Download and Install Istio

```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH
```
istioctl version
1.2 Install Istio on the Kubernetes Cluster
```bash
istioctl install --set values.defaultRevision=default
kubectl get pods -n istio-system
```
Enable automatic sidecar injection:

```bash
kubectl label namespace default istio-injection=enabled
kubectl get namespace -L istio-injection
```
1.3 Deploy the Sample Application
Deploy the Bookinfo application:

```bash
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get services
kubectl get pods
```
Create the Istio Gateway:

```bash
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get svc istio-ingressgateway -n istio-system
```
Task 2: Traffic Routing and Load Balancing
2.1 Create Service Versions
Create a DestinationRule to define service subsets:

```bash
kubectl apply -f destination-rule.yaml
```
2.2 Configure Traffic Splitting
Apply a VirtualService to route traffic:

- Requests with header end-user: jason go to version v2
- All other traffic is split 50/50 between v1 and v3

```bash
kubectl apply -f reviews-virtual-service.yaml
```
Test traffic routing:

```bash
export GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system \
-o jsonpath='{.status.loadBalancer.ingress[0].ip}')

for i in {1..10}; do
  curl -s "http://$GATEWAY_URL/productpage" \
  | grep -o "glyphicon-star\|color:red"
done
```
2.3 Implement Advanced Load Balancing
Apply an advanced DestinationRule with:
- Least-connections load balancing
- Connection pooling
- Circuit breaking

```bash
kubectl apply -f advanced-destination-rule.yaml
```
Task 3: Implement Mutual TLS (mTLS)
3.1 Enable Strict mTLS
Check current mTLS status:

```bash
istioctl authn tls-check productpage.default.svc.cluster.local
```
Apply PeerAuthentication policy:

```bash
kubectl apply -f peer-authentication.yaml
```
3.2 Verify mTLS Configuration
Verify mTLS is enabled:

```bash
istioctl authn tls-check productpage.default.svc.cluster.local
```
Check proxy configuration:

```bash
istioctl proxy-config cluster <productpage-pod> \
--fqdn reviews.default.svc.cluster.local
Test access from a non-mesh pod (expected to fail):
```
```bash
curl http://productpage.default.svc.cluster.local:9080/productpage
```
3.3 Configure Authorization Policies
Apply AuthorizationPolicy to control service access:

```bash
kubectl apply -f authorization-policy.yaml
```
Task 4: Monitor and Observe Service Mesh Traffic
4.1 Install Observability Add-ons
```bash
kubectl apply -f samples/addons/kiali.yaml
kubectl apply -f samples/addons/prometheus.yaml
kubectl apply -f samples/addons/grafana.yaml
kubectl apply -f samples/addons/jaeger.yaml
kubectl get pods -n istio-system
```
4.2 Generate Traffic and Monitor
Generate continuous traffic:

```bash
while true; do
  curl -s "http://$GATEWAY_URL/productpage" > /dev/null
  sleep 1
done
```
Access dashboards:

```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
kubectl port-forward -n istio-system svc/grafana 3000:3000
```
Task 5: Advanced Traffic Management
5.1 Fault Injection
Apply fault injection policy:

```bash
kubectl apply -f fault-injection.yaml
```
Test fault injection:

```bash
curl -H "end-user: jason" "http://$GATEWAY_URL/productpage"
```
5.2 Timeout and Retry Policies
Apply timeout and retry configuration:

```bash
kubectl apply -f timeout-retry.yaml
```
Verification and Troubleshooting
Useful commands:

```bash
istioctl verify-install
istioctl proxy-status
istioctl analyze
istioctl authn tls-check <service-name>
```
## Common issues:

Pods not showing 2/2 ready
→ Ensure namespace has istio-injection=enabled and restart deployments

Cannot access application
→ Verify Gateway, VirtualService, and ingress IP

mTLS issues
→ Check PeerAuthentication and proxy configuration

Observability tools not accessible
→ Verify pods are running and port-forwarding is correct

## Cleanup
To remove all lab resources:

```bash
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl delete -f destination-rule.yaml
kubectl delete -f reviews-virtual-service.yaml
kubectl delete -f advanced-destination-rule.yaml
kubectl delete -f peer-authentication.yaml
kubectl delete -f authorization-policy.yaml
kubectl delete -f fault-injection.yaml
kubectl delete -f timeout-retry.yaml

kubectl delete -f samples/addons/
istioctl uninstall --purge
kubectl delete namespace istio-system
```
## Conclusion
In this lab, you:

- Deployed Istio and enabled service mesh capabilities
- Configured traffic routing, splitting, and load balancing
- Secured services using mutual TLS and authorization policies
- Monitored service behavior with Kiali, Prometheus, and Grafana
- Implemented resilience patterns such as retries, timeouts, and fault injection

These skills are essential for managing production-grade microservices on Kubernetes and are directly applicable to cloud-native, DevOps, and platform engineering roles.
