# Kids Music Quality-First Media Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reopen the falsely-completed video-engine step, replace the low-quality Free.ai music bottleneck with a quality-first prototype route, and enforce a separate final-commercial-regeneration gate before publication.

**Architecture:** Supabase canonical state remains authoritative. Prototype media may be non-commercial but is tagged fail-closed for publication; final media must be newly generated through a commercial-use route and independently re-reviewed. Provider selection is evidence-driven through live Tunilu/music benchmarks.

**Tech Stack:** Supabase PostgreSQL canonical state, Gmail/Work automations, Opera Browser Connector, Suno web/platform, Krea web, existing Gemini reviewer/STT routes.

**Spec:** `docs/superpowers/specs/2026-08-31-kids-music-quality-first-media-pipeline-design.md`

## Global Constraints
- Cash spend remains EUR 0 until separately authorized.
- Non-commercial prototype files may never be published or monetized.
- Every prototype without commercial rights must set `FINAL_COMMERCIAL_REGEN_REQUIRED=true`.
- STEP036 cannot be DONE without a live-benchmarked true generative video engine.
- STEP042 cannot be DONE on the failed ACE-Step candidate.
- Preserve immutable negative evidence; supersede policy/state through new canonical versions rather than deleting history.

---

### Task 1: Correct canonical policy and step states

**Files:**
- Canon docs: `QUALITY_FIRST_MEDIA_PIPELINE_POLICY`, `STEP_036_LIVE_STATE`, `STEP_042_LIVE_STATE`, `MASTER_CHARTER`

**Interfaces:**
- Consumes: latest `MASTER_CHARTER`, existing STEP036/STEP042 evidence.
- Produces: authoritative live state for schedulers and agents.

- [ ] Write a precondition SQL query that demonstrates STEP036 is currently DONE and STEP042 is Free.ai-cap blocked.
- [ ] Persist `QUALITY_FIRST_MEDIA_PIPELINE_POLICY:v1`.
- [ ] Persist corrected STEP036 state as `NOT_DONE / REVISION_REQUIRED_REAL_GENERATIVE_ENGINE`.
- [ ] Persist corrected STEP042 state with ACE-Step FAIL retained and Suno prototype route active.
- [ ] Cancel the queued Free.ai retry job so it cannot burn another daily music allowance after the route is superseded.
- [ ] Write a new MASTER_CHARTER version reflecting the corrections.
- [ ] Re-read all four records and verify exact states.

### Task 2: Suno prototype music route

**Files:**
- Canon docs/artifacts: `STEP_042_SUNO_PROTOTYPE_ROUTE`, prototype music artifacts/reviews.

**Interfaces:**
- Consumes: approved lyrics artifact, music brief, quality-first policy.
- Produces: accepted internal prototype or precise blocker; never a publishable artifact.

- [ ] Verify current Suno free-plan quota and non-commercial restriction from official sources.
- [ ] Inspect connected browser/session for Suno access and official platform API availability.
- [ ] If a zero-cost official API path is available, record its auth/setup gate; otherwise use web UI as the prototype execution lane without reverse-engineering private APIs.
- [ ] Generate multiple bounded candidates within the free daily budget, preserving exact approved lyrics and production brief.
- [ ] Review candidate quality for melody, child-safe vocal clarity, hook quality, lyric fidelity, arrangement and replay value.
- [ ] Mark the best passing candidate `INTERNAL_PROTOTYPE_NONCOMMERCIAL` with `FINAL_COMMERCIAL_REGEN_REQUIRED=true`.
- [ ] Do not mark STEP042 publishably DONE; record `PROTOTYPE_ACCEPTED_FINAL_COMMERCIAL_REGEN_PENDING` if quality passes.

### Task 3: Real primary video engine benchmark

**Files:**
- Canon docs/artifacts: `STEP_036_VIDEO_ENGINE_CANDIDATES`, Tunilu benchmark artifacts/reviews.

**Interfaces:**
- Consumes: Visual Bible, Character Bible, Video Soul, approved Tunilu reference image.
- Produces: selected true generative prototype engine or ranked blocker evidence.

- [ ] Verify current Krea free daily compute and available free video models in the live account.
- [ ] Choose the strongest available image-to-video model for character consistency.
- [ ] Run one Tunilu 4–6 second I2V benchmark with a controlled prompt/camera action.
- [ ] Review identity stability, anatomy, teeth/trunk constraints, camera continuity, flicker and preschool safety.
- [ ] If FAIL and quota permits, run one bounded repair with a materially changed prompt/model setting.
- [ ] If Krea cannot satisfy quality/throughput, move to the next zero-cost prototype candidate and preserve evidence; do not fall back to deterministic FFmpeg as primary.
- [ ] Only when a true generator passes, set STEP036 to `PROTOTYPE_ENGINE_VERIFIED` and record whether it is API-connected or web-only.

### Task 4: Publish gate enforcement

**Files:**
- Canon policy/state-machine documents governing asset publication.

**Interfaces:**
- Consumes: prototype artifact rights metadata.
- Produces: fail-closed publish eligibility decision.

- [ ] Add/record policy that `rights_state != COMMERCIAL_VERIFIED` or `FINAL_COMMERCIAL_REGEN_REQUIRED=true` rejects publish eligibility.
- [ ] Require final commercial asset lineage to point to canonical spec/reference inputs, not to an illicitly reused prototype master.
- [ ] Require final independent review after commercial regeneration.
- [ ] Verify a synthetic non-commercial Suno/Krea prototype is rejected by the publish gate.

### Task 5: Scheduler reconciliation

**Files:**
- `MASTER_CHARTER`, existing `Kids Music Canon Executor` task state.

**Interfaces:**
- Consumes: corrected live frontier.
- Produces: next hourly run that follows the new policy.

- [ ] Verify Canon Executor remains enabled with sole prompt `izvrsavaj step iz canon fajla`.
- [ ] Confirm the latest master version exposes the new STEP036/STEP042 frontier and no stale Free.ai retry instruction.
- [ ] Verify no new owner action is created unless authentication/UI genuinely cannot be completed autonomously.
