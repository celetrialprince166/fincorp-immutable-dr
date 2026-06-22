---
name: disaster-recovery
description: Builds and proves FinCorp's cross-region disaster recovery — an Amazon RDS database in us-east-1, AWS Backup taking daily snapshots and copying them to us-west-2, then a simulated region failure (deleting the primary) recovered by restoring in us-west-2 with the recovery time measured against a 30-minute RTO. Use when configuring AWS Backup, cross-region copy, simulating region failure, or restoring and timing the recovery. Objective 2 of the FinCorp lab.
---

# Cross-region disaster recovery

Objective 2. Protect a critical RDS database so it can be **restored in a different
region within 30 minutes**, and prove it with a timed drill.

## The design
1. **Primary database** — Amazon RDS (PostgreSQL) in **us-east-1** (the default provider).
   Master password in Secrets Manager; encrypted storage.
2. **AWS Backup** —
   - A backup vault in **us-east-1** and a destination vault in **us-west-2** (the
     `aws.usw2` provider alias).
   - A backup plan with a **daily** rule, and a **copy action** to the us-west-2 vault
     (cross-region copy). A backup selection targeting the RDS instance by ARN/tag.
   - The AWS Backup service IAM role (`AWSBackupServiceRolePolicyForBackup` /
     `...ForRestores`), least-privilege.
3. **Why AWS Backup (vs RDS native cross-region snapshot copy):** centralised,
   policy-driven, auditable, and the same mechanism extends to other services — the FinCorp
   "auditable" requirement. State the trade-off in the writeup.

## The drill (the proof)
1. **Confirm a recovery point exists in us-west-2** (the daily copy completed). For a live
   demo you can force one with an on-demand backup + copy rather than waiting 24h.
2. **Simulate region failure** — delete the primary RDS instance in us-east-1 (take a final
   snapshot only if you want a safety net; the point is to lose the primary).
3. **Start the clock.** Restore the database in **us-west-2** from the copied recovery
   point (`aws backup start-restore-job` with the us-west-2 recovery-point ARN, or restore
   the copied snapshot into a new RDS instance in us-west-2).
4. **Stop the clock when the restored instance is `available`** and reachable. Record the
   **actual RTO** and compare to the 30-minute objective.

## Measuring RTO
```sh
start=$(date +%s)
# start-restore-job / restore-db-instance-from-db-snapshot in us-west-2 ...
aws rds wait db-instance-available --db-instance-identifier <restored> --region us-west-2
end=$(date +%s); echo "RTO = $(( (end-start)/60 )) min $(( (end-start)%60 )) s"
```

## What to capture (capturing-screenshots)
- The backup plan with the daily rule + cross-region copy action.
- A recovery point present in the **us-west-2** vault.
- The primary deleted in us-east-1 (the simulated failure).
- The restore job running, and the restored instance `available` in us-west-2.
- The timer output showing RTO under 30 minutes.

## Done when
A daily backup plan copies to us-west-2, the primary has been deleted and the database
restored in us-west-2, the **measured RTO is recorded against the 30-minute target**, and
the drill is captured and written up. Always include teardown for both regions.
