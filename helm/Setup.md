# LGTM Stack Setup Guide (Helm)

This guide provides step-by-step instructions to deploy the observability stack (Prometheus, Loki, Grafana, and Alloy) into your Kubernetes cluster using Helm.

## Prerequisites

- A running Kubernetes cluster (e.g., K3s, Minikube, or EKS).
- `kubectl` configured to access your cluster.
- `helm` installed on your local machine.

## 1. Create Namespace

First, create the `lgtm` namespace where all components will be hosted:

```bash
kubectl apply -f k8s-config/namespace.yaml
```

## 2. Add Helm Repositories

Add the necessary Helm repositories for Prometheus and Grafana:

```bash
chmod +x scripts/1-setup-helm-repo.sh
./scripts/1-setup-helm-repo.sh
```

## 3. Install Components

Install the stack components in the following order. Make sure you are in the `helm/` directory.

### 3.1 Prometheus
Installs the Prometheus server and Node Exporter for metrics collection.

```bash
chmod +x scripts/2-prometheus-install.sh
./scripts/2-prometheus-install.sh
```

### 3.2 Loki
Installs Loki in `SingleBinary` mode for log aggregation.

```bash
chmod +x scripts/3-setup-loki.sh
./scripts/3-setup-loki.sh
```

### 3.3 Grafana
Installs Grafana for visualization.

```bash
chmod +x scripts/4-setup-grafana.sh
./scripts/4-setup-grafana.sh
```

### 3.4 Alloy
Installs Grafana Alloy as a collector to ship logs to Loki.

```bash
chmod +x scripts/5-setup-alloy.sh
./scripts/5-setup-alloy.sh
```

## 4. Post-Installation & Access

### 4.1 Accessing Grafana

**Option 1: Port Forwarding**
```bash
export POD_NAME=$(kubectl get pods --namespace lgtm -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace lgtm port-forward $POD_NAME 3000
```
Then visit `http://localhost:3000`.

**Option 2: NodePort**
Apply the NodePort service to access Grafana via any Node IP on port `31501`:
```bash
kubectl apply -f k8s-config/grafana-np.yaml
```

### 4.2 Credentials
- **Username:** `admin`
- **Password:** The password is set in `values/grafana-values.yaml` (default: `1q2w3e4r5t6y`). 
  *Note: If not specified in values, retrieve it via:*
  ```bash
  kubectl get secret --namespace lgtm grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```

## 5. Configuration Details

- **Loki:** Configured with a 24h retention period and uses internal Minio for storage (see `values/loki-values.yaml`).
- **Alloy:** Automatically discovers pod logs and system logs (`/var/log/syslog`) and forwards them to Loki (see `values/alloy-values.yaml`).
- **Persistence:** Grafana uses `local-path` storage class by default with 5Gi (see `values/grafana-values.yaml`).
