# Contributing to ArgoCD GitOps Demo

We love your input! We want to make contributing to this project as easy and transparent as possible.

## Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test your changes locally
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## Contribution Guidelines

### Adding New Applications
- Follow the existing structure in `apps/` directory
- Include proper health checks and resource limits
- Add to appropriate ArgoCD application definitions
- Update documentation

### Adding New Features
- Update relevant documentation
- Add examples if applicable
- Test with different Kubernetes versions
- Follow security best practices

### Reporting Bugs
- Use the bug report template
- Include steps to reproduce
- Provide Kubernetes version and ArgoCD version
- Include relevant logs

## Code Style

### YAML Files
- Use 2-space indentation
- Include comments for complex configurations
- Use consistent naming conventions
- Follow Kubernetes best practices

### Shell Scripts
- Include proper error handling
- Use meaningful variable names
- Include usage documentation
- Make executable with `chmod +x`

## Testing

### Local Testing
```bash
# Set up local cluster
./scripts/setup-cluster.sh

# Deploy ArgoCD
./scripts/deploy-argocd.sh

# Test your changes
./scripts/bootstrap-apps.sh
```

## Validation

* All Kubernetes manifests should pass kubectl apply --dry-run
* Kustomize overlays should build successfully
* No secrets committed to repository

## Documentation

* Update README.md for significant changes
* Add examples for new features
* Include troubleshooting steps
* Keep getting started guide updated

## Questions?

* Open an issue for questions
* Check existing documentation
* Review ArgoCD documentation

Thank you for contributing! 🚀