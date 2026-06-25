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

## Capture tips

- Crop to the relevant panel; make sure the setting value (IMMUTABLE, Enabled,
  the CIDR) is legible.
- Avoid clicking anything that opens a JS confirm/alert dialog if using browser
  automation — it blocks the extension.
- Keep the account/region visible in frame where it doesn't expose secrets.
