# FinCorp: The Immutable and Indestructible Pipeline

A DevOps lab delivering two capabilities for FinCorp: a **secure, auditable software
supply chain** that produces immutable, vulnerability-scanned container artifacts, and a
**cross-region disaster recovery** plan that restores a critical database in a different
region within 30 minutes. Built with Terraform and AWS-native services, documented
end-to-end with reproducible steps and captured evidence.

> Scaffolded by reusing the framework and a subset of infrastructure from the prior
> `tabltennis-kube` (pongapp) project. See `AGENTS.md` for the full operating contract.

## Objectives

1. **Immutable artifact pipeline** — AWS CodeArtifact proxies npm and pip; an AWS
   CodePipeline/CodeBuild pipeline builds the application and pushes the image to Amazon
   ECR with **tag immutability** and **image scanning** enabled. The build **fails on any
   High or Critical vulnerability**.
2. **Cross-region disaster recovery** — Amazon RDS in `us-east-1`; AWS Backup takes daily
   snapshots and **copies them to `us-west-2`**; a simulated region failure is recovered by
   restoring in `us-west-2`, with the recovery time measured against a **30-minute RTO**.

## Regions

- Primary: `us-east-1`
- Disaster recovery: `us-west-2`

## Roadmap

| # | Phase | Status |
|---|-------|--------|
| 0 | Framework scaffolding | Done |
| 1 | Terraform foundation (network, ECR immutable + scan, CodeArtifact npm+pip) | Pending |
| 2 | Secure pipeline (CodePipeline + CodeBuild, scan gate) | Pending |
| 3 | Prove the gate (build fails on High/Critical) | Pending |
| 4 | RDS in us-east-1 + AWS Backup cross-region copy to us-west-2 | Pending |
| 5 | DR drill (delete primary, restore in us-west-2, measure RTO) | Pending |
| 6 | Documentation and live walkthrough | Pending |

## Repository structure

```
fincorp-immutable-dr/
├── apps/                         # Application source built by the pipeline (reused)
│   ├── frontend/                 # Angular (npm) + Dockerfile
│   └── backend/                  # Django (pip) + Dockerfile
├── infra/terraform/
│   ├── modules/
│   │   ├── network/ · rds/ · ecr/ · secrets/        # reused
│   │   └── codeartifact/ · codebuild/ · codepipeline/ · backup/   # new (stubs)
│   └── envs/prod/                # single root, us-east-1 + us-west-2 provider aliases
├── docs/                         # tutorial chapters, walkthrough, assets/
├── .claude/
│   ├── agents/                   # infra-engineer, pipeline-engineer, docs-scribe, platform-reviewer
│   └── skills/                   # securing-supply-chain, disaster-recovery, + reused skills
├── capture_window.ps1            # screenshot bridge
├── AGENTS.md                     # operating contract (read this first)
└── README.md
```

## Getting started

The infrastructure is not yet implemented — this repository is scaffolded and ready for
the build phases described in `AGENTS.md` §3. Begin with Phase 1 (Terraform foundation).
