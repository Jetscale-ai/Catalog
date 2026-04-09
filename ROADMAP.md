# Catalog Roadmap

## 0. ArgoCD + Fleet Impact

This repo defines **Blueprints** (patterns) as Helm charts that render ArgoCD `Application` objects.

- **Fleet injects state:** per-cluster `values.yaml` provides version pins + non-sensitive infra IDs.
- **ArgoCD applies it:** clusters converge by syncing `../fleet` → Blueprint chart → rendered Applications.
- **Why it matters here:** we keep the blueprint *shape* stable and reusable; we never pin live versions in Catalog.

## Phase 1: The AWS Standard

- [x] Create `charts/blueprint-aws-standard`.
- [x] Template the reusable AWS workload blueprint using:
  - stack OCI chart from GHCR
  - stack values from `../stack`
  - cluster instance values from `../fleet`
- [x] Wire the root control-plane handoff so `../global-argocd` can consume the
      blueprint as an OCI chart
- [x] Add CI + OCI publish workflow for the AWS blueprint
- [x] Add optional `observability` child Applications alongside one or more
      `stack` child Applications
- [ ] Validate the per-runtime-cluster shape against Fleet paths such as
      `aws-prod-jetscale`, `aws-prod-codewords`, and `aws-prod-glaciergrid`
- [ ] Add any required system-layer Applications once the control-plane split is
      fully settled

## Phase 2: Repo-Wide Release Discipline

- [x] Adopt repo-wide semantic versioning via `go-semantic-release`
- [x] Publish blueprint OCI artifacts to GHCR
- [ ] Keep the version stream repo-wide even before Azure is active
- [x] Document the contract clearly enough that `../global-argocd` and
      `../fleet` can consume published versions without ambiguity

## Phase 3: Azure Parity On The Same Version Stream

- [ ] Implement `charts/blueprint-azure-standard`
- [ ] Publish `blueprint-azure-standard` on the same repo semantic version as
      AWS releases
- [ ] Keep the logical workload set aligned across AWS and Azure as much as
      possible
- [ ] Confine cloud differences to the platform envelope: ingress, identity,
      secret store, and other provider-specific wiring

## Phase 4: Broader Franchise Kit

- [ ] Add more reusable blueprints only when a real operating shape exists
- [ ] Consider self-host / BYOC variants if they diverge materially from the
      cloud-managed shapes
