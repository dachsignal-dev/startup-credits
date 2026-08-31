# Kids Music Quality-First Media Pipeline Design

## Goal
Replace the pre-revenue "commercial-rights-first" media selection rule with a quality-first prototype pipeline while preserving a hard no-publish gate for assets that lack commercial rights.

## Core policy
1. `PROTOTYPE` and `PUBLISHABLE` are separate lifecycle states.
2. Prototype generation may use zero-cost/non-commercial providers if their terms allow lawful private/internal non-commercial use.
3. Any prototype without verified commercial publication rights gets `FINAL_COMMERCIAL_REGEN_REQUIRED=true`.
4. A non-commercial prototype can inform our own canonical specification (lyrics, BPM, arrangement, shot list, character/reference images, timing, motion, camera, visual style), but the prototype file itself may not be published, monetized, distributed commercially, or treated as licensed final media.
5. Final publishable media must be newly generated/created through a route with verified commercial-use rights at the time of creation and must independently pass QA/review.
6. No claim that a later subscription retroactively licenses an earlier non-commercial output unless the provider explicitly grants that exact right for that exact asset.
7. Pre-revenue cash spend remains EUR 0 unless the owner separately changes the policy.

## Music architecture
- Prototype primary: Suno Free, because current official plan provides 50 credits/day (up to 10 songs) and quality materially exceeds the failed ACE-Step candidate.
- Prototype output state: `INTERNAL_PROTOTYPE_NONCOMMERCIAL`.
- ACE-Step/Free.ai is demoted from primary to optional fallback/benchmark only.
- Canonical music spec captures only user-owned/independent inputs and abstract production decisions: approved lyrics, BPM, duration target, section structure, instrumentation, energy curve, vocal character, pronunciation constraints and QA findings.
- Before publication, generate a new final song on a verified commercial route (e.g. Suno paid while subscription is active, or another provider) from the canonical spec; do not reuse the free Suno audio as the final master.

## Video architecture
- STEP036 is reopened: deterministic FFmpeg/2.5D remains assembly/fallback only and is not a primary generative video engine.
- Prototype primary selection is based on live quality + iteration capacity, not commercial rights. First probe: Krea Free web video because it offers daily free compute and selected video-model access without a card.
- If Krea's available free model is inadequate or too constrained, test the next highest-quality zero-cost prototype route. Provider/model names are not locked until a live Tunilu I2V benchmark passes.
- Autonomous/API lane remains desirable but cannot be mislabeled as primary until it passes the same visual identity and continuity benchmark.
- Prototype video assets without commercial rights get `FINAL_COMMERCIAL_REGEN_REQUIRED=true` and may only be used as internal visual references/storyboard/edit timing prototypes.
- Final video shots must be regenerated using a commercial-use route before publish and independently pass the Visual/Character Bible + Video Soul gates.

## State corrections
- STEP036: `NOT_DONE`, `REVISION_REQUIRED_REAL_GENERATIVE_ENGINE` until a real AI video generator is live-benchmarked.
- STEP042: `NOT_DONE`, but no longer blocked on Free.ai daily cap. Failed ACE-Step candidate remains immutable negative evidence. Suno prototype route becomes the active quality experiment.
- STEP043 remains blocked until a music prototype is accepted for creative development; publish authorization remains blocked until final commercial media exists.

## Safety / rights gate
- No payment, card, PAYG, upgrade, or token purchase without explicit owner authorization.
- No external publication of non-commercial prototype assets.
- No attempt to strip watermarks/metadata or conceal provider/tier provenance.
- Preserve provider, tier, generation timestamp, terms/rights state, and final-regeneration requirement with every media artifact.

## Success criteria
- Music: multiple quality iterations are available per day; one prototype is accepted for creative direction; a separate final-commercial regeneration gate is explicit.
- Video: a true generative I2V/T2V engine produces a Tunilu benchmark that passes character identity/safety/camera continuity quality gates; provider/API status is recorded truthfully.
- Canon never marks STEP036 complete based only on FFmpeg/deterministic animation.
