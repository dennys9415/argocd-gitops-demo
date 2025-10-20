# GitOps Best Practices

## Repository Structure

### Organize by Application and Environment

```
├── apps/
│ ├── app-1/
│ │ ├── base/
│ │ └── overlays/
│ │ ├── development/
│ │ ├── staging/
│ │ └── production/
│ └── app-2/
│ ├── base/
│ └── overlays/
└── infrastructure/
├── monitoring/
├── networking/
└── security/
```

### Use Meaningful Names

- Application names: `user-service`, `payment-gateway`
- Environment names: `development`, `staging`, `production`
- Resource names: Descriptive and consistent

## Kubernetes Manifests

### Use Labels and Annotations

```yaml
metadata:
  labels:
    app: user-service
    version: v1.2.3
    environment: production
  annotations:
    description: "User management microservice"
    git-repo: "https://github.com/org/user-service"
```

### Implement Resource Limits

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

### Configure Health Checks

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## ArgoCD Configuration

### Application Best Practices

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: user-service
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/org/gitops-repo
    targetRevision: HEAD
    path: apps/user-service/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: user-service
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ApplyOutOfSyncOnly=true
```

### Use AppProjects for Access Control

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production applications
  sourceRepos:
  - "https://github.com/org/gitops-repo"
  destinations:
  - namespace: "*-prod"
    server: https://kubernetes.default.svc
  roles:
  - name: admin
    policies:
    - p, proj:production:admin, applications, *, production/*, allow
```

## Security Practices

### Implement RBAC

* Use least privilege principle
* Separate development and production access
* Regular access reviews

### Network Security

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Container Security

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
```

## Monitoring and Observability

### Application Metrics

* Expose Prometheus metrics
* Configure alerting rules
* Set up Grafana dashboards

### ArgoCD Monitoring

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-metrics
  namespace: argocd
data:
  serviceMonitor.yaml: |
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: argocd-server
    spec:
      selector:
        matchLabels:
          app.kubernetes.io/name: argocd-server
      endpoints:
      - port: metrics
```

## Deployment Strategies

### Blue-Green Deployment

1. Deploy new version alongside old version
2. Test new version thoroughly
3. Switch traffic to new version
4. Keep old version for quick rollback

### Canary Deployment

1. Deploy to small percentage of users
2. Monitor metrics and logs
3. Gradually increase traffic
4. Full rollout or rollback based on results

### Automated Rollbacks

```yaml
spec:
  syncPolicy:
    automated:
      selfHeal: true
    retry:
      limit: 2
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

## Git Practices

### Commit Strategy

* Use conventional commit messages
* Include issue references in commits
* Squash and merge feature branches

### Branch Protection

* Require PR reviews for main branch
* Enforce status checks
* Prevent force pushes to main branch

### Code Review Checklist

* Kubernetes manifests are valid
* Resource limits are appropriate
* Security contexts are configured
* Health checks are implemented
* Documentation is updated

## Performance Optimization

### Resource Management

* Right-size resource requests and limits
* Implement Horizontal Pod Autoscaling
* Use cluster autoscaling where appropriate

### Caching Strategies

* Cache dependencies in CI/CD pipelines
* Use image pull secrets efficiently
* Implement application-level caching

## Disaster Recovery

### Backup Strategies

* Regular backups of etcd
* Export ArgoCD application definitions
* Document recovery procedures

### High Availability

* Deploy across multiple availability zones
* Use pod anti-affinity rules
* Implement proper retry mechanisms

## Continuous Improvement

### Regular Reviews

* Monthly security reviews
* Performance optimization reviews
* Cost optimization analysis

### Documentation

* Keep runbooks updated
* Document troubleshooting procedures
* Maintain architecture diagrams