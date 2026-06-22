# module: codebuild

**Intent (Phase per AGENTS.md roadmap):** CodeBuild project that authenticates to CodeArtifact, installs npm+pip deps through it, builds the Docker image, pushes to ECR (immutable tag = commit SHA), then reads the ECR scan and fails on HIGH/CRITICAL. Includes the CodeBuild IAM role (least-privilege) and a reference buildspec.

> Stub created during scaffolding. Implement in the build conversation following the
> `securing-supply-chain` / `disaster-recovery` skills.
