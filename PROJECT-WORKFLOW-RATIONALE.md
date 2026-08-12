# Project Workflow Rationale

This document records why the workflow was selected. Operational instructions live
in `PROJECT-WORKFLOW.md`.

## Selected Approach

[Matt Pocock's skills](https://github.com/mattpocock/skills) were selected because
their modular structure front-loads detailed questioning and reduces costly
requirement misunderstandings. The tradeoff is a longer initial conversation and
potentially verbose specifications or tickets.

## Alternatives Considered

**[OpenSpec](https://github.com/Fission-AI/OpenSpec).** Its proposal, delta-spec,
design, task, synchronization, and change-history structure is better suited to teams
that need formal change traceability. It was not selected because it creates several
artifacts per change and adds synchronization overhead.

**[Superpowers](https://github.com/obra/superpowers).** Its strict test-driven
development, detailed planning, isolated execution, approval gates, and repeated
review suit large or high-risk autonomous work. It was not selected because that
ceremony is mandatory even for small changes.

## Framework Boundary

Use one lifecycle framework rather than combining these approaches. Keep
[Karpathy-inspired guidelines](https://github.com/multica-ai/andrej-karpathy-skills)
as concise agent principles, not as a second lifecycle framework.
