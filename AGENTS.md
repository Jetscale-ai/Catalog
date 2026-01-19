# The Catalog Constitution

## 0. The 5-Repo Topology (Global Context)

We operate under the **Fractal Franchise Model**. This repository is one part of a distributed system:

| Repo | Role | Artifact | Responsibility |
| :--- | :--- | :--- | :--- |
| **`iac`** | **The Soil** | `.tfstate` | Provisions Cluster, IAM, S3, and **bootstraps ArgoCD**. |
| **`stack`** | **The App** | OCI Chart | Builds the Business Logic (`backend` + `frontend` umbrella). |
| **`observability`** | **The Tools** | OCI Chart | Builds the Platform Layer (Loki, Grafana, Promtail). |
| **`catalog`** | **The Pattern** | Helm Charts | Defines **Blueprints** (Argo AppSets) for *how* things are installed. |
| **`fleet`** | **The State** | Live Cluster | Defines **Instances**. Pins versions and connects Infra to Apps. |

**Related Documentation:**
- Deployment state (instances + pins): `../fleet/README.md`
- Infrastructure + Argo bootstrap: `../iac/README.md`
- App artifact (OCI chart): `../stack/README.md`
- Observability artifacts: `../observability/README.md`

**Role:** The Librarian (Architect)  
**Context:** This repository owns the **Patterns** of deployment.

## 1. Context & Siblings
- **`../fleet/`**: The "live" instances that consume these blueprints and inject specific versions.
- **`../iac/`**: Bootstraps ArgoCD and outputs the non-sensitive IDs Fleet must commit (buckets, role ARNs).
- **`../stack/`**: The application OCI chart referenced by these blueprints.
- **`../observability/`**: The platform OCI charts referenced by these blueprints.

## 2. Invariants
1.  **Genericism (Clarity):** Blueprints must not contain client-specific secrets, IDs, or **Versions**. Use Helm Values.
2.  **Versioning (Prudence):** Changes to `main` do not affect clusters until tagged and referenced in `fleet`.
3.  **Composition (Symbiosis):** Use the App-of-Apps pattern. The Blueprint is the "Root App".

## 3. The "Blueprint" Boundary
This repo defines **WHAT** can be deployed. It does not define **WHERE** it is deployed or **WHICH VERSION** is running.
