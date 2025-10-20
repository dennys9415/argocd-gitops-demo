#!/bin/bash

set -e

echo "🚀 Bootstrapping applications with ArgoCD..."

# Create namespaces
echo "📁 Creating namespaces..."
kubectl apply -f infrastructure/namespaces/

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=600s

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login to ArgoCD
echo "🔐 Logging into ArgoCD..."
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Create applications
echo "📦 Creating ArgoCD applications..."

# App of the Day
argocd app create app-of-the-day \
  --repo https://github.com/your-username/argocd-gitops-demo \
  --path apps/of-the-day \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Development environment
argocd app create app-development \
  --repo https://github.com/your-username/argocd-gitops-demo \
  --path apps/overlays/development \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace development \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Staging environment
argocd app create app-staging \
  --repo https://github.com/your-username/argocd-gitops-demo \
  --path apps/overlays/staging \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace staging \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Production environment
argocd app create app-production \
  --repo https://github.com/your-username/argocd-gitops-demo \
  --path apps/overlays/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Sync all applications
echo "🔄 Syncing applications..."
argocd app sync app-of-the-day
argocd app sync app-development
argocd app sync app-staging
argocd app sync app-production

# Wait for applications to be healthy
echo "⏳ Waiting for applications to be healthy..."
argocd app wait app-of-the-day --health
argocd app wait app-development --health
argocd app wait app-staging --health
argocd app wait app-production --health

echo "✅ Application bootstrap completed!"
echo ""
echo "📊 Check application status:"
echo "   argocd app list"
echo ""
echo "🌐 Access ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   https://localhost:8080"