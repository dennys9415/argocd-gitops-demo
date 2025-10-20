# ArgoCD GitOps Demo 🚀

A comprehensive demonstration of GitOps practices using ArgoCD and Kubernetes. This repository showcases modern application deployment, multi-environment management, and infrastructure as code using Git as the single source of truth.

## Structure

```
argocd-gitops-demo/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # CI for application changes
│   │   ├── gitops-sync.yml           # GitOps synchronization
│   │   └── security-scan.yml         # Security scanning
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
├── apps/
│   ├── base/
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── overlays/
│   │   ├── development/
│   │   │   ├── kustomization.yaml
│   │   │   ├── patch-deployment.yaml
│   │   │   └── configmap.yaml
│   │   ├── staging/
│   │   │   ├── kustomization.yaml
│   │   │   ├── patch-deployment.yaml
│   │   │   └── hpa.yaml
│   │   └── production/
│   │       ├── kustomization.yaml
│   │       ├── patch-deployment.yaml
│   │       ├── hpa.yaml
│   │       └── network-policy.yaml
│   └── of-the-day/                  # Demo application
│       ├── kustomization.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── configmap.yaml
├── infrastructure/
│   ├── argocd/
│   │   ├── application.yaml
│   │   ├── project.yaml
│   │   └── rbac.yaml
│   ├── namespaces/
│   │   ├── development.yaml
│   │   ├── staging.yaml
│   │   └── production.yaml
│   ├── monitoring/
│   │   ├── grafana/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── datasources.yaml
│   │   └── prometheus/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       └── config.yaml
│   └── networking/
│       ├── ingress-controller.yaml
│       └── cert-manager.yaml
├── scripts/
│   ├── setup-cluster.sh
│   ├── deploy-argocd.sh
│   ├── bootstrap-apps.sh
│   └── health-check.sh
├── docs/
│   ├── getting-started.md
│   ├── concepts.md
│   ├── best-practices.md
│   └── troubleshooting.md
├── examples/
│   ├── multi-cluster/
│   │   ├── cluster-config.yaml
│   │   └── app-of-apps.yaml
│   ├── blue-green/
│   │   ├── deployment-blue.yaml
│   │   ├── deployment-green.yaml
│   │   └── service.yaml
│   └── canary/
│       ├── deployment-primary.yaml
│       ├── deployment-canary.yaml
│       └── service.yaml
├── helm-charts/
│   └── sample-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── ingress.yaml
│       └── crds/
├── LICENSE
├── README.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
└── .gitignore
```

## 📖 What is GitOps?

GitOps is a modern approach to continuous delivery that uses Git as the single source of truth for declarative infrastructure and applications. This repository demonstrates:

- **Git as Source of Truth**: All changes go through Git
- **Declarative Configuration**: Infrastructure defined as code
- **Automated Synchronization**: ArgoCD automatically applies changes
- **Observability**: Full visibility into deployment states

## 🏗️ Architecture

```
Git Repository (This Repo)
↓
ArgoCD (Controller)
↓
Kubernetes Clusters
↓
Applications (Running)
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (v1.20+)
- kubectl configured
- Helm (v3.0+)

### 1. Setup Kubernetes Cluster

```bash
# Using kind for local development
./scripts/setup-cluster.sh
```

### 2. Install ArgoCD

```bash
./scripts/deploy-argocd.sh
```

### 3. Bootstrap Applications

```bash
./scripts/bootstrap-apps.sh
```
### 4. Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open http://localhost:8080
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 📦 What's Included

### Applications

* App of the Day: Sample microservice demonstrating GitOps workflows
* Multi-environment: Development, Staging, Production with Kustomize
* Helm Support: Example Helm chart deployment

### Infrastructure

* ArgoCD Configuration: Application, Project, and RBAC setups
* Monitoring Stack: Prometheus and Grafana for observability
* Networking: Ingress controller and TLS configuration

### Deployment Strategies

* Blue-Green: Zero-downtime deployments
* Canary: Gradual rollout with traffic splitting
* Multi-cluster: Deployment across multiple clusters

## 🛠️ Usage Examples

### Deploy to Development

```bash
# Make changes to apps/overlays/development/
git add .
git commit -m "feat: update development configuration"
git push origin main
# ArgoCD automatically syncs changes
```

### Promote to Production

```bash
# Update the image tag in apps/overlays/production/
kubectl patch app production-app -n argocd --type merge -p '{"spec": {"source": {"targetRevision": "v1.2.3"}}}'
```

### Rollback Deployment

```bash
# Revert to previous commit
git revert HEAD
git push origin main
# Or use ArgoCD UI to sync to previous version
```

## 🔧 Configuration

### Environment-specific Configs

```yaml
# apps/overlays/development/patch-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-of-the-day
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: app
        env:
        - name: ENVIRONMENT
          value: "development"
```

### ArgoCD Application Definition

```yaml
# infrastructure/argocd/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-the-day
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/argocd-gitops-demo
    targetRevision: HEAD
    path: apps/of-the-day
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 🎯 Demo Scenarios

### 1. Basic GitOps Flow

* Make code change → Commit → Push → ArgoCD syncs automatically

### 2. Rollback Scenario

* Introduce breaking change → Observe failure → Git revert → Automatic recovery

### 3. Multi-environment Promotion

* Develop → Test in Staging → Approve → Promote to Production

### 4. Canary Deployment

* Deploy to 10% of users → Monitor → Gradually increase to 100%

## 📊 Monitoring & Observability

* ArgoCD UI: Application health and sync status
* Grafana Dashboards: Application metrics and performance
* Prometheus Alerts: Automated alerting on issues
* Kubernetes Events: Detailed deployment events

## 🔒 Security

* RBAC: Role-based access control for ArgoCD
* Secrets Management: External secrets with Sealed Secrets or Vault
* Network Policies: Restrict pod-to-pod communication
* Pod Security: Security contexts and policies

## 🤝 Contributing

We welcome contributions! Please see our Contributing Guide.

## 📚 Learning Resources

* ArgoCD Documentation
* GitOps Principles
* Kustomize Guide
* Helm Charts

## 🆘 Troubleshooting

See our Troubleshooting Guide for common issues and solutions.

## 📄 License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

## 🙏 Acknowledgments

* ArgoCD team for the amazing GitOps tool
* Kubernetes community
* CNCF for fostering cloud-native technologies