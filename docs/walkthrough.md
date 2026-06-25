# Phase 6 — Live-walkthrough script

## Goal

A tight, repeatable runbook for the live demo. It ties both objectives together —
the immutable, scanned supply chain and the proven cross-region DR — into a single
narrative you can deliver in front of an audience without fumbling. It says what to
show, in what order, the exact commands to run, what to point at on screen, and how
to leave the account clean at the end. Each section links to the full chapter for the
"why".

Account **648637468459**, primary **us-east-1**, DR **eu-west-1**.

## Before you start (pre-flight)

- AWS CLI v2 authenticated to `648637468459`; console open and logged in.
- The CodeConnections connection is `AVAILABLE` (the one-time Authorize is already
  done — see [Phase 2](phase-2-pipeline.md)).
- Both ECR repos hold the green `b48f040` images; `security/scan-allowlist.txt` is in
  the repo.
- For the DR portion, decide live vs. pre-recorded: a real restore is ~26 minutes, so
  for a short demo present the **already-captured** RTO evidence and screenshots
  rather than deleting a live database on stage. The script below assumes you narrate
  the recorded drill; do the live version only if you have the time budget.
- Have the per-phase screenshots in `docs/assets/` open as backup if a live call is
  slow.

## Opening (60 seconds)

> "FinCorp needs two things: a software supply chain where every artifact is
> immutable and scanned, and a database that can come back in a different region
> inside 30 minutes. I built both as reproducible Terraform. Let me show you they
> actually work — not just that they exist."

Show the architecture diagram (`docs/assets/fincorp-architecture.png`).

---

## Part 1 — The immutable, scanned supply chain (Objective 1)

### 1. The trust model is set in infrastructure

Point at the ECR repo settings: **IMMUTABLE** tags + **scan-on-push**.

```bash
aws ecr describe-repositories --repository-names fincorp-backend --region us-east-1 \
  --query "repositories[0].{mutability:imageTagMutability,scan:imageScanningConfiguration,enc:encryptionConfiguration}"
```

Say: *"Tags are immutable and every push is scanned. The bytes we audit are the bytes
that ship — see [Phase 1](phase-1-foundation.md)."*

### 2. The pipeline pulls deps through CodeArtifact and pushes by SHA

Show the green pipeline run (`p2-pipeline-run-all-green-01.png`), then:

```bash
aws codepipeline get-pipeline-state --name fincorp-prod-pipeline --region us-east-1 \
  --query "stageStates[].{stage:stageName,status:latestExecution.status}"
```

Say: *"Source comes from GitHub over a CodeConnections connection — no stored token.
Two parallel builds, npm and pip, every dependency proxied through CodeArtifact, and
the CodeArtifact token is a BuildKit secret so it never lands in a layer. Images are
tagged by git SHA — never `:latest`."* ([Phase 2](phase-2-pipeline.md).)

### 3. Prove the gate has teeth (the money shot of Objective 1)

Show the **failed** run and the log (`p3-gate-failed-run-29-blocking-01.png`).

Say: *"We pinned an end-of-life Debian base on purpose. The scan found 29
High/Critical, and the build was BLOCKED — execution `641c443b`, `GATE FAILED: 29
HIGH/CRITICAL`. A gate you never see fail isn't a gate."*

Then the green run with counts (`p3-gate-passed-allowlist-counts-02.png`):

Say: *"After reverting the base, the only remaining findings are OS CVEs with no
upstream fix — backend 4, frontend 34 — each one explicitly listed and dated in an
auditable allowlist. Zero blocking. And because basic scanning has no fixed-version
field, we count from the per-finding list, not the summary, which on ECR basic
returns null even when findings exist — that was a real false-pass bug we fixed.
A new fixable CVE would still fail the build."* ([Phase 3](phase-3-gate.md).)

---

## Part 2 — Cross-region disaster recovery (Objective 2)

### 4. The protected database and its cross-region backups

Show the RDS instance (private, encrypted) and the two vaults
(`p4-dr-rds-private-encrypted-01.png`, `p4-dr-backup-vaults-02.png`).

```bash
aws rds describe-db-instances --db-instance-identifier fincorp-prod-postgres \
  --region us-east-1 \
  --query "DBInstances[0].{public:PubliclyAccessible,enc:StorageEncrypted,secret:MasterUserSecret.SecretArn}"
```

