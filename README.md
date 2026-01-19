# Service Catalog

**Role:** The Pattern (Blueprints)  
**Artifact:** Git Revisions (Tags)  
**Consumers:** ArgoCD (via Fleet)

This repository contains the **Standard Operating Procedures** for deploying software into JetScale clusters. It defines "What a Cluster IS" using **Blueprint Helm Charts**.

## 🏛 Architecture

This repo is **Read-Only** for the clusters. It is the library of valid configurations.

- **`charts/blueprint-aws-standard/`**: A Helm chart that renders ArgoCD `Application` objects for EKS clusters.
- **`charts/blueprint-azure-standard/`**: A Helm chart that renders ArgoCD `Application` objects for AKS clusters.

## 🛠 Developer Workflow

**We do NOT pin artifact versions here.**
This repo defines the *shape* of the deployment. The *version* of the chart is a Helm Parameter (`targetRevision`) injected by `../fleet`.

### Adding a new Capability
1. Edit `charts/blueprint-aws-standard/templates/observability.yaml`.
2. Ensure it uses `{{ .Values.versions.observability }}` for `targetRevision`.
3. Tag a release (e.g., `v1.2.0`).

## 📂 Repository Layout

```text
catalog/
├── charts/
│   ├── blueprint-aws-standard/    # The standard shape for AWS EKS
│   └── blueprint-azure-standard/  # The standard shape for Azure AKS
```
