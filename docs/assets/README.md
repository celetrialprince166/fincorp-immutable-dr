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
| `p1-common-terraform-apply-outputs-01.png` | The terminal showing `terraform apply` complete with the Phase 1 outputs (VPC id, subnet ids, SG id, ECR URL, CodeArtifact domain). | Local terminal in `infra/terraform/envs/prod`. |
| `p1-common-ecr-immutable-scan-02.png` | The `fincorp-app` repository **settings/detail** view clearly showing **Tag immutability = Enabled (IMMUTABLE)** and **Scan on push = Enabled**. | ECR → Repositories → `fincorp-app` → (General/Settings). |
| `p1-common-codeartifact-domain-repos-03.png` | The `fincorp` domain page listing all four repositories — `npm`, `npm-store`, `pip`, `pypi-store` — ideally showing the upstream/external-connection columns. | CodeArtifact → Domains → `fincorp` → Repositories. |
| `p1-common-vpc-subnets-sg-04.png` | The two private data subnets (`subnet-0788c79bfa91866d9`, `subnet-0a87f809fc79d0503`) and the RDS security group `fincorp-prod-rds-sg` (`sg-01b2d3a92bda2b8b3`) showing inbound 5432 from `10.0.0.0/16` only. A split or two stitched shots are fine. | VPC → Subnets (filter VPC `vpc-0f71b42bfac9d3650`); VPC → Security Groups → `fincorp-prod-rds-sg` → Inbound/Outbound rules. |

### Optional supporting shots

| Filename | What to capture |
|----------|-----------------|
| `p1-common-ecr-lifecycle-05.png` | The ECR lifecycle rule "Keep last 15 images" on `fincorp-app`. |
| `p1-common-tfstate-bucket-06.png` | The S3 bucket `fincorp-tfstate-648637468459-use1` showing Versioning = Enabled, encryption, and Block all public access = On. |

## Capture tips

- Crop to the relevant panel; make sure the setting value (IMMUTABLE, Enabled,
  the CIDR) is legible.
- Avoid clicking anything that opens a JS confirm/alert dialog if using browser
  automation — it blocks the extension.
- Keep the account/region visible in frame where it doesn't expose secrets.
