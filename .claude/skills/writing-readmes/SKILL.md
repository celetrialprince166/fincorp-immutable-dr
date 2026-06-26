---
name: writing-readmes
description: Generates an industry-standard, evidence-rich project README modeled on a proven gold standard — discovers what the project is, ANALYZES every image in the repo by actually opening it, intelligently decides which section each image belongs in and writes alt text that states what the image proves, then assembles the full README on a consistent section skeleton with real relative paths. Use when asked to create, rewrite, or polish a project README, produce submission-quality repo documentation, or place screenshots/diagrams into a README.
---

# Writing READMEs

A README is the project's front door and the first thing a reviewer or recruiter
reads. This skill produces a complete, professional, evidence-backed README that
reads like the gold-standard model — and, crucially, **places every image where
it belongs by understanding what the image shows**, not by guessing from a filename.

## The model to imitate
The structural gold standard lives next to this file:
[`reference-example.md`](reference-example.md) (the `celetrialprince166/pongapp`
README; live at <https://github.com/celetrialprince166/pongapp>). **Read it first,
every time.** Match its section order, its image-per-phase evidence pattern, its
descriptive alt text, its tables and directory tree, and its measured,
trade-off-aware tone. Adapt the content to the project at hand — never copy
pongapp's subject matter.

---

## Procedure

### 1 — Discover the project
Before writing a word, learn what this repo actually is:
- Read `AGENTS.md` / `CLAUDE.md`, any `docs/` index, existing tutorials, and the
  roadmap. These carry the project's purpose, phases, objectives, and the "why".
- Read the IaC / source to get real names, regions, resources, and values
  (don't invent them — pull endpoints, ARNs, CIDRs, module names from the code).
- Identify: the one-line thesis, the audience, the phases/objectives, the tech
  stack, the verified results (RTO, scan counts, costs), and the author.

### 2 — Inventory AND analyze every image  ← the heart of this skill
This is the step that makes the README intelligent. Do not skip the analysis.
1. **Find every image**: glob `docs/assets/**`, `docs/architecture/**`,
   `**/screenshots/**`, `*.png|*.jpg|*.jpeg|*.gif|*.webp|*.svg`. Also note any
   architecture diagram (often a single hero image) separately.
2. **Open each image with the Read tool** — Read renders images visually. Look at
   what it actually depicts; the filename is a hint, not the truth. For each image
   record: the AWS/console service shown, the state it proves (e.g. "RDS available",
   "29 HIGH/CRITICAL → GATE FAILED", "restored DB in eu-west-1"), and any visible
   identifiers.
3. **Classify** each image into one role:
   - `architecture` — a diagram of the system (→ Architecture section)
   - `provision` — infra created (network, registry, vaults, DB) 
   - `pipeline`/`build` — CI/CD runs, build logs, registry settings
   - `verify` — a control/setting proven (immutability, scan-on-push, SG rules)
   - `gate`/`security` — a pass/fail or security decision
   - `dr`/`resiliency` — failover, restore, recovery-point, RTO
   - `results` — dashboards, benchmark/score, the running app
4. **Read the filename convention.** A `pN-...` prefix encodes a phase number —
   map it to that phase's evidence subsection. Respect it; don't reshuffle across
   phases unless the image content clearly contradicts the prefix.

### 3 — Map images to sections (intelligent placement)
- **Architecture diagrams** → the **Architecture** section, one per variant/region,
  each followed by a dense paragraph explaining what the diagram shows.
- **Everything else** → the **Build Walkthrough and Evidence** section, grouped
  under the phase it belongs to, and **ordered by the narrative**:
  provision → build/deploy → verify → secure/gate → recover/DR → results.
- Within a phase, lead with a one-line sentence framing what the images prove,
  then the images in that logical order, then a `Full chapter:` link to the
  matching tutorial if one exists.
- A "money shot" (the running app, the green pipeline, the passed gate, the
  measured RTO) is worth featuring — put the single most convincing image first
  in its group.
- **Never embed an image you have not opened. Never invent a path** — use the real
  relative path from the repo root exactly as it exists on disk. If the README is
  not at repo root, make paths relative to the README's location.
- If an image referenced by the docs is missing on disk, leave a clear
  `<!-- TODO: capture docs/assets/<name>.png -->` rather than a broken link, and
  list it back to the user.

### 4 — Write alt text that states what the image PROVES
Alt text is not a label; it's the caption a reviewer reads. Compare:
- ✗ `![screenshot](docs/assets/p2-01.png)`
- ✓ `![ECR fincorp-backend: Immutable tags, scan-on-push, AES-256](docs/assets/p2-pipeline-ecr-immutable-scan-02.png)`
Write a full, specific phrase naming the service and the proven state. This is
what carries meaning when the image is the evidence.

### 5 — Assemble the README on the skeleton (below), then verify
- Fill every section from real project facts; cut sections that genuinely don't
  apply (e.g. no "Benchmark Results" if the project isn't a comparison — replace
  with "Results" / "Outcomes" or omit).
- Verify: every image path resolves to a real file; every TOC anchor matches a
  heading; tables and the directory tree render; no invented commands or values;
  tone is measured (no hype, no emoji-as-headers).

---

## The section skeleton
Sections in this order, each separated by a `---` divider. Keep the names unless
the project calls for a clearly better one.

1. **Title (H1)** — `project: <crisp value proposition>`. One bold idea, no fluff.
2. **Intro** — 1–3 short paragraphs: what it is, what it proves, and (if relevant)
   the subject/app under test. State the constraint or objective up front.
3. **Table of Contents** — bullet anchor links to every section below.
4. **Motivation** — the gap this fills and why it was built; then the phases as a
   numbered list; close with what it was meant to practise/demonstrate.
5. **Architecture** — shared topology paragraph, then a subsection per
   variant/region with its **diagram image** + an explaining paragraph; close with
   the consequential differences and any interactive explorer link.
6. **Build Walkthrough and Evidence** — a phase subsection each: framing line →
   evidence images (analyzed + alt-texted) → `Full chapter:` link.
7. **Results** (or **Benchmark Results**) — a scored/measured table and a bolded
   **Recommendation**/**Outcome** sentence with the trade-off.
8. **Prerequisites** — tooling + access, as a bullet list with versions.
9. **Installation and Setup** — fenced code blocks per track/path; include a
   **Teardown** subsection (cost-aware projects must show how to stop billing).
10. **Usage** — fenced commands for operating/verifying/demonstrating it.
11. **Project Structure** — a directory tree in a code block + a one-line note on
    the one non-obvious layout decision.
12. **Key Technologies** — `**Tech** — what it is and *why it was chosen*` bullets.
13. **Learning Outcomes** — what was built and learned, as outcome bullets.
14. **Challenges and Solutions** — `###` per challenge, each with bold
    **Problem:** / **Root cause:** / **Solution:** — the most credibility-building
    section; use the real failures the project hit.
15. **Future Improvements** — honest next steps.
16. **Contributing** — short fork/branch/PR steps.
17. **License** — one line.
18. **Author** — name, role, GitHub, email.

---

## Tone & quality bar
- Measured and evidence-first. State trade-offs; never oversell. No marketing voice.
- Headings are words, not emoji. Bold sparingly, for terms and verdicts.
- Prefer concrete numbers (cost, RTO, finding counts, versions) over adjectives.
- Match the existing project's spelling/voice if one is established.
- Real paths, real commands, real values — a reviewer will try to run them.

## Done when
- [ ] `reference-example.md` was re-read and its structure followed.
- [ ] Every image on disk was opened and either placed (right section, narrative
      order, proof-stating alt text) or deliberately omitted — none guessed-at.
- [ ] No broken image paths and no invented paths; TODOs left for any missing-but-
      referenced asset and surfaced to the user.
- [ ] Every TOC anchor resolves; tables and the directory tree render.
- [ ] Sections filled from real project facts; teardown present if anything bills.
- [ ] Tone is measured; author block correct.
