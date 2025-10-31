# Lab 8: Implementing Security with Authentication, Authorization, and Admission Control 🔒

## Overview

In this lab, I explored how Kubernetes secures access to cluster resources using **authentication**, **authorization**, and **admission control**. The focus was on understanding how Kubernetes manages user and service identities, applies role-based permissions, and enforces policies to maintain a secure cluster environment.

---

## Objectives

By the end of this lab, I was able to:

* Understand the Kubernetes security model (Authentication, Authorization, Admission Control)
* Create and configure **service accounts** for applications and users
* Implement **Role-Based Access Control (RBAC)** to manage permissions
* Test access control using both authorized and unauthorized actions
* Configure **Admission Controllers** (like Resource Quotas) to enforce policies and limits
* Validate that security configurations work as intended

---

## Prerequisites

Before starting, I ensured I had:

* Basic knowledge of Pods, Services, and Deployments
* Familiarity with YAML syntax and Linux commands
* Understanding of Linux file permissions and user management
* Basic `kubectl` command-line experience

My **Al Nafi** cloud lab came preconfigured with a single-node Kubernetes cluster and full administrative access, so I could focus directly on security configuration.

---

## Task 1: Understanding Kubernetes Security Architecture

### Subtask 1.1 — Explore Current Security Context

I started by reviewing the current user and service account setup:

```bash
kubectl config current-context
kubectl cluster-info
kubectl get serviceaccounts --all-namespaces
kubectl describe serviceaccount default
```
Subtask 1.2 — Understand RBAC ComponentsTo understand existing access control, I explored the built-in roles and bindings:
```Bash
kubectl get roles --all-namespaces
kubectl get clusterroles
kubectl describe clusterrole view
kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings
```
Task 2: Create Service Accounts and Implement RBACSubtask 2.1 — Create Namespace
```Bash
kubectl create namespace security-lab
kubectl config set-context --current --namespace=security-lab
kubectl get namespaces
```
Subtask 2.2 — Create Service AccountsI created three service accounts:
```Bash
kubectl create serviceaccount developer-sa -n security-lab
kubectl create serviceaccount viewer-sa -n security-lab
kubectl create serviceaccount admin-sa -n security-lab
kubectl get serviceaccounts -n security-lab
kubectl describe serviceaccount developer-sa -n security-lab
```
Subtask 2.3 — Define Custom RolesDeveloper Role (Full App Access)
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: security-lab
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
```
Viewer Role (Read-Only Access)
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: security-lab
  name: viewer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
   resources: ["deployments", "replicasets"]
  verbs: ["get", "list"]
```
Applied both roles:
```Bash
kubectl apply -f developer-role.yaml
kubectl apply -f viewer-role.yaml
kubectl get roles -n security-lab
```
Subtask 2.4 — Create Role BindingsDeveloper Role Binding
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: security-lab
subjects:
- kind: ServiceAccount
  name: developer-sa
  namespace: security-lab
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```
Viewer Role Binding
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewer-binding
  namespace: security-lab
subjects:
- kind: ServiceAccount
  name: viewer-sa
  namespace: security-lab
roleRef:
  kind: Role
  name: viewer-role
  apiGroup: rbac.authorization.k8s.io
```
Admin Cluster Role Binding
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-binding
subjects:
- kind: ServiceAccount
  name: admin-sa
  namespace: security-lab
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```
Applied all bindings and verified:
```Bash
kubectl apply -f developer-rolebinding.yaml
kubectl apply -f viewer-rolebinding.yaml
kubectl apply -f admin-clusterrolebinding.yaml

kubectl get rolebindings -n security-lab
kubectl get clusterrolebindings | grep admin-binding
```
Task 3: Test Access Control MechanismsSubtask 3.1 — Create Test Deployment
```Bash
kubectl apply -f test-deployment.yaml
kubectl get deployments -n security-lab
kubectl get pods -n security-lab
```
Subtask 3.2 — Test Service Account PermissionsGenerated tokens for each service account:
```Bash
DEVELOPER_TOKEN=$(kubectl create token developer-sa -n security-lab)
VIEWER_TOKEN=$(kubectl create token viewer-sa -n security-lab)
ADMIN_TOKEN=$(kubectl create token admin-sa -n security-lab)
Developer (Expected: Full Namespace Access)Bashkubectl --token=$DEVELOPER_TOKEN get pods -n security-lab
kubectl --token=$DEVELOPER_TOKEN create configmap test-config --from-literal=key=value -n security-lab
Viewer (Expected: Read-Only)Bashkubectl --token=$VIEWER_TOKEN get pods -n security-lab
kubectl --token=$VIEWER_TOKEN create configmap test-fail --from-literal=key=value -n security-lab
```
Access denied as expected
```
Admin (Expected: Full Cluster Access)Bashkubectl --token=$ADMIN_TOKEN get nodes
kubectl --token=$ADMIN_TOKEN create configmap admin-test --from-literal=admin=true -n default
```
Task 4: Configure Admission ControllersResource QuotasCreated and applied resource-quota.yaml:
```YAML
apiVersion: v1
kind: ResourceQuota
metadata:
  name: security-lab-quota
  namespace: security-lab
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
    services: "5"
    configmaps: "10"
```
Tested quota enforcement with a resource-heavy deployment. Kubernetes correctly denied resources beyond limits.Network PoliciesTo restrict traffic, I implemented:
```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: security-lab
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-test-app-ingress
  namespace: security-lab
spec:
  podSelector:
    matchLabels:
      app: test-app
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: allowed
    ports:
    - protocol: TCP
      port: 80
```
Applied and verified:
```Bash
kubectl apply -f network-policy.yaml
kubectl get networkpolicies -n security-lab
```
Task 5: Validate Security ImplementationCreated a test-client pod with access: allowed label and confirmed it could reach the test app. An unauthorized pod without this label was unable to connect — confirming the network policy was active.Finally, I verified all security components:
```Bash
kubectl get serviceaccounts -n security-lab
kubectl get roles -n security-lab
kubectl get rolebindings -n security-lab
kubectl get networkpolicies -n security-lab
kubectl get resourcequotas -n security-lab
```
## Troubleshooting
NotesIssueCauseFixToken not workingToken expired or invalidRecreate using kubectl create tokenRBAC not appliedMissing or misnamed RoleBindingCheck with kubectl describe rolebindingQuota ignoredMissing resource requests in Pod specsAdd resources to Pod containersNetwork Policy not blockingUnsupported CNI pluginVerify network plugin supports policiesCleanup
```Bash
kubectl delete namespace security-lab
kubectl delete clusterrolebinding admin-binding
kubectl config set-context --current --namespace=default
```
## Summary
This lab gave me practical experience securing Kubernetes clusters using:
- Authentication & Authorization with Service Accounts and RBACAdmission Control with Resource Quotas and Network PoliciesPrinciple of Least Privilege in action through
- role-based accessKey TakeawaysService Accounts define identity for Pods.
- RBAC controls permissions at namespace and cluster level.
- Admission Controllers enforce resource and policy limits.
- Network Policies protect communication between Pods.
- These are essential skills for real-world Kubernetes administration and map directly to KCNA certification objectives.
- The hands-on tests helped me see exactly how Kubernetes enforces security boundaries across different layers.


