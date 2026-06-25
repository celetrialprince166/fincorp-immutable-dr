# AGENTS.md — FinCorp "Immutable & Indestructible"

> Operating contract for any AI agent working in this repo. Read this first, then
> let the **skills** do the heavy lifting. The routing table (§4) tells you which
> skill fires for the work in front of you — you should rarely need to be told.

---

## 1. What this project is

**FinCorp** requires a highly secure, auditable software supply chain and a disaster
recovery plan that can restore a critical database in a different region within
**30 minutes**. This repo delivers both as a documented, reproducible lab with two
objectives:

1. **Immutable artifact pipeline** — AWS CodeArtifact proxies npm and pip; an AWS
   CodePipeline/CodeBuild pipeline builds the app and pushes the image to Amazon ECR
   with **image scanning** and **tag immutability** enabled. The build **fails if any
   High or Critical vulnerability is found**.
2. **Cross-region disaster recovery** — Amazon RDS in **us-east-1**; AWS Backup takes
   daily snapshots and **copies them to us-west-2**; a simulated region failure
   (deleting the primary DB) is recovered by restoring in us-west-2, with the recovery
   time measured against the 30-minute target.

The application being built is the existing **pongapp** source under `apps/` (an Angular
front end installed via npm and a Django backend installed via pip). FinCorp does **not**
run the app — Objective 1 only builds, scans, and stores the immutable image; Objective 2
is a standalone RDS + Backup DR drill.

| Component | Role | Region(s) |
|-----------|------|-----------|
| AWS CodeArtifact | npm + pip upstream proxy | us-east-1 |
| AWS CodePipeline + CodeBuild | build, scan-gate, push | us-east-1 |
| Amazon ECR | immutable, scanned image store | us-east-1 |
| Amazon RDS (PostgreSQL) | the protected database | us-east-1 (primary) |
| AWS Backup | daily snapshots + cross-region copy | us-east-1 → us-west-2 |

---

## 2. Prime directives

1. **Security and auditability first.** Least-privilege IAM everywhere (CodeBuild,
   Backup service role, RDS). No plaintext secrets in git — use Secrets Manager / SSM.
   Every artifact is traceable: immutable tags, scan results retained.
2. **Immutability is non-negotiable.** ECR repositories use `IMMUTABLE` tags; images are
   tagged by commit SHA, never overwritten. The scan gate must genuinely fail the build
   on High/Critical — a passing build with known High/Critical findings is a defect.
3. **Document as you build, not after.** Every meaningful step produces evidence (a
   screenshot or captured command output) and a section in the tutorial. The submission
   is documentation + a live walkthrough. See `writing-tutorials` and `capturing-screenshots`.
4. **DR is proven, not asserted.** The recovery must be performed and **timed**; record
   the actual RTO against the 30-minute objective.
5. **Cost-aware and reversible.** RDS, NAT, and pipelines bill continuously. Always
   provide a teardown path and remind the user to run it. Never leave resources running
   silently in either region.
6. **Skills are automatic.** Match your task to the routing table (§4) and invoke the
   skill yourself.
7. **Explain the "why".** State the trade-off behind each architectural choice in a
   sentence or two — this lab is also for learning.

---

## 3. Roadmap (the lab arc)

Each phase ends with docs + screenshots committed.

| # | Phase | Primary skill(s) | Status |
|---|-------|------------------|--------|
| 0 | Framework: AGENTS.md + skills + agents (scaffolded) | — | ✅ done |
| 1 | Terraform foundation: network, ECR (IMMUTABLE + scan), CodeArtifact| `provisioning-aws-infra` | ✅ done |
| 2 | Secure pipeline: CodePipeline + CodeBuild (CodeArtifact deps → build → push immutable → scan) | `securing-supply-chain` | ⬜ |
| 3 | Prove the gate: introduce a High/Critical dependency, show the build fails | `securing-supply-chain` | ⬜ |
| 4 | RDS in us-east-1 + AWS Backup daily snapshots + cross-region copy to us-west-2 | `disaster-recovery` | ⬜ |
| 5 | DR drill: delete primary, restore in us-west-2, measure RTO < 30 min | `disaster-recovery` | ⬜ |
| 6 | Documentation + live-walkthrough script | `writing-tutorials` | ⬜ |

