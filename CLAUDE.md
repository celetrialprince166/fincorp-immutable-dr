# CLAUDE.md

This project's full operating contract lives in **AGENTS.md**. Read it before
doing any work — it defines the project, the prime directives, and (critically)
the **skill routing table** that tells you which skill to invoke automatically.

@AGENTS.md

## Quick reminder
- Skills in `.claude/skills/` are invoked **proactively** based on AGENTS.md §4.
- Subagents in `.claude/agents/` handle focused pipeline / infra / docs / review work.
- Every phase ends with screenshots + a tutorial chapter, then a teardown note.
- Two regions: **us-east-1** (primary) and **us-west-2** (DR). Never leave RDS,
  NAT, or pipelines running silently — always offer the teardown.
