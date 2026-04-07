# Service Catalog

**Role:** The Pattern (Blueprints)  
**Artifact:** OCI Helm blueprint charts published to GHCR  
**Consumers:** `../global-argocd` (directly) and `../fleet` (indirectly)

This repository defines the reusable deployment patterns that ArgoCD consumes.
It does not deploy workloads itself. Instead, it publishes blueprint Helm charts
that render ArgoCD `Application` objects.

## What These Artifacts Are

Each chart in `catalog` is a blueprint:

- it describes how a class of cluster should deploy workloads
- it renders ArgoCD `Application` manifests rather than application pods directly
- it keeps cloud/platform concerns in one place
- it leaves live instance state to `../fleet`

Current charts:

- `charts/blueprint-aws-standard/`: AWS EKS blueprint used by the MVP
- `charts/blueprint-azure-standard/`: Azure AKS scaffold for future parity

## How The Layers Fit

```text
global-argocd
  └─ creates the root ArgoCD Application
       │
       ▼
fleet
  └─ provides cluster-specific values.yaml
       │
       ▼
catalog (this repo)
  └─ publishes blueprint OCI charts to GHCR
       │
       ▼
stack / observability
  └─ publish deployable workload OCI charts
```

For the current AWS shape:

1. `global-argocd` creates one root `Application` per runtime cluster
2. that root app uses `../fleet/clusters/<cluster-name>/values.yaml`
3. it renders `blueprint-aws-standard` from `oci://ghcr.io/jetscale-ai/catalog`
4. `blueprint-aws-standard` then renders:
   - one child ArgoCD app per `stackApps[]` entry
   - zero or one shared `observability-core` child app for the cluster
5. those child apps pull the actual workload charts from `../stack` and
   `../observability`

So this repo is the pattern bridge between control-plane bootstrap and workload
deployment.

## Why Catalog Exists

The workload chart in `../stack` should remain as cloud-agnostic as possible,
but the platform envelope is still cloud-specific:

- AWS uses ALB annotations, ACM, IRSA, and AWS Secrets Manager wiring
- Azure will use AKS-specific ingress, identity, and secret-store contracts
- GCP will have its own platform envelope later

`catalog` isolates that difference without forking the app itself.

## Release Model

This repo is released as OCI Helm charts to GHCR.

- current OCI base: `oci://ghcr.io/jetscale-ai/catalog`
- current active chart: `blueprint-aws-standard`
- versioning is repo-wide semantic versioning via `go-semantic-release`
- AWS is implemented first
- Azure will join the same repo version stream later

That means future releases should aim for:

- one repo semantic version such as `0.2.0`
- `blueprint-aws-standard:0.2.0`
- `blueprint-azure-standard:0.2.0`

even if only AWS is active today.

## Developer Workflow

Catalog does not own live version pins for workloads.

- blueprint chart versions are published from this repo
- workload chart versions are injected into blueprint values by `../fleet`
- cluster-specific values belong in `../fleet`
- the reusable contract is `1..n` stack apps plus optional cluster-wide
  observability

### Adding a new capability

1. Update the appropriate blueprint chart in `charts/`
2. Keep client-specific values out of this repo
3. Verify with `helm lint` and `helm template`
4. Merge via PR using conventional commits
5. Let GitHub Actions publish a new OCI chart version
6. Bump the consumed blueprint version in `../global-argocd` when ready

## Repository Layout

```text
catalog/
├── charts/
│   ├── blueprint-aws-standard/    # AWS EKS blueprint chart
│   └── blueprint-azure-standard/  # Azure AKS blueprint chart
├── .release.yml                   # go-semantic-release config
└── .github/workflows/
    ├── ci.yaml                    # lint + render checks
    └── release.yaml               # OCI publish workflow
```
