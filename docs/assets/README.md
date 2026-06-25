# Screenshot assets index

Visual evidence for the FinCorp lab tutorials. Naming follows the
`capturing-screenshots` skill convention:

```
p<phase>-<platform>-<subject>-<NN>.png
```

Phase 1 is platform-agnostic infrastructure, so `<platform>` is `common`.

A human captures these from the AWS console (account **648637468459**, region
**us-east-1**) and saves them here with the exact filenames below. They are
already referenced from [`../phase-1-foundation.md`](../phase-1-foundation.md).

## Phase 1 — foundation

| Filename | What to capture | Where in the console |
|----------|-----------------|----------------------|
| Filename | Status | What to capture | Where in the console |
|----------|--------|-----------------|----------------------|
| `p1-common-terraform-apply-outputs-01.png` | pending (optional) | The terminal showing `terraform apply` complete with the Phase 1 outputs. Captured outputs are already in `../../infra/terraform/envs/prod/apply-phase1.txt`. | Local terminal in `infra/terraform/envs/prod`. |
| `p1-common-ecr-immutable-scan-02.png` | ✅ captured | The `fincorp-app` repository **Summary** view showing **Tag mutability = Immutable**, **Scan frequency = Scan on push**, and **AES-256**. | ECR → Repositories → `fincorp-app` → Summary. |
| `p1-common-codeartifact-domain-repos-03.png` | ✅ captured | The `fincorp` domain page listing all four repositories — `npm`, `npm-store`, `pip`, `pypi-store`. | CodeArtifact → Domains → `fincorp` → Repositories. |
| `p1-common-vpc-subnets-sg-04.png` | ✅ captured | The two private data subnets (`subnet-0788c79bfa91866d9`, `subnet-0a87f809fc79d0503`) in VPC `vpc-0f71b42bfac9d3650`. | VPC → Subnets (filter VPC `vpc-0f71b42bfac9d3650`). |
| `p1-common-rds-sg-inbound-05.png` | ✅ captured | The RDS security group `fincorp-prod-rds-sg` (`sg-01b2d3a92bda2b8b3`) inbound rule: PostgreSQL 5432 from `10.0.0.0/16` only — no `0.0.0.0/0`. | VPC → Security Groups → `fincorp-prod-rds-sg` → Inbound rules. |

### Optional supporting shots

| Filename | What to capture |
|----------|-----------------|
| `p1-common-ecr-lifecycle-06.png` | The ECR lifecycle rule "Keep last 15 images" on `fincorp-app`. |
| `p1-common-tfstate-bucket-07.png` | The S3 bucket `fincorp-tfstate-648637468459-use1` showing Versioning = Enabled, encryption, and Block all public access = On. |

## Phase 2 — secure pipeline

| Filename | What to capture | Where in the console |
|----------|-----------------|----------------------|
| `p2-pipeline-run-all-green-01.png` | The `fincorp-prod-pipeline` execution with Source + Build (both parallel actions) all green. First green run = SHA `571cca1`. | CodePipeline → `fincorp-prod-pipeline` → most recent successful execution. |
| `p2-pipeline-ecr-immutable-scan-02.png` | An ECR repo (`fincorp-backend` or `fincorp-frontend`) showing **Tag mutability = Immutable**, **Scan on push**, and an image tagged by short SHA. | ECR → Repositories → `fincorp-backend` → Summary + Images. |
| `p2-pipeline-codestar-connection-available-03.png` | The `fincorp-*` CodeConnections connection in **Available** status (after the one-time Authorize). | Developer Tools → Settings → Connections. |

## Phase 3 — prove the gate

| Filename | What to capture | Where in the console |
|----------|-----------------|----------------------|
| `p3-gate-failed-run-29-blocking-01.png` | The **Failed** pipeline execution `641c443b` and the CodeBuild log lines `GATE FAILED: 29 HIGH/CRITICAL ... fincorp-backend:928049d`. | CodePipeline execution `641c443b` → backend Build action → CloudWatch logs. |
| `p3-gate-passed-allowlist-counts-02.png` | The **green** run `8e1f45da` (SHA `b48f040`) and the per-tier triage log: backend 4/4 allowlisted, frontend 34/34, 0 blocking, GATE PASSED. | CodePipeline execution `8e1f45da` → Build action logs. |

## Phase 4 — RDS + AWS Backup cross-region

| Filename | What to capture | Where in the console |
|----------|-----------------|----------------------|
| `p4-dr-rds-private-encrypted-01.png` | `fincorp-prod-postgres` showing postgres 17.9, **not publicly accessible**, **encrypted**, master credential in Secrets Manager. | RDS → Databases → `fincorp-prod-postgres` → Configuration/Connectivity. |
| `p4-dr-backup-vaults-02.png` | Both vaults: `fincorp-prod-vault-use1` (us-east-1) and `fincorp-prod-vault-dr` (eu-west-1). | AWS Backup → Vaults (switch regions). |
| `p4-dr-backup-plan-copy-action-03.png` | The daily backup plan rule showing the **cross-region copy** action to the eu-west-1 vault. | AWS Backup → Backup plans → the daily plan → rule detail. |
| `p4-dr-recovery-point-copied-04.png` | A `COMPLETED` recovery point in `fincorp-prod-vault-dr` (eu-west-1). | AWS Backup → Vaults → `fincorp-prod-vault-dr` → Recovery points (eu-west-1). |

## Phase 5 — DR drill + RTO

| Filename | What to capture | Where in the console |
|----------|-----------------|----------------------|
| `p5-dr-restored-db-available-01.png` | The restored `fincorp-prod-postgres-dr` in **eu-west-1**, status `available`, private + encrypted, postgres 17.9. | RDS → Databases (eu-west-1) → `fincorp-prod-postgres-dr`. |
| `p5-dr-rto-timeline-02.png` | The terminal RTO timeline: DISASTER DECLARED 13:48:49Z → RECOVERY COMPLETE 14:14:51Z → END-TO-END RTO 26m02s PASS. | Local terminal capture of the drill output. |

## Capture tips

- Crop to the relevant panel; make sure the setting value (IMMUTABLE, Enabled,
  the CIDR) is legible.
- Avoid clicking anything that opens a JS confirm/alert dialog if using browser
  automation — it blocks the extension.
- Keep the account/region visible in frame where it doesn't expose secrets.
