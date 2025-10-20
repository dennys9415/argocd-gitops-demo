#!/bin/bash

set -e

echo "🚀 Setting up Kubernetes cluster..."

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "📥 Installing kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

# Create cluster configuration
cat > kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

# Create cluster
echo "📦 Creating Kubernetes cluster with kind..."
kind create cluster --name gitops-demo --config kind-config.yaml

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready node/gitops-demo-control-plane --timeout=300s

# Create namespaces
echo "📁 Creating namespaces..."
kubectl apply -f infrastructure/namespaces/

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Kubernetes cluster setup completed!"
echo ""
echo "🔧 Next steps:"
echo "   ./scripts/deploy-argocd.sh"
echo "   ./scripts/bootstrap-apps.sh"