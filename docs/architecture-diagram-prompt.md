# Master prompt — FinCorp architecture diagram (for Gemini image generation)

> Paste the block below into Gemini to generate the architecture diagram.
> Update the "Baked-in decisions" section first if any assumption is wrong.

---

Create a professional, presentation-grade AWS cloud architecture diagram, in the exact
visual style of the reference image I provided: a clean white canvas with a faint
light-gray grid background, rounded-corner container boxes with colored borders and pale
fills, official AWS service icons rendered in their correct brand colors, thin labeled
arrows showing data flow, a bold title top-left, and a legend box bottom-right. Use a
16:9 widescreen aspect ratio, high resolution, crisp and uncluttered. Use a modern
sans-serif font. Labels must be short and legible.

TITLE (top-left, bold black): "FinCorp — Immutable Supply Chain & Cross-Region DR"
SUBTITLE (smaller, gray): "Immutable ECR artifacts · High/Critical scan gate · RDS Backup DR (us-east-1 → us-west-2) · RTO < 30 min"

TOP — ACTORS (small line-icons, centered above the cloud):
- "Developers" (developer icon)
- "Security / Auditors" (shield icon)

MAIN — one large rounded box labeled "AWS Cloud". Inside it, split the canvas into TWO
clearly separated regions, each its own rounded container with a region label at its top:

============================================================================
LEFT REGION — large rounded box labeled "us-east-1 (Primary)".
Inside it, stack TWO labeled sections:

SECTION A (top of us-east-1) — light-blue rounded box labeled
"Objective 1 — Immutable Artifact Pipeline".
Show a left-to-right horizontal flow with official logos and thin labeled arrows:

  GitHub (source)
    → "AWS CodePipeline" (orchestration)
    → "AWS CodeBuild" (build + scan gate)
    → "Amazon ECR" (image store)

  - Under CodeBuild, a light-green rounded sub-box labeled "AWS CodeArtifact"
    containing two small items: "npm upstream proxy" and "pip upstream proxy",
    with a dashed arrow from CodeArtifact UP into CodeBuild labeled
    "dependencies (npm + pip)".
  - On the Amazon ECR icon add a small note: "IMMUTABLE tags · scan-on-push · tagged by git SHA".
  - Between CodeBuild and ECR add a small red diamond gate labeled
    "Scan Gate" with a yellow sticky note: "FAIL build on HIGH / CRITICAL".
  - Add a small note under the section: "FinCorp builds, scans & stores the image only — app is not deployed".

SECTION B (bottom of us-east-1) — light-purple rounded box labeled
"Objective 2 — Protected Database".
  - Inside a smaller box labeled "VPC 10.0.0.0/16 · private data subnets", show:
    - A cylinder icon labeled "Amazon RDS — PostgreSQL" note "(Single-AZ, private, encrypted)".
  - To the right of RDS, an icon labeled "AWS Backup Vault (us-east-1)"
    with a note "daily snapshots".
  - Show "AWS Backup Plan" as a small icon with a dashed arrow to RDS labeled
    "daily snapshot".

============================================================================
RIGHT REGION — large rounded box labeled "us-west-2 (Disaster Recovery)".
Inside it:
  - An icon labeled "AWS Backup Vault (us-west-2)" note "cross-region copy destination".
  - Below it a cylinder icon labeled "Amazon RDS — Restored" drawn with a dashed
    border (to show it exists only after recovery), note "(restored from copied snapshot)".
  - A small yellow sticky note on this region: "Recovery target: RTO < 30 min".

============================================================================
CENTER — the key DR flow arrow that crosses between the two regions:
  - A bold solid arrow from "AWS Backup Vault (us-east-1)" → "AWS Backup Vault (us-west-2)"
    labeled "Cross-Region Copy (daily)".
  - A dashed arrow from "AWS Backup Vault (us-west-2)" → "Amazon RDS — Restored"
    labeled "Restore (DR drill)".
  - A small red "X" icon over the primary "Amazon RDS — PostgreSQL" with a label
    "Simulated region failure (delete primary)".

