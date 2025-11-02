# Lab 13: Using ConfigMaps and Secrets for Application Configuration

This lab focuses on managing application configuration in Kubernetes using **ConfigMaps** and **Secrets**.  
You’ll learn how to securely handle both non-sensitive and sensitive configuration data, pass environment variables to Pods, and mount configuration files into containers.

---

## 🎯 Objectives

By the end of this lab, you will be able to:

- Create and manage **ConfigMaps** to store non-sensitive configuration data.  
- Create and manage **Secrets** to store sensitive information securely.  
- Pass environment variables to Pods using ConfigMaps and Secrets.  
- Mount ConfigMaps and Secrets as files in Pod containers.  
- Understand the differences between ConfigMaps and Secrets.  
- Apply best practices for application configuration management in Kubernetes.

---

## 🧠 Prerequisites

Before starting this lab, you should have:

- A basic understanding of **Kubernetes concepts** (Pods, Deployments).  
- Familiarity with **YAML syntax**.  
- Experience using the **command-line interface**.  
- Basic knowledge of **environment variables** and **file systems**.

---

## ☁️ Lab Environment

Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed.  
Simply click **Start Lab** to access your environment — no setup or installation required.

Your lab environment includes:

- Kubernetes cluster (minikube or similar)  
- `kubectl` command-line tool  
- Text editor (`nano` or `vim`)  
- All necessary permissions to create resources

---

## 🧩 Lab Tasks

### Task 1: Create a ConfigMap to Pass Environment Variables to a Pod

#### Subtask 1.1: Create a ConfigMap Using `kubectl`
```bash
kubectl create configmap app-config \
  --from-literal=DATABASE_HOST=mysql-service \
  --from-literal=DATABASE_PORT=3306 \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=info

kubectl get configmaps
kubectl describe configmap app-config
```
Subtask 1.2: Create a ConfigMap from a File
```bash
cat > app.properties << EOF
database.host=mysql-service
database.port=3306
app.environment=production
log.level=info
cache.enabled=true
cache.ttl=300
EOF

kubectl create configmap app-properties --from-file=app.properties
kubectl get configmap app-properties -o yaml
```
Subtask 1.3: Use ConfigMap as Environment Variables in a Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-env
spec:
  containers:
  - name: app-container
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: app-config
    env:
    - name: CUSTOM_MESSAGE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
  restartPolicy: Never
```
```bash
kubectl apply -f pod-with-configmap.yaml
kubectl exec app-pod-env -- env | grep -E "(DATABASE|APP|LOG)"
```
Task 2: Create a Secret to Store Sensitive Information
Subtask 2.1: Create a Secret for Database Credentials
```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=supersecret123 \
  --from-literal=root-password=rootsecret456

kubectl get secrets
kubectl describe secret db-credentials
kubectl get secret db-credentials -o yaml
```
Subtask 2.2: Create a Secret from Files
```bash
echo -n 'admin' > username.txt
echo -n 'supersecret123' > password.txt

kubectl create secret generic file-credentials \
  --from-file=username.txt \
  --from-file=password.txt

rm username.txt password.txt
```
Subtask 2.3: Use Secrets as Environment Variables in a Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-secret
spec:
  containers:
  - name: app-container
    image: nginx:1.21
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
    - name: DB_ROOT_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: root-password
  restartPolicy: Never
```
```bash
kubectl apply -f pod-with-secret.yaml
kubectl exec app-pod-secret -- env | grep DB_
Task 3: Mount ConfigMaps and Secrets into Pods as Files
Subtask 3.1: Create a Pod with ConfigMap and Secret Volume Mounts
yaml
Copy code
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-volumes
spec:
  containers:
  - name: app-container
    image: nginx:1.21
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
      readOnly: true
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    - name: properties-volume
      mountPath: /etc/properties
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: secret-volume
    secret:
      secretName: db-credentials
      defaultMode: 0400
  - name: properties-volume
    configMap:
      name: app-properties
  restartPolicy: Never
```
```bash
kubectl apply -f pod-with-volumes.yaml
kubectl wait --for=condition=Ready pod/app-pod-volumes --timeout=60s
```
Subtask 3.2: Verify Mounted Files
```bash
kubectl exec app-pod-volumes -- ls -la /etc/config/
kubectl exec app-pod-volumes -- cat /etc/config/DATABASE_HOST
kubectl exec app-pod-volumes -- ls -la /etc/secrets/
kubectl exec app-pod-volumes -- cat /etc/secrets/username
kubectl exec app-pod-volumes -- cat /etc/properties/app.properties
```
Subtask 3.3: Create a Deployment Using ConfigMaps and Secrets
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-container
        image: nginx:1.21
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: app-config
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html/config
        - name: secret-volume
          mountPath: /usr/share/nginx/html/secrets
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: db-credentials
```
```bash
kubectl apply -f deployment-with-config.yaml
kubectl get pods -l app=web-app
POD_NAME=$(kubectl get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- env | grep -E "(DATABASE|APP|LOG|DB_)"
```
Task 4: Update ConfigMaps and Secrets
Subtask 4.1: Update a ConfigMap
```bash
kubectl patch configmap app-config --patch '{"data":{"LOG_LEVEL":"debug","NEW_FEATURE":"enabled"}}'
kubectl describe configmap app-config
```
Subtask 4.2: Update a Secret
```bash
kubectl patch secret db-credentials --patch '{"data":{"api-key":"'$(echo -n 'new-api-key-123' | base64)'"}}'
kubectl describe secret db-credentials
```
Task 5: Clean Up
```bash
kubectl delete pod app-pod-env app-pod-secret app-pod-volumes
kubectl delete deployment web-app-deployment
kubectl delete configmap app-config app-properties
kubectl delete secret db-credentials file-credentials
rm -f *.yaml app.properties
```
## Security Tips

* Secrets are base64 encoded, not encrypted by default.

* Use RBAC to limit access.

* Use external secret managers for production (e.g., HashiCorp Vault, AWS Secrets Manager).

* Avoid printing or logging Secret values.

* Set restrictive permissions for mounted files.

* Performance Notes

* ConfigMaps and Secrets have a 1MB size limit.

* Mounted files may take up to 60 seconds to refresh after updates.

* Environment variable changes require Pod restarts.

## ⚙️ Troubleshooting

Pod not starting:
```
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```
ConfigMap/Secret not found:
```
kubectl get configmaps
kubectl get secrets
```

File not updating after ConfigMap change:
Wait up to 60 seconds or restart the Pod.

## 🏁 Conclusion

In this lab, you successfully:

* Created ConfigMaps and Secrets using literals and files.

* Used them as environment variables and mounted volumes.

* Applied configurations to both Pods and Deployments.

* Updated existing ConfigMaps and Secrets dynamically.

## Why It Matters

Configuration management separates code from configuration, improves security, supports environment-specific setups, and simplifies updates without rebuilding containers.

These concepts are essential for real-world Kubernetes work and certifications like KCNA and CKA, helping you build scalable, secure, and configurable cloud-native applications.

🧰 Tools Used

* Kubernetes
* kubectl
* Nginx
* YAML
* Linux CLI

## Author: Abdullah Saleem 
