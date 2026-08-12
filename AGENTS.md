# Agent Instructions

## Context

- Read `README.md`, `MAIN-SPEC.md`, active change spec, and relevant code/tests
  when present.
- `MAIN-SPEC.md` is current as-is truth. Approved change spec (or agreed plan if
  none) supersedes affected sections for that change; `MAIN-SPEC.md` governs
  everything else. On conflict, stop and clarify.
- Do not edit `MAIN-SPEC.md` / `README.md` before completion, unless asked.

## Implementation

- Surface ambiguous requirements before coding when choice affects observable
  behavior, data, security, compatibility, recovery, or costly architecture.
- For reversible implementation details, follow existing patterns and choose
  simplest solution.
- Keep changes within approved scope. Avoid speculative features and unrelated
  refactors.
- Test observable behavior and run relevant checks before completion.

## Completion

- Review against approved change spec or agreed plan.
- Update `README.md` only for changed user-facing setup or usage.
- Update `MAIN-SPEC.md` only when the completed work changes a durable,
  non-obvious project contract, constraint, or decision that future work must know
  and that code/tests do not already express adequately. Prefer replacing or
  deleting existing text. Never add task history, implementation narrative,
  one-off findings, speculative guidance, or duplicated information. If no fact
  passes this test, leave the file unchanged.
- Report verification performed and unresolved risks.

## Project-Specific Rules

<!-- Add commands, protected files, architecture constraints, and other rules. -->
