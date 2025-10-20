# Getting Started with ArgoCD GitOps Demo

## Overview

This guide will help you set up a complete GitOps workflow using ArgoCD and Kubernetes.

## Prerequisites

### Required Tools
- **kubectl**: Kubernetes command-line tool
- **Docker**: Container runtime
- **Git**: Version control

### Optional Tools
- **kind**: Kubernetes in Docker (for local development)
- **Helm**: Kubernetes package manager
- **ArgoCD CLI**: ArgoCD command-line interface

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/argocd-gitops-demo.git
cd argocd-gitops-demo
```

### 2. Set Up Local Kubernetes Cluster

```bash
# Using kind (recommended for local development)
./scripts/setup-cluster.sh

# Or using minikube
minikube start --cpus=4 --memory=8192
```

### 3. Install ArgoCD

```bash
./scripts/deploy-argocd.sh
```

### 4. Bootstrap Applications

```bash
./scripts/bootstrap-apps.sh
```

### 5. Access the Demo

```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access sample application
kubectl port-forward svc/app-of-the-day -n default 8081:80
```

## Understanding the Structure

### Application Manifests

* apps/of-the-day/: Sample application demonstrating GitOps
* apps/base/: Base configurations shared across environments
* apps/overlays/: Environment-specific customizations

### Infrastructure

* infrastructure/argocd/: ArgoCD configuration and RBAC
* infrastructure/monitoring/: Prometheus and Grafana setup
* infrastructure/networking/: Ingress and TLS configuration

### Scripts

* scripts/setup-cluster.sh: Creates local Kubernetes cluster
* scripts/deploy-argocd.sh: Installs and configures ArgoCD
* scripts/bootstrap-apps.sh: Deploys all applications

## Your First GitOps Deployment

### 1. Make a Change

Edit the application deployment:

```bash
# Edit the replica count
vim apps/of-the-day/deployment.yaml
```

Change:

```yaml
spec:
  replicas: 3  # Changed from 2
```

### 2. Commit and Push

```bash
git add apps/of-the-day/deployment.yaml
git commit -m "feat: scale up to 3 replicas"
git push origin main
```

### 3. Watch ArgoCD Sync

1. Open ArgoCD UI: https://localhost:8080
2. Observe the app-of-the-day application
3. Watch it automatically sync and scale up

### 4. Verify the Change

```bash
kubectl get pods -l app=app-of-the-day
```

## Next Steps

### Explore Multi-environment Deployment

1. Check the different overlays in apps/overlays/
2. See how each environment has different configurations
3. Practice promoting changes between environments

### Try Deployment Strategies

1. Explore the examples/ directory
2. Try blue-green deployment
3. Experiment with canary releases

### Set Up Monitoring

1. Deploy the monitoring stack
2. Set up Grafana dashboards
3. Configure alerts

## Troubleshooting

### Common Issues

**ArgoCD not syncing**

* Check network connectivity to Git repository
* Verify ArgoCD has correct permissions
* Check application health status

**Application not starting**

* Check container image exists and is accessible
* Verify resource requests and limits
* Check liveness and readiness probes

**Access issues**

* Verify port forwarding is working
* Check firewall rules
* Confirm service types and ports

## Getting Help

* Check the troubleshooting guide
* Open an issue on GitHub
* Check ArgoCD documentation

### Learning Resources

* ArgoCD Documentation
* GitOps Principles
* Kubernetes Documentation
* Kustomize Guide