---

## 4. Skill routing — invoke these AUTOMATICALLY

When your work matches the **trigger**, load and follow that skill without being asked.
If two apply, the more specific one wins; chain them (any build/infra step also triggers
`capturing-screenshots` + `writing-tutorials`).

| If you are… | Use skill |
|-------------|-----------|
| Writing/editing any Terraform (`.tf`), provisioning VPC/subnets/NAT, remote state, RDS, or any AWS resource module | `provisioning-aws-infra` |
| Setting up CodeArtifact, CodeBuild/CodePipeline, ECR immutability/scanning, or the High/Critical vulnerability gate | `securing-supply-chain` |
| Building/fixing a Dockerfile or verifying the app image builds | `containerizing-services` |
| Configuring AWS Backup, cross-region copy, simulating region failure, or restoring/measuring RTO | `disaster-recovery` |
| At any step where visual proof helps — AWS console, pipeline run, scan findings, restore | `capturing-screenshots` |
| Finishing a phase or any teachable step; producing the end-to-end writeup | `writing-tutorials` |

> Rule of thumb: **a build/infra/DR action is never "done" until its evidence is captured
> (`capturing-screenshots`) and its narrative is written (`writing-tutorials`).**

---

## 5. Subagents — when to delegate

Defined in `.claude/agents/`. Delegate to keep the main context clean and run work in parallel.

| Agent | Hand off when… |
|-------|----------------|
| `infra-engineer` | A phase needs focused Terraform for the foundation or DR (network, RDS, Secrets, AWS Backup, cross-region wiring). |
| `pipeline-engineer` | The secure supply-chain work: CodeArtifact, CodeBuild/CodePipeline, ECR immutability/scanning, the vulnerability gate. |
| `docs-scribe` | A phase is functionally complete and needs screenshots gathered + a tutorial chapter written. |
| `platform-reviewer` | Before declaring a phase done — audits security, immutability enforcement, scan-gate effectiveness, least-privilege IAM, DR completeness, and RTO evidence. |

Typical loop per phase: **plan → `infra-engineer` / `pipeline-engineer` builds →
`platform-reviewer` checks → `docs-scribe` documents → commit.**

---

## 6. Repo conventions

- **Layout:**
  - `apps/` — the application source built by the pipeline (reused pongapp: npm + pip).
  - `infra/terraform/modules/` — reusable modules; `envs/prod/` — the single root with
    `aws` (us-east-1, default) and `aws.usw2` (us-west-2) provider aliases. S3 remote
    state, native lockfile (no DynamoDB).
  - `docs/` — tutorials, the walkthrough script, and `docs/assets/` for screenshots.
- **Regions:** primary `us-east-1`, DR `us-west-2`. One pair only.
- **Naming:** lowercase-kebab for AWS resources, prefix everything `fincorp-`.
- **Images:** ECR `IMMUTABLE` tags, tagged by **git short SHA** — never `:latest`, never overwritten.
- **Secrets:** never commit real values. `*.tfvars` with secrets and `k8s`-style secret
  files are gitignored. RDS master password in Secrets Manager.
- **Commits:** clear messages, **no AI/model attribution** (no Co-Authored-By, no model
  name, no session trailer).
- **Always offer the teardown command** at the end of any provisioning step, for both regions.

---

## 7. Definition of done (per phase)

- [ ] It works and was verified (command output / screenshot proves it).
- [ ] Security holds: least-privilege IAM, no plaintext secrets, immutability enforced.
- [ ] Evidence captured to `docs/assets/` via `capturing-screenshots`.
- [ ] Tutorial chapter written via `writing-tutorials`, with the "why".
- [ ] `platform-reviewer` pass: no leaked secrets, gate genuinely blocks High/Critical, teardown exists.
- [ ] Teardown path stated to the user (both regions where relevant).
- [ ] Roadmap table (§3) status updated.
