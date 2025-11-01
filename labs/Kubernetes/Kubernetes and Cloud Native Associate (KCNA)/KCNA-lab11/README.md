# Lab 11: Managing Kubernetes Volumes and Persistent Storage 💾

## Overview

This lab focused on understanding and managing persistent storage in Kubernetes. I learned how to work with **Volumes**, **PersistentVolumes (PV)**, and **PersistentVolumeClaims (PVC)** to ensure data remains available even when pods are deleted or recreated.

---

## Objectives

By completing this lab, I was able to:

* Understand the difference between Volumes, PVs, and PVCs
* Create and configure PersistentVolumes with custom storage classes
* Request storage resources using PersistentVolumeClaims
* Deploy applications that utilize persistent storage
* Verify data persistence after pod restarts and deletions
* Troubleshoot common storage issues
* Apply best practices for managing persistent data in Kubernetes

---

## Prerequisites

Before starting, I made sure I was comfortable with:

* Basic Kubernetes concepts (Pods, Deployments, Services)
* YAML manifest files
* Linux CLI commands
* File systems and storage basics

The lab was performed on a pre-configured Kubernetes environment provided by Al Nafi, using Minikube with `kubectl` ready to go.

---

## Step 1: Verify Cluster and Namespace

I started by checking the cluster and creating a dedicated namespace:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get storageclass

kubectl create namespace storage-lab
kubectl config set-context --current --namespace=storage-lab
Step 2: PersistentVolume (PV) and PersistentVolumeClaim (PVC)
Create a PersistentVolume
I created persistent-volume.yaml defining a 1Gi local storage volume using hostPath for Minikube:

YAML

apiVersion: v1
kind: PersistentVolume
metadata:
  name: lab-pv
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/lab-data"
  persistentVolumeReclaimPolicy: Retain
Applied and verified:

Bash

kubectl apply -f persistent-volume.yaml
kubectl get pv
Create a PersistentVolumeClaim
I created a PVC requesting 500Mi, which bound automatically to the custom PV:

YAML

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
Applied and confirmed the Bound status:

Bash

kubectl apply -f persistent-volume-claim.yaml
kubectl get pvc
Step 3: Deploy an Application Using Persistent Storage
I deployed a simple BusyBox Deployment that utilizes the PVC to write data.

YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: storage-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-app
  template:
    metadata:
      labels:
        app: storage-app
    spec:
      containers:
      - name: storage-container
        image: busybox:1.35
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo $(date) >> /data/timestamps.log; sleep 30; done"]
        volumeMounts:
        - name: storage-volume
          mountPath: /data
      volumes:
      - name: storage-volume
        persistentVolumeClaim:
          claimName: lab-pvc
After applying and confirming it was running:

Bash

kubectl apply -f storage-app-deployment.yaml
kubectl get pods
kubectl exec <pod-name> -- cat /data/timestamps.log
# Confirmed timestamps were being written.
Step 4: Verify Data Persistence
I tested persistence by deleting and recreating the application.

Bash

kubectl delete deployment storage-app
kubectl apply -f storage-app-deployment.yaml
# Checked the logs of the new pod:
kubectl exec <new-pod-name> -- cat /data/timestamps.log
✅ Result: The log file still contained the original timestamps, proving data persisted even after the pod and deployment were recreated.

Step 5: Monitoring and Troubleshooting
I practiced troubleshooting common issues like:

PVC stuck in Pending state: Debugged by checking PV availability and storageClassName mismatch.

Pod unable to mount volume: Checked YAML syntax and PV/PVC status.

Data loss: Understood the importance of the Retain reclaim policy.

Step 6: Cleanup
To clean up all resources safely:

Bash

# Delete application (to stop writing data)
kubectl delete deployment storage-app

# Delete the PVC (unbounds the PV)
kubectl delete pvc lab-pvc

# Delete the PV (since the reclaim policy is Retain, this must be done manually)
kubectl delete pv lab-pv

# Delete the namespace
kubectl delete namespace storage-lab
✅ Key Takeaways
This lab gave me a strong understanding of how Kubernetes handles stateful workloads:

PVs represent the actual storage capacity available in the cluster.

PVCs are requests for that storage, allowing the application to consume it without knowing the underlying details.

The Retain reclaim policy is crucial for preventing accidental data loss during testing and in production database environments.

Storage is mounted via a Volume defined in the Pod spec, which references the bound PVC.

💡 Why This Matters
Persistent storage is essential for any production workload that requires data durability (e.g., databases, content management systems, file services). This knowledge is a core requirement for real-world DevOps/AIOps roles and the KCNA certification.

🧭 Next Steps
After this lab, my plan is to:

Explore dynamic provisioning using StorageClasses.

Practice StatefulSets for database deployments.

Learn volume snapshot and backup strategies.
