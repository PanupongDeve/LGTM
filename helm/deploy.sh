#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

TARGET_CONTEXT="k3s-local"

echo "🔍 Checking Kubernetes context..."

# Switch context
if command -v kubectx >/dev/null 2>&1; then
    echo "🔄 Switching to context: $TARGET_CONTEXT"
    kubectx $TARGET_CONTEXT
else
    echo "⚠️  'kubectx' not found, attempting to use 'kubectl config use-context'"
    kubectl config use-context $TARGET_CONTEXT
fi

# Validate context
CURRENT_CONTEXT=$(kubectl config current-context)
if [ "$CURRENT_CONTEXT" != "$TARGET_CONTEXT" ]; then
    echo "❌ Error: Current context is '$CURRENT_CONTEXT', but '$TARGET_CONTEXT' is required."
    exit 1
fi

echo "✅ Validated context: $CURRENT_CONTEXT"

echo "🚀 Starting LGTM Stack Deployment..."

# 1. Create Namespace
echo "📦 Creating namespace 'lgtm'..."
kubectl apply -f k8s-config/namespace.yaml

# 2. Setup Helm Repositories
echo "📥 Setting up Helm repositories..."
chmod +x scripts/1-setup-helm-repo.sh
./scripts/1-setup-helm-repo.sh

# 3. Install Prometheus
echo "🔥 Installing Prometheus..."
chmod +x scripts/2-prometheus-install.sh
./scripts/2-prometheus-install.sh

# 4. Install Loki
echo "🪵 Installing Loki..."
chmod +x scripts/3-setup-loki.sh
./scripts/3-setup-loki.sh

# 5. Install Grafana
echo "📊 Installing Grafana..."
chmod +x scripts/4-setup-grafana.sh
./scripts/4-setup-grafana.sh

# 6. Install Alloy
echo "📡 Installing Alloy (Collector)..."
chmod +x scripts/5-setup-alloy.sh
./scripts/5-setup-alloy.sh

# 7. Apply NodePort for Grafana (Optional but recommended)
echo "🌐 Applying NodePort for Grafana..."
kubectl apply -f k8s-config/grafana-np.yaml

echo "---------------------------------------------------"
echo "✅ LGTM Stack deployed successfully!"
echo "---------------------------------------------------"
echo "Check pods status:"
echo "kubectl get pods -n lgtm"
echo ""
echo "Access Grafana at: http://<Node-IP>:31501"
echo "Username: admin"
echo "Password: (See values/grafana-values.yaml)"
echo "---------------------------------------------------"
