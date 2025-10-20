#!/bin/bash

set -e

echo "🚀 Deploying ArgoCD..."

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Install ArgoCD CLI (Linux/Mac)
if ! command -v argocd &> /dev/null; then
    echo "📥 Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
fi

# Get initial admin password
echo "🔐 ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Port forward for access
echo "🌐 ArgoCD UI will be available at https://localhost:8080"
echo "📝 Username: admin"
echo "🔑 Password: <see above>"
echo ""
echo "To access the UI, run: kubectl port-forward svc/argocd-server -n argocd 8080:443"

# Apply ArgoCD configuration
echo "⚙️ Applying ArgoCD configuration..."
kubectl apply -f infrastructure/argocd/project.yaml
kubectl apply -f infrastructure/argocd/application.yaml
kubectl apply -f infrastructure/argocd/rbac.yaml

echo "✅ ArgoCD deployment completed!"