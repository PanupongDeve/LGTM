#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Note: For cleanup, we use '|| true' to ensure the script continues even if a resource is already gone.
set -e

TARGET_CONTEXT="k3s-local"
NAMESPACE="lgtm"

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

echo "🧹 Starting LGTM Stack Cleanup..."

# 1. Uninstall Helm releases
echo "🗑️  Uninstalling Alloy..."
helm uninstall alloy -n $NAMESPACE 2>/dev/null || echo "⚠️  Alloy release not found."

echo "🗑️  Uninstalling Grafana..."
helm uninstall grafana -n $NAMESPACE 2>/dev/null || echo "⚠️  Grafana release not found."

echo "🗑️  Uninstalling Loki..."
helm uninstall loki -n $NAMESPACE 2>/dev/null || echo "⚠️  Loki release not found."

echo "🗑️  Uninstalling Prometheus..."
helm uninstall prometheus -n $NAMESPACE 2>/dev/null || echo "⚠️  Prometheus release not found."

# 2. Remove Namespace
echo "🔥 Removing namespace '$NAMESPACE'..."
kubectl delete namespace $NAMESPACE 2>/dev/null || echo "⚠️  Namespace '$NAMESPACE' not found."

echo "---------------------------------------------------"
echo "✨ Cleanup complete!"
echo "---------------------------------------------------"