RIGHT SIDE — vertical gray panel of cross-cutting AWS services (official icons, stacked,
each with a short label):
- "AWS Secrets Manager" (RDS master password)
- "AWS KMS" (ECR + RDS + Backup encryption)
- "AWS IAM — least privilege" (CodeBuild role · Backup service role · RDS)
- "Amazon CloudWatch" (pipeline + build logs, scan findings retained)

ARROWS / DATA FLOW (thin, with small labels):
- Developers → GitHub (push commit)
- GitHub → AWS CodePipeline (source change)
- AWS CodePipeline → AWS CodeBuild (build stage)
- AWS CodeArtifact → AWS CodeBuild (npm + pip dependencies), dashed
- AWS CodeBuild → Scan Gate → Amazon ECR (push image only if scan passes)
- AWS Secrets Manager → Amazon RDS (master password), dashed
- AWS Backup Plan → Amazon RDS (daily snapshot), dashed
- Amazon RDS → AWS Backup Vault (us-east-1) (snapshot stored)
- AWS Backup Vault (us-east-1) → AWS Backup Vault (us-west-2) (cross-region copy), solid bold
- AWS Backup Vault (us-west-2) → Amazon RDS — Restored (restore), dashed
- Security / Auditors → Amazon ECR and CloudWatch (review scan findings + immutable tags), dashed
- AWS KMS → Amazon ECR, Amazon RDS, AWS Backup Vault (encrypt), dashed

LEGEND (bottom-right box):
- Solid arrow = data flow
- Dashed arrow = control / provisioning / encryption
- Bold solid arrow = cross-region copy
- Dashed border = resource exists only after DR recovery
- Light blue = artifact pipeline
- Light green = CodeArtifact dependency proxy
- Light purple = data tier / protected database
- Red diamond = vulnerability scan gate
- Orange icon = ECR / CodeBuild / CodePipeline (developer tools)
- Blue icon = RDS / database

Use authentic AWS Architecture icon styling and brand colors: CodePipeline, CodeBuild and
CodeArtifact in AWS orange (developer tools), Amazon ECR in AWS orange, Amazon RDS in AWS
blue (PostgreSQL blue elephant), AWS Backup in pink/red (storage), AWS KMS and IAM in red,
AWS Secrets Manager in red, Amazon CloudWatch in pink/red, GitHub logo in black. Keep
everything aligned to a clean grid with generous spacing. Clearly separate the two region
boxes with a visible gap so the cross-region copy arrow reads as crossing regions.
Do not invent extra services. Spell every label exactly as written above.cc

Baked-in decisions — confirm or change:
- Two regions only: us-east-1 (primary) and us-west-2 (DR), matching the lab.
- The app (pongapp: Angular via npm + Django via pip) is only built, scanned, and stored
  as an immutable image. FinCorp does NOT run the app — no ALB, ECS, EKS, or running pods shown.
- Source is GitHub via a CodeStar/CodeConnections connection feeding CodePipeline. Tell me
  if you'd rather show GitHub Actions instead of CodePipeline/CodeBuild.
- ECR uses IMMUTABLE tags, scan-on-push, images tagged by git short SHA — never :latest.
- The scan gate fails the build on any HIGH or CRITICAL finding (non-negotiable).
- RDS is Single-AZ, private, encrypted (cost-optimized lab). Say if you want Multi-AZ shown.
- VPC CIDR 10.0.0.0/16 with private data subnets for RDS. Adjust if your network module differs.
- AWS Backup: daily plan in us-east-1 + cross-region copy to a us-west-2 vault; recovery is
  a restore in us-west-2 measured against a 30-minute RTO target.
- No ElastiCache/Redis, no Secrets Manager beyond the RDS password, no extra app services shown.
