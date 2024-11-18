# Retool Dashboard
###### Indended purpose of this dashboard is for easy management of self-managed Kubernetes clusters with nodes running on Google Compute Engine

## Requirements
##### 1. Retool account / self-hosted backend
##### 2. Kubernetes cluster
##### 3. Prometheus (Pod)
##### 4. NodeExporter (Pod)
   - As DaemonSet

### Features
##### 1. Insights into GCE instances and their metrics 
- Instance: status, name, zone internal & external IP, machine type project and instance ID
- Metrics: CPU, RAM, DISK 
         
##### 2. Insights into Kubernetes namespaces and their corresponing pods
- Pods: status, name, node, pod IP, age and restart count


### Installation & Configuration
1. Follow this tutorial on [how to install retool backend](https://retool.com/self-hosted)
2. Clone the repository
3. Upload the contents to your retool environment
4. Configure the necessary settings
   
## Configuring Prometheus
###### In order for the dashboard to acquire necessary data it need access to Prometheus with NodeExporter
Prometheus needs to be configured in the specific way so I will share the manifests here:

##### Create a dedicated namespace
```bash
kubectl create ns monitoring
```
##### Create a directory
```bash
mkdir monitoring && cd monitoring
```

#####
```yaml
# prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:latest
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: config-volume
              mountPath: /etc/prometheus
            - name: prometheus-storage
              mountPath: /prometheus
      volumes:
        - name: config-volume
          configMap:
            name: prometheus-config
        - name: prometheus-storage
          persistentVolumeClaim:
            claimName: prometheus-storage
```

```yaml
# prometheus-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: 'node-exporter'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_namespace]
            action: keep
            regex: node-exporter;monitoring
          # Add the following relabel_configs to get node IP and hostname
          - source_labels: [__meta_kubernetes_node_name]
            target_label: node
          - source_labels: [__meta_kubernetes_pod_node_name]
            target_label: instance_ip
        metrics_path: /metrics
```

```yaml
# prometheus-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
  - apiGroups: [""]
    resources: ["services", "endpoints", "pods"]
    verbs: ["get", "list", "watch"]
```

```yaml
# prometheus-clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: monitoring
roleRef:
  kind: ClusterRole
  name: prometheus
  apiGroup: rbac.authorization.k8s.io
```

## Persistent Volume Claim - Service & Service Account Manifests

```yaml
# prometheus-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-storage
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: local-path
```

```yaml
# prometheus-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
    - port: 9090
      targetPort: 9090
      nodePort: 30090  # Choose a unique NodePort in the 30000-32767 range
  type: NodePort
```

```yaml
# prometheus-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
```

## NodeExporter Manifests

```yaml
# node-exporter-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        args:
          - "--path.procfs=/host/proc"
          - "--path.sysfs=/host/sys"
        env:
          - name: NODE_IP
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
        ports:
          - containerPort: 9100
        volumeMounts:
          - name: proc
            mountPath: /host/proc
            readOnly: true
          - name: sys
            mountPath: /host/sys
            readOnly: true
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: sys
          hostPath:
            path: /sys

```

```yaml
# node-exporter-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    app: node-exporter
  ports:
    - port: 9100
      targetPort: 9100
  clusterIP: None  # Headless service for direct pod access
```

## Final
##### Leave the directory 
```bash
cd ..
```

##### Apply the manifests
```bash
kubectl apply -f monitoring
```

##### Run the following command
```bash
kubectl get all -n monitoring
```

##### Previous command should return something like this
```bash
NAME                              READY   STATUS    RESTARTS       AGE
pod/node-exporter-875cz           1/1     Running   3 (174m ago)   4d1h
pod/node-exporter-9dtxp           1/1     Running   3 (174m ago)   4d1h
pod/node-exporter-b2dgb           1/1     Running   5 (174m ago)   4d1h
pod/node-exporter-xvftf           1/1     Running   3 (174m ago)   4d1h
pod/prometheus-788d686849-h6c8j   1/1     Running   3 (174m ago)   4d1h

NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/node-exporter   ClusterIP   None           <none>        9100/TCP         7d10h
service/prometheus      NodePort    10.43.16.208   <none>        9090:30090/TCP   7d10h

NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/node-exporter   4         4         4       4            4           <none>          7d10h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus   1/1     1            1           7d10h

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-588db56897   0         0         0       7d10h
replicaset.apps/prometheus-788d686849   1         1         1       7d9h
```

## Explanation
##### With this setup we deployed Prometheus inside a pod as well as NodeExporter in a pod on each node within the cluster. This allows us to gather metrics from each node with a centrilized monitoring system
