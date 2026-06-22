---
name: securing-supply-chain
description: Builds FinCorp's immutable, auditable artifact pipeline — AWS CodeArtifact as an npm/pip upstream proxy, an AWS CodeBuild/CodePipeline build that installs dependencies through CodeArtifact, builds the Docker image, and pushes it to Amazon ECR with tag immutability and scan-on-push enabled, then fails the build when High/Critical vulnerabilities are found. Use when setting up CodeArtifact, CodeBuild/CodePipeline, ECR immutability/scanning, or the vulnerability gate. Objectives 1 of the FinCorp lab.
---

# Securing the software supply chain

Objective 1. Produce **immutable, scanned** container artifacts from a build that pulls
every dependency through a controlled proxy and **refuses to ship High/Critical
vulnerabilities**.

## The four controls (all must hold)
1. **CodeArtifact as the only dependency source.** A CodeArtifact domain with an `npm`
   repo and a `pip` (python) repo, each with the public upstream attached (`npm-store`,
   `pypi-store`). The build authenticates with a short-lived token; no direct registry pulls.
2. **ECR tag immutability.** `image_tag_mutability = "IMMUTABLE"` — a tag can never be
   overwritten. Tag images by **git short SHA**, never `:latest`.
3. **Scan on push.** `image_scanning_configuration { scan_on_push = true }` (enhanced /
   Amazon Inspector scanning preferred for OS + language findings).
4. **The gate.** After push, read the scan findings; **exit non-zero if any HIGH or
   CRITICAL** finding exists, which fails the CodeBuild build and the pipeline.

## Method
1. Terraform: `codeartifact` (domain + npm + pip repos + upstreams), `ecr` (IMMUTABLE +
   scan_on_push), `codebuild` (project + least-privilege role + buildspec), `codepipeline`
   (Source = GitHub via a CodeStar connection → Build).
2. Buildspec outline (CodeBuild):
   - `aws codeartifact login --tool npm` and configure pip's index-url from
     `aws codeartifact get-repository-endpoint` + `get-authorization-token`.
   - Install deps (npm ci / pip install) — now proxied and recorded by CodeArtifact.
   - `docker build` and tag `:$CODEBUILD_RESOLVED_SOURCE_VERSION` (the commit SHA).
   - `docker push` to the IMMUTABLE ECR repo.
   - Wait for the scan, then evaluate findings (see the gate below).
3. The gate (in the buildspec, after push):
   ```sh
   aws ecr wait image-scan-complete --repository-name "$REPO" --image-id imageTag="$SHA"
   counts=$(aws ecr describe-image-scan-findings --repository-name "$REPO" \
     --image-id imageTag="$SHA" \
     --query 'imageScanFindingsSummary.findingSeverityCounts' --output json)
   echo "$counts"
   crit=$(echo "$counts" | jq '(.CRITICAL // 0) + (.HIGH // 0)')
   if [ "$crit" -gt 0 ]; then echo "FAILED: $crit High/Critical findings"; exit 1; fi
   ```
4. Prove it (Phase 3): add a dependency with a known High/Critical CVE, push, and show
   the build **fails** at the gate; then remove it and show it pass.

## What to capture (capturing-screenshots)
- The CodeArtifact domain + repos with upstreams.
- The ECR repo settings showing IMMUTABLE + scan-on-push.
- A successful pipeline run, and the **failing** run blocked by the gate (the money shot).
- The scan findings summary.

## Trade-offs to explain
- IMMUTABLE tags force SHA-based tagging and a redeploy-to-roll-forward model (no silent
  overwrite) — that is the auditability win.
- CodeArtifact adds a proxy hop but gives provenance and the ability to block/curate packages.
- ECR basic scanning is free and quick; Amazon Inspector (enhanced) finds more but costs more.

## Done when
CodeArtifact proxies npm + pip, ECR is IMMUTABLE with scan-on-push, the pipeline builds
and pushes a SHA-tagged image, the gate has been shown to **both pass clean and fail on a
High/Critical**, and all of it is captured and written up.
