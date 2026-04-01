# Repository Constitution: catalog

**Status:** Ratified
**Authority:**
[Supreme Constitution](https://github.com/Jetscale-ai/Governance/blob/main/AGENTS.md)
**Version:** 0.1.0
**Risk Level:** Medium
**Owner:** JetScale Global Services Platform
**Deploy Target:** None (consumed by ArgoCD via Fleet)
**Branch Protection:** Protected (blueprint changes affect all clusters once
tagged and referenced)

## 0. Situational Awareness (Required Context)

- **Universal Red Lines (excerpt)**:
  - **No Direct Commits:** Agents must never execute commits, pushes, or tags.
  - **No Secrets:** Agents must never output, log, or persist secrets/keys.
  - **No Impersonation:** Agents must clearly identify work as
    machine-generated.
- **Commit Authority:** This repository must be treated as a protected IaC repo.
  Changes require feature branches, PR review, and human-authored commits.
- **Default Failure Mode:** If instructions conflict, evidence is ambiguous, or
  blast radius is unknown: **STOP -> AUDIT -> ASK**.
- **Eudaimonia Framework (12 invariants):** Legitimacy, Prudence, Symbiosis,
  Clarity, Traceability, Minimalism, Testability, Sovereignty, Temporality,
  Proportionality, Interoperability, Reflexivity.
  - `audit_log:` entries cite **only the invariants that applied**; they are
    not the full framework definition.
- **Session start rule (mandatory):** On the **first user message** in a new
  session (and on the first time you read this file), **bootstrap immediately**
  before answering any substantive question. Do not ask permission; this is a
  safety preflight.
- **Tooling preflight (mandatory):** Before bootstrapping canonical law, verify
  required tooling exists (including `gh` auth). If any check fails, **STOP**
  and ask a human to install/authenticate tooling.
- **Load Canonical Law (GitHub `main`)**: Load the Supreme Constitution and the
  bootstrap protocol. Other Codex artifacts may be loaded **on-demand** per the
  Trigger -> Required Law mapping in `.agents/codex/protocols/bootstrap.md`.
  - If any retrieval fails (permission/404/network), **do not proceed** beyond
    reporting the failure and asking a human to ratify/publish the missing law.
    Treat this repo as **Advisory Mode**.
  - Do not guess definitions from names or templates, and do not run additional
    commands until canonical law is retrievable.
- **Load Local Operations (required):** Read `.agents/AGENTS.md` before giving
  operational instructions (commands, verification steps, deployment flows). If
  it is missing, treat this repo as **Advisory Mode**.

```bash
# Tooling preflight (mandatory). STOP if any check fails.
require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required tool: $1" >&2; exit 1; }; }

# Canonical-law bootstrap tooling (private Governance repo)
require_cmd gh
gh auth status -h github.com >/dev/null 2>&1 || { echo "gh not authenticated for github.com (run: gh auth login)" >&2; exit 1; }
require_cmd base64
require_cmd sed

# Repo toolchain (Helm charts)
require_cmd helm
```

```bash
# Local operational law (oracles/commands live here)
sed -n '1,200p' .agents/AGENTS.md
```

```bash
# Supreme Constitution + bootstrap protocol (mandatory at session start)
gh api repos/Jetscale-ai/Governance/contents/AGENTS.md --jq .content | base64 -d
gh api repos/Jetscale-ai/Governance/contents/.agents/codex/protocols/bootstrap.md --jq .content | base64 -d

# Other Codex artifacts loaded on-demand per Trigger -> Required Law mapping
```

## 1. Preamble & Delegation

This repository does not invent governance. All agentic operations herein are
governed by the JetScale Supreme Constitution.

This constitution was ratified by human commit. Agents must follow the Codex
artifacts adopted in Section 2 and the local constraints in Section 3.

## 2. Codex Ratification (The Law)

This repository adopts the following Codex artifacts from
`Jetscale-ai/Governance@main`:

### Blueprints

- [x] [`.agents/codex/blueprints/iac.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/blueprints/iac.md)

### Protocols

- [x] [`.agents/codex/protocols/bootstrap.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/bootstrap.md)
- [x] [`.agents/codex/protocols/ratification.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/ratification.md)
- [x] [`.agents/codex/protocols/audit-trail.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/audit-trail.md)
- [x] [`.agents/codex/protocols/secret-management.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/secret-management.md)
- [x] [`.agents/codex/protocols/branch-protection.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/branch-protection.md)
- [x] [`.agents/codex/protocols/reachability.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/reachability.md)
- [x] [`.agents/codex/protocols/handoff.md`](https://github.com/Jetscale-ai/Governance/blob/main/.agents/codex/protocols/handoff.md)

## 3. Local Constraints (Catalog: The Pattern)

- **Ownership boundary:** This repo owns reusable deployment blueprints that
  render ArgoCD `Application` objects. It defines **what** can be deployed, not
  **where** it runs or **which version** is active.
- **Blast radius:** A broken blueprint template affects every cluster that
  references it once the released OCI version is consumed by
  `../global-argocd`. Changes are medium-risk and must be previewed with
  `helm template` before release.
- **Genericism invariant:** Blueprints must not contain client-specific secrets,
  IDs, or version pins. All instance-specific values are injected by Fleet.
- **Version discipline:** Changes to `main` do not affect clusters until a
  released OCI chart version is referenced by `../global-argocd`. Git tags are
  immutable release markers; OCI chart versions are immutable deployment
  artifacts.
- **Composition pattern:** Use the App-of-Apps pattern. Each blueprint chart
  renders ArgoCD `Application` resources for the workloads it governs (system,
  stack, observability).
- **No runtime secrets:** This repo never handles secrets. Secrets are managed
  at runtime via External Secrets Operator, configured by the values Fleet
  provides.
- **Supply chain:** Blueprint `repoURL` fields must point to trusted registries
  (GHCR OCI, Jetscale-ai GitHub repos). No custom ArgoCD plugins (CMP/AVP).
- **Cloud abstraction:** Separate blueprint charts per cloud provider
  (`blueprint-aws-standard`, `blueprint-azure-standard`) to keep provider-
  specific concerns (ingress class, secret store type, annotations) isolated.
- **Fleet dependency:** This repo consumes cluster instance state from
  `../fleet`, while `../global-argocd` consumes the published blueprint OCI
  chart. If either sibling references a version or contract that doesn't exist
  here, the failure is in the consumer.
- **Sibling boundary:** If workload Helm charts need changes, route to
  `../stack` or `../observability`. If cluster infrastructure needs changes,
  route to `../global-argocd` or `../global-cloud-network`.

## 4. Local Operational Details

See [**`.agents/AGENTS.md`**](./.agents/AGENTS.md) for repository-specific
commands, verification steps, and evidence expectations.
