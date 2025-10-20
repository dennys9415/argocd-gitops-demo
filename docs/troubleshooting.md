# Troubleshooting Guide

## Common Issues and Solutions

### ArgoCD Issues

#### Application Stuck in "OutOfSync" State

**Symptoms**: Application shows "OutOfSync" but no changes are being applied

**Possible Causes**:
1. Sync policy not set to automated
2. Pruning disabled
3. Resource hooks blocking sync

**Solutions**:

```bash
# Check sync policy
argocd app get <app-name>

# Enable automated sync
argocd app set <app-name> --sync-policy automated

# Enable pruning
argocd app set <app-name> --auto-prune

# Force sync
argocd app sync <app-name>
```

**Application Stuck in "Progressing" State**

**Symptoms:** Application shows "Progressing" for extended period

**Possible Causes:**

1. Resource quotas exceeded
2. Image pull errors
3. Liveness/readiness probe failures

**Solutions:**

```bash
# Check resource quotas
kubectl describe quota -n <namespace>

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check image pull secrets
kubectl get secrets -n <namespace>
```

**ArgoCD Cannot Access Git Repository**

**Symptoms:** Application shows "Unknown" or "Missing" status

**Possible Causes:**

1. Invalid repository URL
2. Authentication issues
3. Network connectivity problems

**Solutions:**

```bash
# Test repository access
argocd repo list

# Add repository with proper credentials
argocd repo add https://github.com/org/repo.git \
  --username <username> \
  --password <token>

# Check network connectivity
kubectl exec -it <argocd-pod> -n argocd -- nslookup github.com
```

### Kubernetes Issues

**Pods Not Starting**

vSymptoms:** Pods stuck in "Pending" or "ContainerCreating" state

**Possible Causes:**

1. Insufficient resources
2. Image pull errors
3. Persistent volume claims pending

**Solutions:**

```bash
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl top nodes

# Check persistent volumes
kubectl get pv,pvc -n <namespace>
```

**Services Not Accessible**

**Symptoms:** Services not responding or connection refused

**Possible Causes:**

1. Service selector mismatch
2. Network policies blocking traffic
3. Incorrect port configuration

**Solutions:**

```bash
# Verify service endpoints
kubectl get endpoints <service-name> -n <namespace>

# Check network policies
kubectl get networkpolicies -n <namespace>

# Test service internally
kubectl exec -it <pod-name> -n <namespace> -- curl http://<service-name>
```

### Kustomize Issues

**Kustomize Build Failures**

**Symptoms:** Error when building Kustomize overlays

**Possible Causes:**

1. Missing base resources
2. Invalid patches
3. Variable substitution errors

**Solutions:**

```bash
# Test Kustomize build locally
kustomize build apps/overlays/development

# Check for missing resources
kubectl apply -k apps/overlays/development --dry-run=client

# Validate patches
kubectl apply -k apps/overlays/development --dry-run=server
```

**Environment-Specific Configurations Not Applied**

**Symptoms:** Changes in overlays not reflected in deployed resources

**Possible Causes:**

1. Incorrect kustomization.yaml
2. Patch files not referenced
3. Wrong overlay selected

**Solutions:**

```bash
# Verify kustomization.yaml structure
cat apps/overlays/development/kustomization.yaml

# Check what resources would be generated
kustomize build apps/overlays/development

# Verify ArgoCD is using correct path
argocd app get <app-name> -o yaml | grep path
```

### Networking Issues

**Ingress Not Working**

**Symptoms:** Ingress resources not routing traffic

**Possible Causes:**

1. Ingress controller not installed
2. Incorrect host configuration
3. TLS certificate issues

**Solutions:**

```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Verify ingress resource
kubectl describe ingress <ingress-name> -n <namespace>

# Check ingress controller logs
kubectl logs -f <ingress-controller-pod> -n ingress-nginx
```

**DNS Resolution Problems**

**Symptoms:** Services cannot resolve internal DNS names

**Possible Causes:**

1. CoreDNS issues
2. Network policies blocking DNS
3. Incorrect service names

**Solutions:**

```bash
# Test DNS resolution from pod
kubectl exec -it <pod-name> -n <namespace> -- nslookup <service-name>

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS configuration
kubectl get configmap -n kube-system coredns -o yaml
```

### Resource Management Issues

**Resource Quota Exceeded**

**Symptoms:** Pod creation fails with quota exceeded errors

**Possible Causes:**

1. Resource requests too high
2. Too many replicas
3. Quota limits too low

**Solutions:**

```bash
# Check resource quotas
kubectl describe quota -n <namespace>

# Check resource usage
kubectl top pods -n <namespace>

# Adjust resource requests or quotas
```

**Node Pressure**

**Symptoms:** Nodes reporting memory or disk pressure

**Possible Causes:**

1. Insufficient cluster capacity
2. Memory leaks in applications
3. Logs filling disk space

**Solutions:**

```bash
# Check node status
kubectl describe node <node-name>

# Check resource usage
kubectl top nodes

# Clean up unused resources
kubectl get pods --all-namespaces --field-selector=status.phase==Succeeded -o json | kubectl delete -f -
```

### Debugging Commands

**General Debugging**

```bash
# Get overall cluster status
kubectl get all --all-namespaces

# Check node status
kubectl get nodes -o wide

# Check events across all namespaces
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

**ArgoCD Specific**

```bash
# List all applications
argocd app list

# Get application details
argocd app get <app-name>

# Check application resources
argocd app resources <app-name>

# View application sync status
argocd app history <app-name>

# Check ArgoCD server logs
kubectl logs -f deployment/argocd-server -n argocd
```

**Network Debugging**

```bash
# Check service endpoints
kubectl get endpoints

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -- sh

# Check network policies
kubectl get networkpolicies --all-namespaces

# Verify DNS resolution
kubectl run dns-test --image=busybox --rm -it -- nslookup <service-name>
```

## Performance Issues

**Slow Sync Operations**

**Symptoms:** ArgoCD sync operations taking too long

**Possible Causes:**

1. Large number of resources
2. Network latency to Git repository
3. Resource constraints on ArgoCD

**Solutions:**

```bash
# Check ArgoCD resource usage
kubectl top pods -n argocd

# Monitor sync operations
argocd app get <app-name> --refresh

# Optimize repository structure
```

**High Resource Usage**

**Symptoms:** Cluster resources consistently high

**Possible Causes:**

1. Inefficient resource requests
2. Memory leaks
3. Too many running pods

**Solutions:**

```bash
# Identify resource hogs
kubectl top pods --all-namespaces --sort-by=cpu
kubectl top pods --all-namespaces --sort-by=memory

# Check for resource recommendations
# Install vertical-pod-autoscaler for suggestions
```

### Logging and Monitoring

**Enable Detailed Logging**

```bash
# Increase ArgoCD log level
kubectl patch deployment argocd-server -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","args":["--loglevel","debug"]}]}}}}'

# Check application logs
kubectl logs -f <pod-name> -n <namespace>

# Follow multiple pods
kubectl logs -f -l app=<app-label> -n <namespace>
```

**Monitoring Setup**

```bash
# Check if monitoring is working
kubectl get pods -n monitoring

# Access Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090

# Access Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000
```
## Getting Help

### Collect Debug Information

```bash
# System information
kubectl cluster-info dump > cluster-dump.log

# ArgoCD information
argocd version > argocd-version.log
argocd app list > app-list.log

# Resource information
kubectl get all --all-namespaces > all-resources.log
```

### Community Resources

* ArgoCD Documentation
* Kubernetes Documentation
* GitOps.tech
* CNCF Slack - #argo-cd channel