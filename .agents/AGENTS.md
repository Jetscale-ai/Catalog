# Repository Operations: catalog

**Status:** Operational Details
**Scope:** `catalog` only
**Branch Protection:** Protected (blueprint changes affect all consuming
clusters once tagged)

## 1. Verification (Local Oracles)

### Lint / Template Check

```bash
helm lint charts/blueprint-aws-standard
helm lint charts/blueprint-azure-standard
```

### Render Preview (Dry-Run)

Verify that blueprint templates render valid ArgoCD `Application` manifests
before committing:

```bash
helm template test-cluster charts/blueprint-aws-standard \
  --set versions.stack=0.32.1 \
  --set versions.observability=1.0.0 \
  --set enabled.stack=true \
  --set enabled.observability=true \
  --set cluster.name=test-cluster \
  --set "cluster.server=https://kubernetes.default.svc" \
  --set "repositories.stack.repoURL=oci://ghcr.io/jetscale-ai/charts/jetscale"
```

Expected: valid YAML containing `apiVersion: argoproj.io/v1alpha1` Application
resources with correct `repoURL`, `targetRevision`, and `destination` fields.

### Chart Packaging

```bash
helm package charts/blueprint-aws-standard
helm package charts/blueprint-azure-standard
```

## 2. Evidence Expectations

- **Template evidence:** include `helm template` output in the PR description to
  prove the rendered Applications are correct.
- **Lint evidence:** `helm lint` must pass with no errors for all modified
  charts.
- **Traceability:** material changes must include an `audit_log:` section in the
  human-authored commit message (`.agents/codex/protocols/audit-trail.md`).
- **Linkage:** blueprint changes should cite the Fleet entry or sibling-repo
  contract that motivates the change.

### Commit message template

```text
<type>(<scope>): <summary>

- Change: <...>
- Verification: <...>

audit_log:
- Legitimacy: <why this is required (standard clause or business goal)>
- Prudence: <why this approach is feasible/safe>
- Symbiosis: <why it's linked; issue/PR URLs>
- Testability: <why it's verifiable; oracle/CI evidence>
- Traceability: <audit_log captured in commit body; links included>
```

## 3. Secrets & Sensitive Data

- Follow `.agents/codex/protocols/secret-management.md`.
- Blueprints must never contain secrets, tokens, or credentials.
- Blueprint `repoURL` fields must reference trusted registries only (GHCR OCI,
  Jetscale-ai GitHub repos).
- Client-specific identifiers (account IDs, role ARNs, bucket names) belong in
  `../fleet`, not here.

## 4. Release Workflow

### Tagging Convention

Tags follow semantic versioning: `v<major>.<minor>.<patch>`.

```bash
git tag v0.1.0
git push origin v0.1.0
```

Fleet entries reference catalog tags via `targetRevision`. A tag is immutable
once consumed by any cluster.

### Breaking Changes

A major version bump is required when:
- An existing values key is renamed or removed
- A template is deleted or its rendered output changes incompatibly
- A new required value is added without a default

## 5. Dependency Layer

```text
stack / observability (OCI chart registries)
  └─ publish immutable Helm charts to GHCR
       │
       ▼
catalog (this repo)
  └─ blueprint charts render ArgoCD Application objects that reference
     the OCI charts above
       │
       ▼
fleet
  └─ per-cluster values.yaml pins catalog tag + version overrides
       │
       ▼
global-argocd
  └─ root Application syncs from fleet, ArgoCD reconciles the blueprint
```

## 6. Chart Inventory

| Chart | Cloud | Status | Purpose |
| :--- | :--- | :--- | :--- |
| `blueprint-aws-standard` | AWS (EKS) | Scaffold (templates pending) | Standard shape for AWS clusters |
| `blueprint-azure-standard` | Azure (AKS) | Scaffold (templates pending) | Standard shape for Azure clusters |