Say: *"Postgres 17.9, private, encrypted, master password in Secrets Manager — no
plaintext. AWS Backup takes a daily snapshot and copies it cross-region. One honest
caveat: an org SCP blocks Backup in US regions, so the DR region is eu-west-1 — a
genuinely separate region, and the 30-minute target doesn't care which one."*
([Phase 4](phase-4-dr-foundation.md).)

Point at the copy action and the copied recovery point in the DR vault
(`p4-dr-backup-plan-copy-action-03.png`, `p4-dr-recovery-point-copied-04.png`).

### 5. The drill and the RTO (the money shot of Objective 2)

Show the restored DB + RTO timeline (`p5-dr-restored-db-available-01.png`,
`p5-dr-rto-timeline-02.png`).

Say: *"We deleted the primary with no final snapshot — recovery had to come from the
cross-region copy alone. Disaster declared 13:48:49Z, restored DB available in
eu-west-1 at 14:14:51Z. End-to-end RTO **26 minutes 2 seconds — under the 30-minute
objective**. The restore mechanism itself was about 9 minutes; the rest is real
recovery work, including a first attempt that failed on `DBName must be null` for
postgres restores."* ([Phase 5](phase-5-dr-drill.md).)

```bash
aws rds describe-db-instances --db-instance-identifier fincorp-prod-postgres-dr \
  --region eu-west-1 \
  --query "DBInstances[0].{status:DBInstanceStatus,engine:EngineVersion,public:PubliclyAccessible,enc:StorageEncrypted}"
```

Say: *"Same posture as the original — available, private, encrypted, postgres 17.9.
A faithful restore, not a degraded one."*

---

## Closing (30 seconds)

> "Two objectives, both proven not asserted: an immutable, scanned supply chain whose
> gate we watched block a vulnerable build, and a cross-region restore measured at
> 26 minutes against a 30-minute target. Everything is Terraform and documented
> per phase, so anyone can reproduce it."

---

## Teardown (run after the demo — both regions bill)

The DR database and the dual-region backup storage cost money continuously. Tear down
in this order:

```bash
# 1. Empty BOTH vaults — recovery points block vault deletion.
aws backup delete-recovery-point --backup-vault-name fincorp-prod-vault-use1 \
  --recovery-point-arn <arn> --region us-east-1
aws backup delete-recovery-point --backup-vault-name fincorp-prod-vault-dr \
  --recovery-point-arn <arn> --region eu-west-1

# 2. Destroy the Terraform-managed Phase 4 resources.
terraform destroy   # from infra/terraform/envs/prod

# 3. Manually delete the eu-west-1 drill resources — NOT in Terraform state:
aws rds delete-db-instance --db-instance-identifier fincorp-prod-postgres-dr \
  --skip-final-snapshot --region eu-west-1
aws rds delete-db-subnet-group --db-subnet-group-name fincorp-prod-db-dr --region eu-west-1
aws ec2 delete-security-group --group-id sg-0dd2c654e6a4596ab --region eu-west-1

# 4. (Optional) Objective-1 stack: empty the IMMUTABLE ECR repos first, then destroy.
aws ecr batch-delete-image --repository-name fincorp-backend  --region us-east-1 --image-ids imageTag=b48f040
aws ecr batch-delete-image --repository-name fincorp-frontend --region us-east-1 --image-ids imageTag=b48f040
terraform destroy -target=module.codepipeline -target=module.codebuild
```

> **The eu-west-1 restored DB, its DB subnet group (`fincorp-prod-db-dr`), and SG
> (`sg-0dd2c654e6a4596ab`) are not in Terraform state** — `terraform destroy` will not
> touch them. Always run step 3 by hand or they keep billing in the DR region.

## Demo checklist

- [ ] Connection `AVAILABLE`, green pipeline run visible.
- [ ] Failed run (`641c443b`, 29 blocking) and green run (allowlist counts) both on hand.
- [ ] RDS private/encrypted; both vaults + copied recovery point visible.
- [ ] RTO evidence (26m02s, PASS) ready.
- [ ] Teardown commands queued — including the **manual eu-west-1** cleanup.
