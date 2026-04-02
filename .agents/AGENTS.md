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
before committing.

**With inline overrides:**

```bash
helm template global-services-live charts/blueprint-aws-standard \
  --set versions.stack=0.32.1 \
  --set cluster.name=global-services-live \
  --set "stackApps[0].name=jetscale-console" \
  --set "stackApps[0].namespace=jetscale-console" \
  --set "stackApps[0].valueFiles[0]=envs/aws/aws.yaml" \
  --set "stackApps[0].valueFiles[1]=envs/aws/prod/default.yaml" \
  --set "stackApps[0].extraValueFiles[0]=envs/aws/prod/jetscale-console.yaml"
```

**With fleet values file (end-to-end preview):**

```bash
helm template global-services-live charts/blueprint-aws-standard \
  -f ../fleet/clusters/global-services-live/values.yaml
```

Expected: valid YAML containing `apiVersion: argoproj.io/v1alpha1` multi-source
`Application` resources with `$stackValues` refs, correct `repoURL`,
`targetRevision`, and `destination` fields.

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

### Artifact Contract

Catalog publishes OCI Helm blueprint charts to GHCR.

- OCI base: `oci://ghcr.io/jetscale-ai/catalog`
- Active MVP chart: `blueprint-aws-standard`
- Release versions follow semantic versioning (`0.1.0`, `0.2.0`, ...)
- Git tags follow the matching `v<major>.<minor>.<patch>` shape

`../global-argocd` consumes the published OCI chart version directly via:

- `catalogOciRepo`
- `catalogBlueprintChart`
- `catalogBlueprintVersion`

`../fleet` remains the source of instance state and workload version pins.

### Release Automation

The repository release flow uses `go-semantic-release`, following the same
semantic versioning model as `../stack`, but publishing blueprint charts instead
of workload charts.

- `ci.yaml` validates charts with `helm lint` and `helm template`
- `release.yaml` resolves the next semver from conventional commits
- the workflow updates `Chart.yaml` version fields, packages the chart, and
  pushes it to GHCR
- AWS is released first; Azure will join the same repo version stream later

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
  └─ publishes blueprint OCI charts that render ArgoCD Application objects
     referencing the OCI charts above
       │
       ▼
fleet
  └─ per-cluster values.yaml provides instance state + workload version overrides
       │
       ▼
global-argocd
  └─ root Application reads fleet values and renders the catalog OCI blueprint
```

## 6. Chart Inventory

| Chart | Cloud | Status | Purpose |
| :--- | :--- | :--- | :--- |
| `blueprint-aws-standard` | AWS (EKS) | **Active (MVP)** | Published OCI blueprint consumed by `global-argocd` |
| `blueprint-azure-standard` | Azure (AKS) | Scaffold (templates pending) | Standard shape for Azure clusters |
