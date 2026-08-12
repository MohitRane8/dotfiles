# AI Project Workflow

Goal: expose assumptions before code, then let agent implement autonomously against
one compact source of current truth.

## Project Documents

- `README.md` — user-facing introduction and usage.
- `MAIN-SPEC.md` — authoritative current behavior, architecture, cross-cutting
  constraints, and durable decisions.
- `AGENTS.md` — agent workflow and project-specific operating rules.
- Active change spec — approved intent for one change; issue or temporary document.

Existing system follows `MAIN-SPEC.md`. Approved change spec defines intended
delta. Conflicts stop implementation for clarification. The main spec is a compact
reference, not a change log or a repository tour.

## Default Flow

For new projects and non-trivial changes, use selected [Matt Pocock skills](https://github.com/mattpocock/skills).
Agents start from `README.md` + `MAIN-SPEC.md` (via `AGENTS.md`).

```text
grill-with-docs → [to-spec] → preview doc deltas → [to-tickets] → implement → code-review → reconcile MAIN-SPEC.md
# [to-spec]/to-tickets]: optional; skip for small one-session work
# preview doc deltas: in chat only — expected MAIN-SPEC.md (/ README.md) section edits from approved intent; no file writes; approve before implement
# reconcile MAIN-SPEC.md: apply the AGENTS.md admission rule; leaving it unchanged is a valid outcome
```

## Final Reconciliation

Keep this step in the implementation conversation, after code review, because that
conversation has the approved intent, final code, and review findings. Do not open a
new conversation merely to write the main spec.

For a large or high-risk change, a fresh agent may review the proposed documentation
delta for omissions, duplication, and task-specific detail before the implementation
conversation applies it. Give that reviewer the existing main spec, approved change
spec, final diff, and review findings. Use the fresh agent as a reviewer, not the
default author.

Reconciliation means editing the smallest existing section that now became false or
incomplete, and removing superseded text. It does not mean summarizing the work. The
admission rule in `AGENTS.md` decides whether any main-spec edit is warranted.

## Tool Choice

**Matt skills — selected.** Modular and front-loads detailed questioning, directly
targeting costly requirement misunderstandings. Costs: longer initial conversation
and potentially verbose specs/tickets; keep tickets optional and specs compact.

**[OpenSpec](https://github.com/Fission-AI/OpenSpec) — not selected.** Strong
proposal/delta-spec/design/task structure, synchronization, and change history.
Costs: several artifacts per change, more synchronization, and stronger bias toward
reasonable agent assumptions than exhaustive discovery. Better fit for teams needing
formal change traceability.

**[Superpowers](https://github.com/obra/superpowers) — not selected.** Strong design
approval, strict TDD, detailed planning, isolated execution, and repeated review.
Costs: mandatory ceremony for small changes, many approval gates, and highly detailed
plans to review. Better fit for large or high-risk autonomous work.

Use one workflow owner. Do not combine these lifecycle frameworks. Keep
[Karpathy-inspired guidelines](https://github.com/multica-ai/andrej-karpathy-skills)
as short `AGENTS.md` principles—surface assumptions, prefer simplicity, make
surgical changes, and verify goals—not as another workflow.
