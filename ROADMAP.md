# Catalog Roadmap

## 0. ArgoCD + Fleet Impact

This repo defines **Blueprints** (patterns) as Helm charts that render ArgoCD `Application` objects.

- **Fleet injects state:** per-cluster `values.yaml` provides version pins + non-sensitive infra IDs.
- **ArgoCD applies it:** clusters converge by syncing `../fleet` → Blueprint chart → rendered Applications.
- **Why it matters here:** we keep the blueprint *shape* stable and reusable; we never pin live versions in Catalog.

## Phase 1: The AWS Standard
- [ ] Create `charts/blueprint-aws-standard`.
- [ ] Template `argocd/Application` resources for:
    - `system` (Ingress Nginx, Cert Manager) - *Install First*
    - `stack` (JetScale App) - *Install Second*
    - `observability` (Loki/Grafana) - *Install Third*

## Phase 2: The Franchise Kit (Self-Host)
- [ ] Create `charts/blueprint-self-host`.
- [ ] Add `enabled` toggles for observability so clients can opt-out.
