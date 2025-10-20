#!/bin/bash

set -e

echo "🔍 Running health checks..."

# Check cluster status
echo "📊 Cluster status:"
kubectl cluster-info

# Check node status
echo "🖥️  Node status:"
kubectl get nodes

# Check ArgoCD status
echo "🔄 ArgoCD status:"
kubectl get pods -n argocd

# Check application status
echo "📦 Application status:"
kubectl get applications -n argocd

# Check all namespaces
echo "📁 Namespace status:"
kubectl get namespaces

# Check deployments
echo "🚀 Deployment status:"
for ns in default development staging production; do
    echo "Namespace: $ns"
    kubectl get deployments -n $ns 2>/dev/null || echo "No deployments in $ns"
    echo "---"
done

# Check services
echo "🔌 Service status:"
for ns in default development staging production; do
    echo "Namespace: $ns"
    kubectl get services -n $ns 2>/dev/null || echo "No services in $ns"
    echo "---"
done

echo "✅ Health checks completed!"